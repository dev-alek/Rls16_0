using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.
using ibs.th.str.utd.sts.*.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сканирование акцизных марок".
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
define variable vss-include-info0 as character format "X(65)" no-undo
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-date
  )  .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
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
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "X(65)" no-undo
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter parparentproc         as handle              no-undo .
define input parameter p-doc-id as integer no-undo .
define input parameter p-db-num as integer   no-undo .
define input parameter p-mode as character no-undo .
define variable iLang           as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable v-comment      as character no-undo .
define variable m-gds-code     as character no-undo label "Товар" view-as fill-in.
define variable gds-rec         as integer   no-undo .
define variable v-proc-name-err as character no-undo initial 'impmark.txt'.
define variable l-error         as logical   no-undo.
define variable v-user-action   as character no-undo.
define variable v-printed       as logical   no-undo.
define variable v-mark-short     as character no-undo.
define buffer X_utd-lines           for tt-utd-lines .
define buffer buf_clients  for ub.clients .
define buffer buf_marking  for ub.marking .
define buffer buf_marking-lines  for ub.marking-lines .
define buffer buf_utd  for ub.utd .
define buffer buf_utd-attr for ub.utd-attr .
define buffer buf_utd-lines  for ub.utd-lines .
define buffer buf_utd-lines-attr  for ub.utd-lines-attr .
define buffer buf_utd-marking-lines  for ub.utd-marking-lines .
define buffer bf_fbr-line  for ub.fbr-line.
define buffer buf_recipe   for ub.recipe .
define buffer bf_bar-code  for ub.bar-code.
define buffer buf_goods for ub.goods .
define buffer buf_gds-obj for ub.gds-obj .
define variable v-timedelay  as integer   no-undo.
define variable v-scan-str as character no-undo.
define variable v-num-str as integer no-undo .
define variable v-manual as logical no-undo .
define variable recid_utd      as integer   no-undo .
define variable vLineNum as integer no-undo .
define variable marking as class mark no-undo .
define variable v-attr-value like ub.gds-obj-attr.attr-value no-undo .
define variable v-attr-type as character no-undo .
define variable disable-set as logical no-undo init no .
define stream str-err .
define stream in-stream.
DEFINE MENU m_marks
   MENU-ITEM m_marks-utd    LABEL "Марки по документу"
   MENU-ITEM m_marks-lines  LABEL "Марки по строке".
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b_del-line
     LABEL "Удалить товар"
     SIZE 36 BY 1.24.
DEFINE BUTTON B_mark
     LABEL "Марки"
     SIZE 10 BY 1.
DEFINE BUTTON b_prov-finish
     LABEL "Проверка завершена"
     SIZE 36 BY 1.24.
DEFINE BUTTON r-obj-TH
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE c-status AS INTEGER FORMAT "-999":U INITIAL 0
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Новый",0,
                     "Подтвержден",8
     DROP-DOWN-LIST
     SIZE 55.6 BY 1 NO-UNDO.
DEFINE VARIABLE c-type AS INTEGER FORMAT "-999":U INITIAL 10
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEM-PAIRS "Сбор марок",10
     DROP-DOWN-LIST
     SIZE 42 BY 1 NO-UNDO.
DEFINE VARIABLE f-comment AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 100 BY 3.5 NO-UNDO.
DEFINE VARIABLE a-n-c-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 45 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE f-comment-name AS CHARACTER FORMAT "X(256)":U INITIAL "Комментарий:"
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.
DEFINE VARIABLE f-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-name AS CHARACTER FORMAT "X(256)":U INITIAL "Дата:"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 115 BY 1 NO-UNDO.
DEFINE VARIABLE f-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-name AS CHARACTER FORMAT "X(256)":U INITIAL "№ документа:"
     VIEW-AS FILL-IN
     SIZE 12.6 BY 1 NO-UNDO.
DEFINE VARIABLE f-obj-code-TH AS INTEGER FORMAT "->>>>>>" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14.8 BY 1.
DEFINE VARIABLE f-obj-name-TH AS CHARACTER FORMAT "X(100)"
     VIEW-AS FILL-IN
     SIZE 48.6 BY 1.
DEFINE VARIABLE f-obj-type-TH AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.2 BY 1.
DEFINE VARIABLE f-status-TH AS CHARACTER FORMAT "X(256)":U INITIAL "Статус ТН:"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(256)":U
     LABEL "Марка"
     VIEW-AS FILL-IN
     SIZE 100 BY 1 NO-UNDO.
DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Код", "code",
"Нач.назв", "name",
"Нач.слова", "context"
     SIZE 37.6 BY 1 NO-UNDO.
DEFINE VARIABLE R-error       AS INTEGER
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS
   "Все", 1,
   "Ошибки", 2
   SIZE 22 BY 1 NO-UNDO.
DEFINE RECTANGLE R-TH
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 73.6 BY 3.1 TOOLTIP "Данные ТН".
DEFINE VARIABLE is-initial-set AS LOGICAL INITIAL no
     LABEL "Первоначальный сбор марок"
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .81 NO-UNDO.
DEFINE QUERY br-utd-lines FOR
      X_utd-lines SCROLLING.
DEFINE BROWSE br-utd-lines
  QUERY br-utd-lines NO-LOCK DISPLAY
      X_utd-lines.LineNum FORMAT "99999":U label "Номер"
      X_utd-lines.gds-code FORMAT "999999999":U label "Код товара"
      X_utd-lines.GdsName FORMAT "x(128)":U label "Наименование товара" width 40
      X_utd-lines.Quantity FORMAT "->>,>>9.<<<":U label "Просканировано"
      X_utd-lines.free-qnty FORMAT "->>,>>9.<<<":U label "Общий остаток"
      X_utd-lines.UnitCode FORMAT "x(8)":U label "Единица измерения"
    WITH SEPARATORS SIZE 117 BY 8.
