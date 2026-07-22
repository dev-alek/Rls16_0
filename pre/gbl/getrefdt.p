block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-reference as character no-undo .
define input-output parameter p-date as date no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getrefdt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getrefdt.p $":U .
define variable vss-description as character no-undo init "Получение даты по выбору сущностей из различных справочников".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-rid-list as character no-undo .
define variable v-mode as character no-undo .
define variable v-code-schet as integer no-undo .
define variable v-curr-code as integer no-undo .
do
on error undo, return error
:
  message p-reference view-as alert-box .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  case entry(1, p-reference, chr(4) ):
    when "finsttms" then do:
       if entry(2, p-reference, chr(4)) = "ext-type-stat-start" then do:
         assign
         v-mode = "ext-type-stat-start"
         v-code-schet = 0
         v-curr-code = ?
         .
       end.
       if entry(2, p-reference, chr(4)) =  "ext-type-stat-end"
       or entry(2, p-reference, chr(4)) =  "ext-type-stat-end1"
       then do:
         assign
         v-mode = "ext-type-stat-end"
         v-code-schet = 0
         v-curr-code = ?
         .
       end.
       if entry(2, p-reference, chr(4)) = "code-schet-end":U
       or entry(2, p-reference, chr(4)) = "code-schet-start":U
       or entry(2, p-reference, chr(4)) = "code-schet-end1":U then do:
         assign
         v-mode = "code-schet"
         v-code-schet = integer(entry(3, p-reference, chr(4)))
         v-curr-code = ?
         .
       end.
       if entry(2, p-reference, chr(4)) = "currency-start":U
       or entry(2, p-reference, chr(4)) = "currency-end":U
       or entry(2, p-reference, chr(4)) = "currency-end1":U then do:
         assign
         v-mode = "currency"
         v-code-schet = 0
         v-curr-code = integer(entry(3, p-reference, chr(4)))
         .
       end.
      define buffer buf_fin-statement for ub.fin-statement.
      run ref/finsttms.w (
                     input parparentproc
                    ,input v-cntxt-host-code-obj
                    ,input "b-sel":U
                    ,input v-mode
                    ,input v-cntxt-host-code-obj
                    ,input 'факт':U
                    ,input 'стд':U
                    ,input 'стд':U
                    ,input ?
                    ,input ?
                    ,input 0
                    ,input v-code-schet
                    ,input v-curr-code
                    ,input-output v-rid-list) no-error .
      if v-rid-list = '':U then return.
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(v-rid-list) no-error.
      if available buf_fin-statement then do:
        if entry(2, p-reference, chr(4)) = "ext-type-stat-start"
        or entry(2, p-reference, chr(4)) = "code-schet-start"
        or entry(2, p-reference, chr(4)) = "currency-start"
        then do:
          assign
          p-date = buf_fin-statement.start-date.
        end.
        if entry(2, p-reference, chr(4)) = "ext-type-stat-end"
        or entry(2, p-reference, chr(4)) = "code-schet-end"
        or entry(2, p-reference, chr(4)) = "currency-end"
        then do:
          assign
          p-date = buf_fin-statement.end-date.
        end.
        if entry(2, p-reference, chr(4)) = "ext-type-stat-end1"
        or entry(2, p-reference, chr(4)) = "code-schet-end1"
        or entry(2, p-reference, chr(4)) = "currency-end1"
        then do:
          assign
          p-date = buf_fin-statement.end-date + 1.
        end.
      end.
    end.
    otherwise do:
      message
      substitute("Не определен или неверно определен справочник &1 для выбора даты", p-reference)
      view-as alert-box error .
      return .
    end.
  end case.
end.