DEFINE FRAME Dialog-Frame
     b-cancel AT ROW 1.24 COL 2
     b-exit AT ROW 1.24 COL 12 WIDGET-ID 380
     B_mark AT ROW 1.24 COL 109 WIDGET-ID 80
     c-type AT ROW 2.43 COL 5.2 COLON-ALIGNED WIDGET-ID 240
     f-num-name AT ROW 2.43 COL 53.8 NO-LABEL WIDGET-ID 328
     f-num AT ROW 2.43 COL 64.6 COLON-ALIGNED NO-LABEL WIDGET-ID 284
     f-date-name AT ROW 2.43 COL 81.2 NO-LABEL WIDGET-ID 330
     f-date AT ROW 2.43 COL 85.2 COLON-ALIGNED NO-LABEL WIDGET-ID 286
     is-initial-set AT ROW 3.86 COL 77 WIDGET-ID 344
     f-obj-type-TH AT ROW 5.05 COL 7 RIGHT-ALIGNED NO-LABEL WIDGET-ID 102
     f-obj-code-TH AT ROW 5.05 COL 22.8 RIGHT-ALIGNED NO-LABEL WIDGET-ID 98
     r-obj-TH AT ROW 5.05 COL 23.6 WIDGET-ID 104
     f-obj-name-TH AT ROW 5.05 COL 74.6 RIGHT-ALIGNED NO-LABEL WIDGET-ID 100
     f-status-TH AT ROW 6.95 COL 6 NO-LABEL WIDGET-ID 336
     c-status AT ROW 6.95 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 238
     f-comment AT ROW 8 COL 17 NO-LABEL WIDGET-ID 266
     f-comment-name AT ROW 8.19 COL 4 NO-LABEL WIDGET-ID 340
     v-mark AT ROW 11.48 COL 15 COLON-ALIGNED
     a-n-c AT ROW 12.76 COL 3 NO-LABEL WIDGET-ID 272
     a-n-c-name AT ROW 12.81 COL 40.2 COLON-ALIGNED NO-LABEL WIDGET-ID 278
     R-error AT ROW 12.76 COL 99 NO-LABEL WIDGET-ID 372
     br-utd-lines AT ROW 13.81 COL 3
     f-msg AT ROW 21.95 COL 3 NO-LABEL WIDGET-ID 92
     b_prov-finish AT ROW 23.14 COL 3 WIDGET-ID 70
     b_del-line AT ROW 23.14 COL 39 WIDGET-ID 94
     "Объект:" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 4.1 COL 4 WIDGET-ID 182
     "Данные ТН:" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 3.62 COL 33.6 WIDGET-ID 180
     R-TH AT ROW 3.76 COL 3 WIDGET-ID 112
     SPACE(2) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ сбора марок"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.
function CrCheckMarkDoc return char
   (v-cntxt-obj-type as char,
   v-cntxt-obj-code as int,
   idb-num as int,
    idoc-id as int,
   imark as char,
    is-initial-set-p as logical
   )
      :
  define buffer buf_marking-child for ub.marking .
  define buffer buf_marking for ub.marking.
  define buffer buf_marking-attr for  ub.marking-attr.
  define buffer buf_marking-parent for ub.marking .
  define buffer buf_utd-marking-lines for ub.utd-marking-lines.
  define buffer buf_utd-marking-lines-child for ub.utd-marking-lines .
  define buffer buf_utd-lines for ub.utd-lines.
  define buffer buf_goods for ub.goods.
  define buffer buf_gds-obj for ub.gds-obj.
  define variable v-par-type as character no-undo.
  define variable v-par-val  as character no-undo.
  define variable v-gds-code as integer no-undo .
  define variable v-num-recipes as integer no-undo .
  define variable v-GTIN as character no-undo .
  define variable v-GTIN-qnty as decimal no-undo .
  define variable v-GTIN-child as character no-undo .
  define variable v-GTIN-qnty-child as decimal no-undo .
  define variable v-free-qnty as decimal no-undo .
  define variable v-old-sts as integer no-undo .
  define variable v-mark-short as character no-undo.
  define variable v-GisMTcheckStatus as integer no-undo .
  define variable v-is-off-line as logical no-undo .
  define variable v-mark-weight as decimal no-undo .
  define variable v-isweighed as logical no-undo .
  define variable v-ok        as logical no-undo .
  if imark = ""
    then return "".
  v-mark-short = GetCodeIdent(imark).
  if v-mark-short = "" or v-mark-short = ?
  then do:
    return "Неизвестный формат марки.".
  end.
  find first buf_marking where (buf_marking.mark begins v-mark-short) no-error.
  if available buf_marking
  then do :
    if buf_marking.unit-ext = "LEVEL2" then
      return "Неизвестный формат марки.".
    v-GTIN = getGtinByDM(buf_marking.mark) .
  end .
  else do :
    v-GTIN = getGtinByDM(imark) .
  end .
  v-gds-code = getGdsCodeByGtin(v-GTIN) .
  v-GTIN-qnty = getQntyCodeByGtin(v-GTIN) .
  if v-gds-code = ?
  then do :
    return substitute ("Не удалось найти товар по gtin &1",v-GTIN).
  end .
  find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
  if not available buf_goods
  then do :
    return substitute ( "Не найден товар по коду &1.",v-gds-code ).
  end .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
  ( buf_goods.gds-code,
   'weighed-gds':U,
   output v-par-val,
   output v-par-type
  ).
  v-isweighed = logical(v-par-val) .
  if v-GTIN-qnty = ?
  or v-GTIN-qnty <= 0.0
  then do :
    return substitute ("Не установлен коэффициент для упаковки для марки &1.",imark).
  end .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
  ( buf_goods.gds-code,
   'mark-type':U,
   output v-par-val,
   output v-par-type
  ).
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsArticForType(v-par-val)
  or (not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsArticForType(v-par-val)
    and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(v-par-val)
    and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsMarkingForType(v-par-val)
      )
  then do :
    return substitute ("Сверка марок товара &1 '&2' не требуется", buf_goods.gds-code,buf_goods.gds-name).
  end .
  if v-isweighed
  and v-par-val > ""
  and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(v-par-val)
  and not available buf_marking
  then do :
    return "Марка не найдена в БД" .
  end .
  define variable v-attr-value as character no-undo.
  define variable v-attr-type as character no-undo.
 run gdsoattr-value in this-procedure (input   'mark-collect-type':U,
                                        input   buf_goods.gds-code,
                                        input   v-cntxt-obj-type,
                                        input   v-cntxt-obj-code,
                                        output  v-attr-value,
                                        output  v-attr-type
                                        ) no-error.
  find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = idb-num
                                             and buf_utd-marking-lines.doc-id = idoc-id
                                             and buf_utd-marking-lines.mark begins v-mark-short
                                             no-error.
  if available buf_utd-marking-lines
  then do :
     return substitute ("Марка &1 добавлена в документ ранее.",imark).
  end .
  find first buf_utd-lines exclusive-lock where buf_utd-lines.db-num    = idb-num
                                            and buf_utd-lines.doc-id    = idoc-id
                                            and buf_utd-lines.gds-code  = buf_goods.gds-code
                                            no-error .
  if not available buf_utd-lines
  then do :
    if is-initial-set-p
    then do :
      if v-attr-value = "1"
      or v-attr-value = "2"
      then do :
        message substitute("Для товара &1 ранее был выполнен первоначальный сбор марок, хотите произвести его повторно?", buf_goods.gds-name)
        view-as alert-box question buttons yes-no update v-ok .
        if not v-ok
        then do :
          return "" .
        end .
      end .
        else do :
        disable is-initial-set with frame Dialog-Frame .
      end .
    end .
    else do :
      if v-attr-value = ""
      or v-attr-value = "0"
      then do :
        if vLineNum = 0
        then do :
          assign is-initial-set = yes .
          display is-initial-set with frame Dialog-Frame .
        end .
        else do :
          message substitute("Для товара &1 не выполнен первоначальный сбор марок, товар не может быть добавлен в документ без признака «Первоначальный сбор марок». Создайте для товара отдельный документ", buf_goods.gds-name)
          view-as alert-box .
          return "".
        end .
      end .
    end .
    vLineNum = vLineNum + 1.
    create buf_utd-lines .
    assign
      buf_utd-lines.db-num    = idb-num
      buf_utd-lines.doc-id    = idoc-id
      buf_utd-lines.gds-code  = buf_goods.gds-code
      buf_utd-lines.UnitCode  = buf_goods.unit-base
      buf_utd-lines.LineNum   = vLineNum
    .
    assign v-free-qnty = 0 .
    find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                     and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                     and buf_gds-obj.artic     = buf_goods.artic
                                     and buf_gds-obj.prod-type = buf_goods.prod-type
                                     and buf_gds-obj.prod-code = buf_goods.prod-code
                                     no-error .
    if available buf_gds-obj
    then do :
      assign v-free-qnty = buf_gds-obj.free-qnty .
    end .
    create tt-utd-lines .
    buffer-copy buf_utd-lines to tt-utd-lines
    assign
      tt-utd-lines.free-qnty = v-free-qnty
      tt-utd-lines.GdsName = buf_goods.gds-name
    .
  end .
  if v-isweighed
  then do :
    find first buf_marking-attr where buf_marking-attr.mark      eq buf_marking.mark
                                  and buf_marking-attr.attr-code eq "weight"
    no-lock no-error.
    if avail buf_marking-attr
    then
      v-mark-weight = dec(buf_marking-attr.attr-value) .
    .
    assign
      buf_utd-lines.Quantity = buf_utd-lines.Quantity + v-mark-weight
    .
  end .
  else do :
    assign
      buf_utd-lines.Quantity = buf_utd-lines.Quantity + v-GTIN-qnty
    .
  end .
  for each buf_marking-child no-lock where buf_marking-child.mark-parent begins v-mark-short,
  first buf_utd-marking-lines-child no-lock where buf_utd-marking-lines-child.mark = buf_marking-child.mark
                                              and buf_utd-marking-lines-child.db-num  = buf_utd-lines.db-num
                                              and buf_utd-marking-lines-child.doc-id  = buf_utd-lines.doc-id
                                              and buf_utd-marking-lines-child.LineNum = buf_utd-lines.LineNum
  :
    assign
      v-GTIN-child = getGtinByDM(buf_marking-child.mark)
      v-GTIN-qnty-child = getQntyCodeByGtin(v-GTIN-child)
      buf_utd-lines.Quantity = buf_utd-lines.Quantity - v-GTIN-qnty-child
    .
  end .
  find first tt-utd-lines exclusive-lock where tt-utd-lines.db-num    = buf_utd.db-num
                                           and tt-utd-lines.doc-id    = buf_utd.doc-id
                                           and tt-utd-lines.gds-code  = buf_goods.gds-code
                                           no-error .
  assign
    tt-utd-lines.Quantity  = buf_utd-lines.Quantity
    tt-utd-lines.qnty-mark = tt-utd-lines.qnty-mark + 1
  .
  if available buf_marking
  then do :
    create buf_utd-marking-lines .
    assign
      buf_utd-marking-lines.mark      = buf_marking.mark
      buf_utd-marking-lines.gds-code  = buf_goods.gds-code
      buf_utd-marking-lines.sts       = buf_marking.sts
      buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
      buf_utd-marking-lines.doc-id    = idoc-id
      buf_utd-marking-lines.db-num    = idb-num
      buf_utd-marking-lines.doc-level = 1
    .
  end .
  else do :
    create buf_marking .
    assign
      buf_marking.mark = v-mark-short
      buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      buf_marking.box-qnty = v-GTIN-qnty
      buf_marking.obj-type = v-cntxt-obj-type
      buf_marking.obj-code = v-cntxt-obj-code
      buf_marking.gds-code = buf_goods.gds-code
      buf_marking.gds-ext-id = v-GTIN
      buf_marking.unit-ext = (if v-GTIN-qnty = 1 then "UNIT" else if v-GTIN-qnty > 1 then "LEVEL1" else "")
    .
    create buf_utd-marking-lines .
    assign
      buf_utd-marking-lines.mark      = buf_marking.mark
      buf_utd-marking-lines.gds-code  = buf_goods.gds-code
      buf_utd-marking-lines.sts       = 0
      buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
      buf_utd-marking-lines.doc-id    = idoc-id
      buf_utd-marking-lines.db-num    = idb-num
      buf_utd-marking-lines.doc-level = 1
    .
  end .
  validate buf_utd-marking-lines .
  return "" .
end.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
   B_mark:POPUP-MENU IN FRAME Dialog-Frame = MENU m_marks:HANDLE.
ASSIGN
   b_mark:MENU-MOUSE = 1.
ASSIGN
       f-msg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
FUNCTION CliName RETURNS CHARACTER
   (input p-cli-code as integer, input p-cli-type as character) :
   define variable v-cli-name as character no-undo .
   find first buf_clients no-lock where buf_clients.obj-code = p-cli-code
      and buf_clients.obj-type = p-cli-type no-error .
   if available (buf_clients) then v-cli-name = buf_clients.obj-name .
   RETURN v-cli-name.
END FUNCTION.
FUNCTION GdsName RETURNS CHARACTER
   ( input p-gds-code as integer) :
   define variable v-gds-name as character no-undo .
   define buffer buf_goods for ub.goods .
   find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
   if available (buf_goods) then v-gds-name = buf_goods.gds-name .
   RETURN v-gds-name.
END FUNCTION.
FUNCTION StatusTHName RETURNS CHARACTER
   (input p-stsTH as integer)  .
   Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  assign a-n-c .
  apply "TAB":U to self .
  return no-apply .
END.
ON VALUE-CHANGED OF is-initial-set IN FRAME Dialog-Frame
DO:
  assign is-initial-set .
END.
ON VALUE-CHANGED OF f-comment IN FRAME Dialog-Frame
DO:
  assign f-comment .
END.
ON return OF f-comment IN FRAME Dialog-Frame
DO:
  define variable v-cursor as integer no-undo .
  define variable v-lines as integer no-undo .
  assign f-comment .
  v-cursor = f-comment:cursor-offset .
  v-lines = num-entries((substring(f-comment, 1, v-cursor - 1)), chr(10)) .
  f-comment = substring(f-comment, 1, v-cursor - v-lines) + chr(10) + substring(f-comment, v-cursor + 1 - v-lines) .
  display f-comment with frame Dialog-Frame .
  f-comment:cursor-offset = v-cursor + 2 .
END.
ON leave, return OF a-n-c-name IN FRAME Dialog-Frame
DO:
  assign a-n-c-name .
  assign a-n-c .
  case a-n-c:
     when "code" then
        do:
           find first X_utd-lines where X_utd-lines.gds-code = integer(a-n-c-name) no-error .
           if available (X_utd-lines) then
           do:
              recid_utd = recid (X_utd-lines) .
              br-utd-lines :refresh() no-error.
              reposition br-utd-lines to recid recid_utd no-error .
           end.
        end.
     when "name" then
        do:
           find first X_utd-lines where (X_utd-lines.GdsName begins a-n-c-name) no-error .
           if available (X_utd-lines) then
           do:
              recid_utd = recid (X_utd-lines) .
              br-utd-lines :refresh() no-error.
              reposition br-utd-lines to recid recid_utd no-error .
           end.
        end.
     when "context" then
        do:
           find first X_utd-lines where (X_utd-lines.GdsName MATCHES "*" + a-n-c-name + "*") no-error .
           if available (X_utd-lines) then
           do:
              recid_utd = recid (X_utd-lines) .
              br-utd-lines :refresh() no-error.
              reposition br-utd-lines to recid recid_utd no-error .
           end.
        end.
  end case.
  apply "TAB":U to self .
  return no-apply .
END.
ON value-changed OF R-error IN FRAME Dialog-Frame
DO:
  assign R-error .
  if r-error = 2 then OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK where X_utd-lines.Quantity < X_utd-lines.free-qnty INDEXED-REPOSITION.                                        else OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK INDEXED-REPOSITION.
END.
ON ENTRY OF v-mark IN FRAME Dialog-Frame
DO:
  run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
  run adm/shattri.p (
           input "get":U
           ,input  v-cntxt-obj-type
           ,input  v-cntxt-obj-code
           ,input  'marking':U
           ,input  'rus-key':U
           ,output p-value-character
           ,output p-value-date
           ,output p-value-decimal
           ,output p-value-integer
           ,output p-value-logical
           ,output p-param-type
           ,input-output table-handle v-tth
           ) no-error .
  IF p-value-logical = yes THEN  iLang = 68748313.
  run ActivateKeyboardLayout (input iLang, input 0).
END.
ON CHOOSE OF menu-item m_marks-lines
DO:
  apply "entry" to br-utd-lines in frame Dialog-Frame.
  if available (X_utd-lines) then
  do:
     recid_utd = recid(X_utd-lines) .
     run temp-mark (input 1) .
     if available (tt-marking-lines) then
     do:
        run str/mark_browse.w (input parparentproc,
           input-output table tt-marking-lines by-reference,
           input p-mode,
           input ("Марки по: Сбор марок " + buf_utd.DocumentNumber + " по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code)),
           input "0",
           input ""
           ) no-error .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-utd-lines :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
        empty temp-table tt-marking-lines .
     end.
     else
     do:
        message "Нет марок"
           view-as alert-box.
     end.
     br-utd-lines :refresh() no-error .
     apply "VALUE-CHANGED" to br-utd-lines in frame Dialog-Frame.
     apply "entry" to br-utd-lines in frame Dialog-Frame.
     reposition br-utd-lines to recid recid_utd no-error .
  end.
  else message "Нет марок"
        view-as alert-box.
  return no-apply .
END.
ON CHOOSE OF menu-item m_marks-utd
DO:
  apply "entry" to br-utd-lines in frame Dialog-Frame.
  recid_utd = recid (X_utd-lines) .
  run temp-mark (input 2) .
  if available (tt-marking-lines) then
  do:
     run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines by-reference,
        input p-mode,
        input "Марки по документу: Сбор марок " + buf_utd.DocumentNumber,
        input "0",
        input ""
        ) no-error .
     empty temp-table tt-marking-lines .
     br-utd-lines:refresh () no-error.
     apply "VALUE-CHANGED" to br-utd-lines in frame Dialog-Frame.
     apply "entry" to br-utd-lines in frame Dialog-Frame.
     reposition br-utd-lines to recid recid_utd no-error .
  end.
  else
  do:
     message "Нет марок по документу"
        view-as alert-box.
  end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
do:
  define buffer bf_utd-lines for ub.utd-lines .
  assign
    is-initial-set
    f-comment
  .
  find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num
                                           and buf_utd-attr.doc-id = buf_utd.doc-id
                                           and buf_utd-attr.attr-code = "is-initial-set"
                                           no-error .
  if not available buf_utd-attr
  then do :
    create buf_utd-attr .
    assign
      buf_utd-attr.db-num = buf_utd.db-num
      buf_utd-attr.doc-id = buf_utd.doc-id
      buf_utd-attr.attr-code = "is-initial-set"
    .
  end .
  assign buf_utd-attr.attr-value = string(is-initial-set) .
  assign buf_utd.comment = trim(f-comment) .
  find first bf_utd-lines no-lock where bf_utd-lines.db-num = buf_utd.db-num
                                    and bf_utd-lines.doc-id = buf_utd.doc-id
                                    no-error .
  if not available bf_utd-lines
  then do :
    message "Документ пустой. Изменения не будут сохранены" view-as alert-box .
    if p-mode <> 'ПРОСМОТР':U
    and available (buf_utd)
    then do:
      delete buf_utd .
    end .
  end .
end.
ON any-printable OF b_del-line IN FRAME Dialog-Frame
DO:
  run proc-any-key.
END.
ON CHOOSE OF b_del-line IN FRAME Dialog-Frame
DO:
  define buffer bf_utd-lines for ub.utd-lines .
  define buffer bf_utd-marking-lines for ub.utd-marking-lines .
  define buffer bf_marking for ub.marking .
  define variable v-auto as logical no-undo .
  if available X_utd-lines
  then do :
    for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = X_utd-lines.db-num
                                            and bf_utd-marking-lines.doc-id = X_utd-lines.doc-id
                                            and bf_utd-marking-lines.LineNum = X_utd-lines.LineNum
                                            and bf_utd-marking-lines.sts = 0
    :
      v-auto = g#auto .
      g#auto = true .
      for each bf_marking exclusive-lock where bf_marking.mark = bf_utd-marking-lines.mark
                                           and bf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      :
        delete bf_marking .
      end.
      g#auto = v-auto .
    end.
    find first bf_utd-lines exclusive-lock where bf_utd-lines.db-num = X_utd-lines.db-num
                                             and bf_utd-lines.doc-id = X_utd-lines.doc-id
                                             and bf_utd-lines.LineNum = X_utd-lines.LineNum
                                             no-error .
    if available bf_utd-lines
    then do :
      delete bf_utd-lines .
    end .
    vLineNum = X_utd-lines.LineNum - 1 .
    delete X_utd-lines .
    for each tt-utd-lines where tt-utd-lines.LineNum > vLineNum,
    first bf_utd-lines exclusive-lock where bf_utd-lines.db-num = tt-utd-lines.db-num
                                        and bf_utd-lines.doc-id = tt-utd-lines.doc-id
                                        and bf_utd-lines.LineNum = tt-utd-lines.LineNum
                                        break by tt-utd-lines.LineNum
    :
      for each bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.db-num = bf_utd-lines.db-num
                                                     and bf_utd-marking-lines.doc-id = bf_utd-lines.doc-id
                                                     and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum
      :
        bf_utd-marking-lines.LineNum = bf_utd-marking-lines.LineNum - 1 .
      end .
      tt-utd-lines.LineNum = tt-utd-lines.LineNum - 1 .
      bf_utd-lines.LineNum = tt-utd-lines.LineNum .
      if last-of(tt-utd-lines.LineNum)
      then do :
        vLineNum = tt-utd-lines.LineNum .
      end .
    end .
    if r-error = 2 then OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK where X_utd-lines.Quantity < X_utd-lines.free-qnty INDEXED-REPOSITION.                                        else OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK INDEXED-REPOSITION.
  end .
  if is-initial-set
  and not is-initial-set:sensitive
  then do :
    assign disable-set = no .
    for each X_utd-lines no-lock where X_utd-lines.db-num = buf_utd.db-num
                                   and X_utd-lines.doc-id = buf_utd.doc-id
    :
      run gdsoattr-value in this-procedure (input   'mark-collect-type':U,
                                            input   X_utd-lines.gds-code,
                                            input   buf_utd.obj-type,
                                            input   buf_utd.obj-code,
                                            output  v-attr-value,
                                            output  v-attr-type
                                            ) no-error.
      if is-initial-set
      and (v-attr-value = "" or v-attr-value = "0")
      then do :
        assign disable-set = yes .
        leave .
      end .
    end .
    if not disable-set then enable is-initial-set with frame Dialog-Frame .
  end .
END.
ON any-printable OF b_prov-finish IN FRAME Dialog-Frame
DO:
  run proc-any-key.
END.
ON CHOOSE OF b_prov-finish IN FRAME Dialog-Frame
DO:
  define variable v-ok        as logical no-undo .
  define buffer bf_utd-marking-lines for ub.utd-marking-lines .
  define buffer bf2_utd-marking-lines for ub.utd-marking-lines .
  define buffer bf_utd-lines-attr    for ub.utd-lines-attr .
  define buffer bf_utd-lines         for ub.utd-lines .
  define buffer bf_marking           for ub.marking .
  define buffer bf_marking-parent    for ub.marking .
  define variable vPawd as character no-undo.
  assign
    is-initial-set
    f-comment
  .
  find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num
                                           and buf_utd-attr.doc-id = buf_utd.doc-id
                                           and buf_utd-attr.attr-code = "is-initial-set"
                                           no-error .
  if not available buf_utd-attr
  then do :
    create buf_utd-attr .
    assign
      buf_utd-attr.db-num = buf_utd.db-num
      buf_utd-attr.doc-id = buf_utd.doc-id
      buf_utd-attr.attr-code = "is-initial-set"
    .
  end .
  assign buf_utd-attr.attr-value = string(is-initial-set) .
  assign buf_utd.comment = trim(f-comment) .
  find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = buf_utd.db-num
                                            and bf_utd-marking-lines.doc-id = buf_utd.doc-id
                                            no-error .
  if not available (bf_utd-marking-lines)
  then do:
    message "Документ пустой. Завершить его обработку невозможно"
      view-as alert-box.
    return no-apply .
  end.
  v-ok = yes .
  for first X_utd-lines where X_utd-lines.Quantity < X_utd-lines.free-qnty:
    v-ok = no .
  end.
  if not v-ok
  then do:
    message "Документ содержит товары, по которым количество просканированных марок меньше остатков в системе (выделены красным в интерфейсе). Продолжить закрытие документа?"
    view-as alert-box question buttons yes-no update v-ok .
  end .
  if not v-ok
  then
    return no-apply .
  run adm\ask-pswd.w ("Введите пароль пользователя, осуществляющего закрытие сбора марок, с целью подтверждения внесенных фактических остатков марок на АЗК.",output vPawd).
  if  vPawd eq ?
  then
    return no-apply .
  If vPawd ne encode(g#passwd)
  then do:
    message "Введен неправильный пароль" view-as alert-box .
    return no-apply .
  end.
  run waitfram-show in this-procedure (input "ЖДИТЕ...") .
  for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = buf_utd.db-num
                                          and bf_utd-marking-lines.doc-id  = buf_utd.doc-id
                                          and bf_utd-marking-lines.site   <> "only-send",
  first bf_marking no-lock where bf_marking.mark = bf_utd-marking-lines.mark
  :
    if bf_marking.mark-parent > ""
    then do :
      for first bf_marking-parent no-lock where bf_marking-parent.mark = bf_marking.mark-parent :
        if bf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
        or bf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB
        then do :
          if not can-find (first bf2_utd-marking-lines where bf2_utd-marking-lines.db-num  = bf_utd-marking-lines.db-num
                                                         and bf2_utd-marking-lines.doc-id  = bf_utd-marking-lines.doc-id
                                                         and bf2_utd-marking-lines.LineNum = bf_utd-marking-lines.LineNum
                                                         and bf2_utd-marking-lines.mark    = bf_marking-parent.mark
                                                         and bf2_utd-marking-lines.site   <> "only-send"
                                                         no-lock)
          then do :
            find current bf_marking-parent exclusive-lock .
            assign bf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB .
          end .
        end .
      end .
    end .
  end .
  for each bf_utd-lines no-lock where bf_utd-lines.db-num = buf_utd.db-num
                                  and bf_utd-lines.doc-id = buf_utd.doc-id,
  first buf_goods no-lock where buf_goods.gds-code = bf_utd-lines.gds-code
  :
    for each bf_marking no-lock where bf_marking.gds-code = bf_utd-lines.gds-code :
      if not can-find (first bf_utd-marking-lines where bf_utd-marking-lines.db-num  = bf_utd-lines.db-num
                                                    and bf_utd-marking-lines.doc-id  = bf_utd-lines.doc-id
                                                    and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum
                                                    and bf_utd-marking-lines.mark    = bf_marking.mark
                                                    and bf_utd-marking-lines.site   <> "only-send"
                                                    no-lock)
      and bf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      then do :
        find current bf_marking exclusive-lock .
        assign bf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB .
        find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = bf_utd-lines.db-num
                                                  and bf_utd-marking-lines.doc-id  = bf_utd-lines.doc-id
                                                  and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum
                                                  and bf_utd-marking-lines.mark    = bf_marking.mark
                                                  no-error .
        if not available bf_utd-marking-lines
        then do :
          create bf_utd-marking-lines .
          assign
            bf_utd-marking-lines.db-num    = bf_utd-lines.db-num
            bf_utd-marking-lines.doc-id    = bf_utd-lines.doc-id
            bf_utd-marking-lines.LineNum   = bf_utd-lines.LineNum
            bf_utd-marking-lines.mark      = bf_marking.mark
            bf_utd-marking-lines.gds-code  = bf_utd-lines.gds-code
            bf_utd-marking-lines.sts       = bf_marking.sts
            bf_utd-marking-lines.doc-level = 1
            bf_utd-marking-lines.site      = "only-send"
          .
        end .
      end .
    end .
    if is-initial-set
    then do :
      run gdsoattr-value in this-procedure (input   'mark-collect-type':U,
                                            input   bf_utd-lines.gds-code,
                                            input   buf_utd.obj-type,
                                            input   buf_utd.obj-code,
                                            output  v-attr-value,
                                            output  v-attr-type
                                            ) no-error.
      if v-attr-value = ""
      or v-attr-value = "0"
      then do:
        run gdsoattr-write (input bf_utd-lines.gds-code,
                            input buf_utd.obj-type,
                            input buf_utd.obj-code,
                            input 'mark-collect-type':U,
                            input "1"
                            ).
      end.
    end .
    else do :
      run gdsoattr-write (input bf_utd-lines.gds-code,
                          input buf_utd.obj-type,
                          input buf_utd.obj-code,
                          input 'mark-collect-type':U,
                          input "2"
                          ).
    end .
    find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                     and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                     and buf_gds-obj.artic     = buf_goods.artic
                                     and buf_gds-obj.prod-type = buf_goods.prod-type
                                     and buf_gds-obj.prod-code = buf_goods.prod-code
                                     no-error .
    find first X_utd-lines no-lock where bf_utd-lines.doc-id = X_utd-lines.doc-id
                                     and bf_utd-lines.db-num = X_utd-lines.db-num
                                     and bf_utd-lines.LineNum = X_utd-lines.LineNum
                                     no-error .
    find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.doc-id = bf_utd-lines.doc-id
                                                   and buf_utd-lines-attr.db-num = bf_utd-lines.db-num
                                                   and buf_utd-lines-attr.LineNum = bf_utd-lines.LineNum
                                                   and buf_utd-lines-attr.attr-code = "comfimed-free-qnty"
                                                   no-error .
    if not available buf_utd-lines-attr
    then do :
      create buf_utd-lines-attr .
      assign
        buf_utd-lines-attr.doc-id = bf_utd-lines.doc-id
        buf_utd-lines-attr.db-num = bf_utd-lines.db-num
        buf_utd-lines-attr.LineNum = bf_utd-lines.LineNum
        buf_utd-lines-attr.attr-code = "comfimed-free-qnty"
      .
    end .
    if available buf_gds-obj
    then do :
      assign buf_utd-lines-attr.attr-value = string(buf_gds-obj.free-qnty) .
    end .
    else
    if available X_utd-lines
    then do :
      assign buf_utd-lines-attr.attr-value = string(X_utd-lines.free-qnty) .
    end .
  end .
  if is-initial-set
  then do :
    for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = buf_utd.db-num
                                            and bf_utd-marking-lines.doc-id  = buf_utd.doc-id
                                            and bf_utd-marking-lines.site   <> "only-send",
    first bf_marking no-lock where bf_marking.mark = bf_utd-marking-lines.mark
    :
      if bf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB
      then do :
        find current bf_marking exclusive-lock .
        assign bf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
      end .
    end .
  end .
  assign buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB .
  validate buf_utd .
  run waitfram-hide in this-procedure .
  apply "choose" to b-exit in frame Dialog-Frame .
END.
ON VALUE-CHANGED OF c-status IN FRAME Dialog-Frame
DO:
  assign c-status .
  if c-type = 0 then
  do:
    message "Укажите тип документа"
      view-as alert-box.
  end.
  buf_utd.sts = integer(c-status).
  validate buf_utd no-error.
  c-status = buf_utd.sts.
  display c-status with frame Dialog-Frame .
END.
ON VALUE-CHANGED OF c-type IN FRAME Dialog-Frame
DO:
  assign c-type .
  if available (buf_utd) then buf_utd.EDocType = c-type .
  F-msg = "                            Просканируйте марку" .
  display F-msg with frame Dialog-Frame .
  run enable_UI .
END.
ON leave OF f-date IN FRAME Dialog-Frame
DO:
    assign f-date .
    if f-num:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> ? then do:
        find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date
            and (ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB)no-error .
        if AVAILABLE (ub.utd) then
        do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
                VIEW-AS ALERT-BOX.
            return NO-APPLY .
        end.
    end.
    display f-date with frame Dialog-Frame .
END.
ON RETURN OF f-date IN FRAME Dialog-Frame
DO:
  apply "TAB":U to self .
  return no-apply .
END.
ON TAB OF f-date IN FRAME Dialog-Frame
DO:
    assign f-date .
    display f-date with frame Dialog-Frame .
END.
ON leave OF f-num IN FRAME Dialog-Frame
DO:
    assign f-num .
    if f-date:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> "" then do:
        find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date
            and (ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB)no-error .
        if AVAILABLE (ub.utd) then
        do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
                VIEW-AS ALERT-BOX.
            return NO-APPLY .
        end.
    end.
    display f-num with frame Dialog-Frame .
END.
ON ROW-DISPLAY OF br-utd-lines IN FRAME Dialog-Frame
DO:
  if available X_utd-lines
  then do :
    if buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
    then do :
      find first buf_goods no-lock where buf_goods.gds-code = X_utd-lines.gds-code .
      find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                       and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                       and buf_gds-obj.artic     = buf_goods.artic
                                       and buf_gds-obj.prod-type = buf_goods.prod-type
                                       and buf_gds-obj.prod-code = buf_goods.prod-code
                                       no-error .
      if available buf_gds-obj
      then do :
        if buf_gds-obj.free-qnty <> X_utd-lines.free-qnty
        then do :
          assign X_utd-lines.free-qnty = buf_gds-obj.free-qnty .
        end .
      end .
    end .
    if X_utd-lines.Quantity < X_utd-lines.free-qnty
    then do :
      assign
        X_utd-lines.LineNum     :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.gds-code    :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.GdsName     :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.UnitCode    :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.Quantity    :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.free-qnty   :fGCOLOR in browse br-utd-lines = red_COLOR
      .
    end .
  end .
END .
ON value-changed OF f-num IN FRAME Dialog-Frame
DO:
  assign f-num .
  display f-num with frame Dialog-Frame .
END.
ON CHOOSE OF r-obj-TH IN FRAME Dialog-Frame
DO:
END.
ON any-printable OF v-mark IN FRAME Dialog-Frame
do:
  run proc-any-key.
end.
ON ENTRY OF v-mark IN FRAME Dialog-Frame
DO:
    run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
    run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
    IF p-value-logical = yes THEN  iLang = 68748313.
    run ActivateKeyboardLayout (input iLang, input 0).
  END.
ON LEAVE OF v-mark IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame v-mark .
END.
ON MOUSE-SELECT-DBLCLICK OF v-mark IN FRAME Dialog-Frame
DO:
    run save_update .
END.
ON return OF v-mark IN FRAME Dialog-Frame
DO:
    run save_update .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
do:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  if p-mode = 'ДОБАВЛЕНИЕ':U and available (buf_utd) then
  do:
     delete buf_utd .
  end.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
do trans ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign v-num-str = 0 .
  Marking = ObjSrv:Env:Marking:Sts:Mark .
  run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
  run adm/shattri.p (
           input "get":U
           ,input  v-cntxt-obj-type
           ,input  v-cntxt-obj-code
           ,input  'marking':U
           ,input  'rus-key':U
           ,output p-value-character
           ,output p-value-date
           ,output p-value-decimal
           ,output p-value-integer
           ,output p-value-logical
           ,output p-param-type
           ,input-output table-handle v-tth
           ) no-error .
  IF p-value-logical = yes THEN  iLang = 68748313.
  run ActivateKeyboardLayout (input iLang, input 0).
  if p-mode = 'ДОБАВЛЕНИЕ':U then
  do:
    if not available (buf_utd) then
    do:
      create buf_utd .
      assign
        buf_utd.DocumentDate = today
        buf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
        buf_utd.obj-code     = v-cntxt-obj-code
        buf_utd.obj-type     = v-cntxt-obj-type
        buf_utd.host-code    = v-cntxt-host-code-obj
        buf_utd.EDocType     = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
      .
      validate buf_utd .
      assign buf_utd.DocumentNumber = string(buf_utd.doc-id) + "-" + string(v-cntxt-obj-code) + substring(v-cntxt-obj-type,1,1) .
    end.
  end.
  else
  do:
    if p-mode = 'ПРОСМОТР':U then find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
    if p-mode = 'ИЗМЕНЕНИЕ':U then find first buf_utd exclusive-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-wait no-error .
    if  error-status:error then
    do:
      message "Документ занят другим пользователем"
      view-as alert-box.
      p-mode = 'ПРОСМОТР':U .
      find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
    end.
  end.
  if available (buf_utd) then
  do:
    assign
      f-num          = buf_utd.DocumentNumber
      f-date         = buf_utd.DocumentDate
      c-status       = buf_utd.sts
      f-obj-code-TH  = buf_utd.obj-code
      f-obj-type-TH  = buf_utd.obj-type
      f-obj-name-TH  = CliName(buf_utd.obj-code, buf_utd.obj-type)
      c-type         = buf_utd.EDocType
      f-comment      = buf_utd.comment
    .
    assign
      frame Dialog-Frame:title = "Сбор марок_____№ " + string (buf_utd.DocumentNumber) + "_____" + p-mode
    .
  end .
  find first buf_utd-attr no-lock where buf_utd-attr.db-num = buf_utd.db-num
                                    and buf_utd-attr.doc-id = buf_utd.doc-id
                                    and buf_utd-attr.attr-code = "is-initial-set"
                                    no-error .
  if available buf_utd-attr
  then do :
    assign is-initial-set = logical(buf_utd-attr.attr-value) no-error .
  end .
  assign vLineNum = 0 .
  for each buf_utd-lines no-lock where buf_utd-lines.doc-id = buf_utd.doc-id
                                   and buf_utd-lines.db-num = buf_utd.db-num,
  first buf_goods no-lock where buf_goods.gds-code = buf_utd-lines.gds-code
  :
    assign vLineNum = max(vLineNum, buf_utd-lines.LineNum) .
    find first X_utd-lines EXCLUSIVE-LOCK where buf_utd-lines.doc-id = X_utd-lines.doc-id
                                            and buf_utd-lines.db-num = X_utd-lines.db-num
                                            and buf_utd-lines.LineNum = X_utd-lines.LineNum
                                            no-error .
    buffer-copy buf_utd-lines to X_utd-lines .
    assign X_utd-lines.GdsName = buf_goods.gds-name .
    if buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB
    then do :
      find first buf_utd-lines-attr no-lock where buf_utd-lines-attr.doc-id = buf_utd-lines.doc-id
                                              and buf_utd-lines-attr.db-num = buf_utd-lines.db-num
                                              and buf_utd-lines-attr.LineNum = buf_utd-lines.LineNum
                                              and buf_utd-lines-attr.attr-code = "comfimed-free-qnty"
                                              no-error .
      if available buf_utd-lines-attr
      then do :
        assign X_utd-lines.free-qnty = decimal(buf_utd-lines-attr.attr-value) .
      end .
    end .
    else do :
      find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                       and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                       and buf_gds-obj.artic     = buf_goods.artic
                                       and buf_gds-obj.prod-type = buf_goods.prod-type
                                       and buf_gds-obj.prod-code = buf_goods.prod-code
                                       no-error .
      if available buf_gds-obj
      then do :
        assign X_utd-lines.free-qnty = buf_gds-obj.free-qnty .
      end .
    end .
    for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                             and buf_utd-marking-lines.db-num   = buf_utd-lines.db-num
                                             and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum
                                             and buf_utd-marking-lines.doc-level = 1
                                             and buf_utd-marking-lines.site    <> "only-send"
    :
      assign X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1 .
    end .
    if not disable-set
    then do :
      run gdsoattr-value in this-procedure (input   'mark-collect-type':U,
                                            input   buf_goods.gds-code,
                                            input   buf_utd.obj-type,
                                            input   buf_utd.obj-code,
                                            output  v-attr-value,
                                            output  v-attr-type
                                            ) no-error.
      if is-initial-set
      and (v-attr-value = "" or v-attr-value = "0")
      then do :
        assign disable-set = yes .
      end .
    end .
  end .
  RUN enable_UI.
  display
    F-msg
    f-num
    f-date
    c-type
    c-status
    f-obj-code-TH
    f-obj-type-TH
    f-obj-name-TH
    f-comment
    is-initial-set
  with frame Dialog-Frame.
  apply "entry" to v-mark in FRAME Dialog-Frame.
  enable v-mark with frame Dialog-Frame.
  on F9 of frame Dialog-Frame anywhere
  do:
    if not available X_utd-lines then  return no-apply.
    find first goods no-lock where goods.gds-code = X_utd-lines.gds-code .
    gds-rec = recid(goods) .
    run ref/gds-form.w
        (input  parParentProc
        ,input  'ПРОСМОТР':U
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input ?
        ,input-output gds-rec
        ).
    apply "entry" to br-utd-lines in frame Dialog-Frame.
    return no-apply.
  end.
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsManual
  then v-manual = yes.
  else do:
    v-manual = no .
    v-mark:READ-ONLY IN FRAME Dialog-Frame = TRUE .
  end.
  if p-mode = 'ПРОСМОТР':U
  then do :
    disable v-mark b-exit b_prov-finish b_del-line is-initial-set with frame Dialog-Frame.
    f-comment:read-only = yes .
  end .
  if disable-set then disable is-initial-set with frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame focus v-mark .
END.
RUN disable_UI.
PROCEDURE ActivateKeyboardLayout external "user32" :
define input parameter P1 as LONG.
   define input parameter P2 as LONG.
END PROCEDURE.
PROCEDURE CrCheckMark :
  define variable vmes as character no-undo.
  vmes = CrCheckMarkDoc(v-cntxt-obj-type, v-cntxt-obj-code,
                 buf_utd.db-num, buf_utd.doc-id,
                 v-mark:screen-value in frame Dialog-Frame,
                 is-initial-set).
   if vmes ne ""
   then
      run dispmessage (vmes).
  end.
PROCEDURE temp-mark :
   define input parameter p-id as integer no-undo .
   define buffer buf_marking for ub.marking .
   empty temp-table tt-marking-lines .
   define variable mQuery as handle    no-undo.
   define variable vqry   as character no-undo.
   define variable vsite  as character no-undo.
   vsite = " and buf_utd-marking-lines.site <> 'only-send'" .
   create query mQuery.
   mQuery:set-buffers(buffer buf_utd-marking-lines:HANDLE).
   vqry = substitute("for each buf_utd-marking-lines no-lock where ~
                               buf_utd-marking-lines.db-num = &1 ~
                           and buf_utd-marking-lines.doc-id = &2 "
                           ,  buf_utd.db-num, buf_utd.doc-id, vsite).
   if p-id = 1
   then
      vqry = vqry + substitute (" and buf_utd-marking-lines.LineNum = &1",X_utd-lines.LineNum).
    mQuery:query-prepare(vqry + vsite).
    mQuery:query-open ().
    mQuery:get-first ().
    do while not mQuery:query-off-end:
       create tt-marking-lines .
       assign
          tt-marking-lines.gds-name  = GdsName(buf_utd-marking-lines.gds-code)
          tt-marking-lines.stts-utd  = StatusTHName(buf_utd-marking-lines.sts)
          tt-marking-lines.mark      = buf_utd-marking-lines.mark
          tt-marking-lines.gds-code  = buf_utd-marking-lines.gds-code
          tt-marking-lines.sts-utd   = buf_utd-marking-lines.sts
          tt-marking-lines.LineNum   = buf_utd-marking-lines.LineNum
          tt-marking-lines.db-num    = buf_utd-marking-lines.db-num
          tt-marking-lines.doc-id    = buf_utd-marking-lines.doc-id
          tt-marking-lines.doc-level = buf_utd-marking-lines.doc-level
          tt-marking-lines.site      = buf_utd-marking-lines.site
       .
       tt-marking-lines.isMark    = IsMark(tt-marking-lines.mark).
       find first utd-marking-lines-attr where utd-marking-lines-attr.doc-id    eq buf_utd-marking-lines.doc-id
                                           and utd-marking-lines-attr.db-num    eq buf_utd-marking-lines.db-num
                                           and utd-marking-lines-attr.LineNum   eq buf_utd-marking-lines.LineNum
                                           and utd-marking-lines-attr.mark      eq buf_utd-marking-lines.mark
                                           and utd-marking-lines-attr.attr-code eq "box-qnty"
       no-lock no-error.
       if avail utd-marking-lines-attr
       then
          tt-marking-lines.box-qnty = dec(utd-marking-lines-attr.attr-value).
       if tt-marking-lines.isMark then
       do:
          for first buf_marking  where buf_marking.mark begins buf_utd-marking-lines.mark :
             assign
                tt-marking-lines.sts         = buf_marking.sts
                tt-marking-lines.unit        = buf_marking.unit
                tt-marking-lines.unit-ext    = buf_marking.unit-ext
                tt-marking-lines.box-qnty    = buf_marking.box-qnty  when tt-marking-lines.box-qnty eq 0 or tt-marking-lines.box-qnty eq ?
                tt-marking-lines.mark-parent = buf_marking.mark-parent
             .
             tt-marking-lines.stts        = StatusTHName(buf_marking.sts).
          end.
       end.
       else
       do:
          tt-marking-lines.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
       end.
      mQuery:get-next ().
   end.
   delete object mQuery.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE dispmessage :
define input parameter p-str as character no-undo.
  f-msg:fgcolor in frame Dialog-Frame = 12.
  do:
    display p-str @ f-msg with frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY c-type f-num-name f-num f-date-name f-date is-initial-set
          f-obj-type-TH f-obj-code-TH f-obj-name-TH f-status-TH c-status
          f-comment f-comment-name v-mark a-n-c a-n-c-name
          f-msg R-error
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-exit B_mark
         is-initial-set R-error
         f-comment v-mark a-n-c a-n-c-name
         br-utd-lines b_prov-finish b_del-line
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if r-error = 2 then OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK where X_utd-lines.Quantity < X_utd-lines.free-qnty INDEXED-REPOSITION.                                        else OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE LoadKeyboardLayoutA external "user32" :
define input  parameter P1 as char.
  define input  parameter P2 as LONG.
  define return parameter pret as LONG.
end procedure.
PROCEDURE proc-any-key :
if not v-manual
    then
    if v-scan-str = ""
      then etime(yes).
    else
      if etime > 700
        then v-scan-str = "".
  v-scan-str = v-scan-str + last-event:label.
end.
PROCEDURE save_update :
define variable v-error      as logical   no-undo init no.
  define variable l-error      as logical   no-undo init no.
  define variable v-error-lang as logical   no-undo init no.
  define variable v_list    as character no-undo .
  define variable ii           as integer   no-undo .
  define variable chg-qnty     as integer   no-undo .
  do trans:
    f-msg:screen-value in frame Dialog-Frame = "" .
    if v-mark:screen-value in frame Dialog-Frame = ""
    then do:
      v-mark:screen-value in frame Dialog-Frame = v-scan-str.
      v-scan-str = "".
    end.
    assign
      v-mark = v-mark:screen-value in frame Dialog-Frame.
    if v-mark = ""
      then return.
    assign v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
    do ii = 1 to length (v-mark):
      if lookup(substring(v-mark, ii, 1), v_list) > 1
      then do:
        message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
        view-as alert-box.
        v-mark:screen-value in frame Dialog-Frame = "" .
        v-mark = "" .
        return .
      end.
    end.
    run CrCheckMark.
    if r-error = 2 then OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK where X_utd-lines.Quantity < X_utd-lines.free-qnty INDEXED-REPOSITION.                                        else OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK INDEXED-REPOSITION.
    v-mark = "".
    v-mark:screen-value in frame Dialog-Frame = "".
    v-mark-short = "".
  end.
end procedure.
