using ibs.th.bge.egais.*.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа с остатками ЕГАИС".
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
FUNCTION Base2Int64 RETURNS INT64 ( INPUT i-hex AS CHARACTER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE j_num AS INT64 NO-UNDO.
  RUN conv-base-to-int64 IN THIS-PROCEDURE ( INPUT i-hex, INPUT i-base, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION.
PROCEDURE conv-base-to-int64 :
  DEFINE  INPUT PARAMETER p-num  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int  AS INT64     NO-UNDO.
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_sign AS INT64   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-int = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                    'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           v_list = SUBSTRING( v_list, 1, p-base * 2 - 1 )
           p-num  = TRIM( p-num ).
    IF SUBSTRING( p-num, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-num  = SUBSTRING( p-num, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-num ) :
      ASSIGN p-int = p-int * p-base + LOOKUP( SUBSTRING( p-num, jj, 1 ), v_list ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END.
END PROCEDURE.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info7 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info7, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info7, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info7 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info7, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info7, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info7, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info7, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info7, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info7, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info7, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define stream OutStr-html.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define temp-table tt-gds-rests no-undo
    field gds-code          like ub.goods.gds-code          label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field ms-base           like ub.goods.ms-base           label "Объем"               format ">>9.9<<"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field proof             like ub.goods.proof             label "Крепость"            format ">9.9"
    field fromEgais         as logical
    field egais-name        as character                    label "Наименование ЕГАИС"  format "X(100)"
    field egais-qnty        as decimal                      label "Остаток ЕГАИС"
    field informA_          as character                    label "ID справки А"        format "X(30)"
    field informB_          as character                    label "ID справки Б"        format "X(30)"
    field TH-qnty           as decimal                      label "Остаток TH"
    field prt-rec           as character
    field packed            as logical
    index pi as primary
        gds-code
    index name_ as word-index
        gds-name
    index alc
        alc-code
.
define buffer old_tt-gds-rests for tt-gds-rests .
define temp-table tt-gds-rests_shop no-undo
    field gds-code          as character                    label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field ms-base           like ub.goods.ms-base           label "Объем"               format ">>9.9<<"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field proof             like ub.goods.proof             label "Крепость"            format ">9.9"
    field fromEgais         as logical
    field egais-name        as character                    label "Наименование ЕГАИС"  format "X(100)"
    field egais-qnty        as decimal                      label "Остаток маг"
    field TH-qnty           as decimal                      label "Остаток TH"
    field prt-rec           as character
    field packed            as logical
    field egais-qnty_stock  as decimal                      label "Остаток скл"
    field in-list           as logical
    index pi as primary
        gds-code
    index name_ as word-index
        gds-name
    index alc
        alc-code
.
define buffer old_tt-gds-rests_shop for tt-gds-rests_shop .
define temp-table tt-compare-rests no-undo
    field gds-code          as character                    label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field TH-qnty           as decimal                      label "Остаток TH"
    field shop-qnty         as decimal                      label "Остаток маг"
    field stock-qnty        as decimal                      label "Остаток скл"
    index pi as primary
        alc-code
    index gds
        gds-code
.
define temp-table tt-marks-compare-rests no-undo
    field gds-code          like ub.goods.gds-code          label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field TH-qnty           as decimal                      label "Остаток TH"
    field shop-qnty         as decimal                      label "Остаток маг"
    field stock-qnty        as decimal                      label "Остаток скл"
    field marks-qnty        as integer                      label "Кол-во марок"
    field gds-codes         as character
    index pi as primary
        alc-code
    index gds
        gds-code
.
define temp-table tt-marks-qnty
    field alc-code  as character                    label "Алкогольный код"     format "X(21)"
    field qnty      as integer                      label "Кол-во марок"
    index pi as primary
        alc-code
.
define temp-table tt-gds-list no-undo
    field alc-code      as character
    field gds-code      as character
    index pi as primary unique
        alc-code gds-code
.
define temp-table tt-obj-list no-undo
    field obj-type as character
    field obj-code as integer
    field inn like ub.firm.inn
    index pi as primary unique
        obj-type obj-code
.
def var rests as class Rests.
def var rests_shop as class Rests_Shop.
def var bh-gds-egais as handle no-undo .
def var qh-gds-egais as handle no-undo .
def var bh-gds-egais_shop as handle no-undo .
def var qh-gds-egais_shop as handle no-undo .
define buffer buf_firm for ub.firm .
define buffer buf_clients for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
define buffer buf_goods for ub.goods .
define buffer buf_goods-attr for ub.goods-attr .
define buffer buf_parts for ub.parts .
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.
define variable v-section-names as character no-undo.
define variable v-page-current as integer no-undo.
define variable v-page as integer no-undo.
define variable iTemp as integer no-undo.
  DEFINE VARIABLE up-image             AS HANDLE NO-UNDO.
  DEFINE VARIABLE tab-type          AS INT NO-UNDO.
  DEFINE VARIABLE char-hdl             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE page-label           AS HANDLE EXTENT 2 NO-UNDO.
  DEFINE VARIABLE image-hdl            AS HANDLE EXTENT 2 NO-UNDO.
  DEFINE VARIABLE page-enabled         AS LOGICAL EXTENT 2 NO-UNDO.
  DEFINE VARIABLE pos-x             AS integer NO-UNDO init 5.
  DEFINE VARIABLE pos-y             AS integer NO-UNDO init 110.
  DEF VAR width-tab-values    AS INT INIT [110,72] EXTENT 2 NO-UNDO.
  DEFINE VARIABLE        number-of-pages    AS INTEGER   NO-UNDO.
define variable select-list as longchar  no-undo .
define variable select-list_shop as longchar  no-undo .
define variable v-sel-entry as character no-undo .
define variable goods-list  as longchar  no-undo .
define variable ref-list    as character no-undo .
define variable ii          as integer   no-undo .
define variable jj          as integer   no-undo .
define variable v-rid       as recid     no-undo .
define variable v-prt-rec   as recid     no-undo .
define variable par-alcohol as character no-undo .
define variable par-egais-name as character no-undo .
define variable par-type    as character no-undo .
define variable v-kpp       as character no-undo .
define variable v-org-inn   as character no-undo .
define variable v-isSent    as logical   no-undo .
define variable v-outId     as character no-undo .
define variable v-ext-sys   as integer   no-undo .
define variable v-replyId   as character no-undo .
define variable glog        as logical no-undo .
define variable v-gds-uniq-key-rec as character no-undo .
define variable saved as logical no-undo initial no .
define variable gds-rec as recid no-undo .
define variable tt-rec as recid no-undo .
define variable tt-row as rowid no-undo .
define variable tt-row2 as rowid no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-org as character no-undo .
define variable v-fs-rar as character no-undo .
define variable v-fs-rar-list as character no-undo .
define variable v-num-loads as integer no-undo .
define variable v-num-objs as integer no-undo .
define variable v-fn-rests as character no-undo .
define variable v-fn-rests_shop as character no-undo .
define variable v-DT-rests as character no-undo
    view-as text format "X(20)" label "Дата и время" .
define variable v-DT-rests_shop as character no-undo
    view-as text format "X(20)" label "Дата и время" .
define stream str-err .
define variable bh-act-header  as handle no-undo .
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field type_         as character        label "Основание списания" format "X(18)"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-B      as character                label "Справка Б"               format "X(20)"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        num position_
    index code
        gds-code
.
define   temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)"
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)"
    field flag                as logical              label "T"
    index pi as primary unique
        mark
.
define variable sw as handle no-undo .
define variable v-file              as character no-undo initial "ActWriteOff1.xml".
DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.
procedure makeXML :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOff") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) no-error .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) no-error .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) no-error .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) no-error .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) no-error .
                        sw:write-data-element ("gds-code", string(tt-gds-act.gds-code)) no-error .
                        sw:write-data-element ("gds-name", tt-gds-act.gds-name) no-error .
                        sw:write-data-element ("alc-code", tt-gds-act.alc-code) no-error .
                        sw:start-element ("awr:InformB") .
                            sw:write-data-element ("pref:BRegId", tt-gds-act.inform-B) no-error .
                        sw:end-element ("awr:InformB") .
                        sw:start-element ("awr:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("awr:MarkCode", tt-marks.mark) .
            end.
                        sw:end-element ("awr:MarkCodeInfo") .
                    sw:end-element ("awr:Position") .
    end.
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOff") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure makeXMLegais :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOff") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 or trim(tt-gds-act.inform-B) = "" or tt-gds-act.inform-B = ? then next.
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("awr:InformB") .
                            sw:write-data-element ("pref:BRegId", tt-gds-act.inform-B) .
                        sw:end-element ("awr:InformB") .
                    sw:end-element ("awr:Position") .
    end.
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOff") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure makeXMLegais_v2 :
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff_v2") .
    sw:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw:start-element ("ns:Owner") .
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") .
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOff_v2") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 or trim(tt-gds-act.inform-B) = "" or tt-gds-act.inform-B = ? then next.
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("awr:InformF1F2") .
                          sw:start-element ("awr:InformF2") .
                            sw:write-data-element ("pref:F2RegId", tt-gds-act.inform-B) .
                          sw:end-element ("awr:InformF2") .
                        sw:end-element ("awr:InformF1F2") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks and (tt-act-header.type_ = "Проверки" or tt-act-header.type_ = "Арест") then do :
                        sw:start-element ("awr:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("awr:MarkCode", tt-marks.mark) .
            end.
                        sw:end-element ("awr:MarkCodeInfo") .
        end.
                    sw:end-element ("awr:Position") .
    end.
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOff_v2") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
end procedure .
procedure parseXML :
    define input parameter inFile as character no-undo .
    empty temp-table tt-act-header .
    empty temp-table tt-gds-act .
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
    hDoc:encoding = 'utf-8'.
    hDoc:LOAD("file", search(inFile),FALSE).
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    RUN GetChildren(hRoot, 1).
    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.
end procedure .
procedure GetChildren :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        hNoderef:GET-CHILD(hText, 1) no-error .
        IF hNoderef:NAME = "awr:Header" THEN do :
            create tt-act-header .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "awr:ActNumber" THEN assign tt-act-header.num    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:ActDate" THEN
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "awr:TypeWriteOff" THEN assign tt-act-header.type_    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "awr:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "awr:Quantity" THEN assign tt-gds-act.qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "pref:BRegId"
        OR hNoderef:NAME = "pref:F2RegId" THEN assign tt-gds-act.inform-B = (hText:node-value) no-error .
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act.gds-code = integer(hText:node-value) no-error .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if available buf_goods then assign tt-gds-act.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act.gds-name) = "" then assign tt-gds-act.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code"     THEN assign tt-gds-act.alc-code = (hText:node-value) no-error .
        IF hNoderef:NAME = "awr:MarkCode" THEN do :
            create tt-marks.
            assign
                tt-marks.num                    = tt-gds-act.num
                tt-marks.gds-part-position_     = tt-gds-act.position_
                tt-marks.mark                   = hText:node-value
                tt-marks.gds-code               = tt-gds-act.gds-code
                tt-marks.gds-name               = tt-gds-act.gds-name
                tt-marks.alc-code               = tt-gds-act.alc-code
                ii = ii + 1.
            .
            assign tt-gds-act.marks-qnty = ii .
        end.
        run GetChildren (hNoderef, (level + 1)).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
define variable bh-act-header-tts  as handle no-undo .
define temp-table tt-act-header-tts
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act-tts
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-B      as character                label "Справка Б"               format "X(20)"
    index pi as primary unique
        position_
    index code
        gds-code
.
define variable sw-tts as handle no-undo .
define variable v-file-tts              as character no-undo initial "TransferToShop1.xml".
DEFINE VARIABLE hDoc-tts AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot-tts AS HANDLE NO-UNDO.
DEFINE VARIABLE good-tts AS LOGICAL NO-UNDO.
procedure makeXML-tts :
    create sax-writer sw-tts .
    sw-tts:formatted = true.
    sw-tts:set-output-destination ("file", v-file-tts).
    sw-tts:encoding = "UTF-8".
    sw-tts:start-document () .
    sw-tts:start-element ("ns:Documents") .
    sw-tts:insert-attribute ("Version", "1.0") .
    sw-tts:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw-tts:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
    sw-tts:insert-attribute ("xmlns:c", "http://fsrar.ru/WEGAIS/Common") .
    sw-tts:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw-tts:insert-attribute ("xmlns:tts", "http://fsrar.ru/WEGAIS/TransferToShop") .
        sw-tts:start-element ("ns:Owner") .
            sw-tts:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw-tts:end-element ("ns:Owner") .
        sw-tts:start-element ("ns:Document") .
            sw-tts:start-element ("ns:TransferToShop") .
                sw-tts:write-data-element ("tts:Identity", tt-act-header-tts.num) no-error .
                sw-tts:start-element ("tts:Header") .
                    sw-tts:write-data-element ("tts:TransferNumber", tt-act-header-tts.num) no-error .
                    sw-tts:write-data-element ("tts:TransferDate", string(iso-date(tt-act-header-tts.date_))) no-error .
                sw-tts:end-element ("tts:Header") .
                sw-tts:start-element ("tts:Content") .
    for each tt-gds-act-tts no-lock where tt-gds-act-tts.num = tt-act-header-tts.num :
                    sw-tts:start-element ("tts:Position") .
                        sw-tts:write-data-element ("tts:Identity", string(tt-gds-act-tts.position_)) no-error .
                        sw-tts:write-data-element ("tts:Quantity", string(tt-gds-act-tts.qnty)) no-error .
                        sw-tts:write-data-element ("gds-code", string(tt-gds-act-tts.gds-code)) no-error .
                        sw-tts:write-data-element ("gds-name", tt-gds-act-tts.gds-name) no-error .
                        sw-tts:write-data-element ("alc-code", tt-gds-act-tts.alc-code) no-error .
                        sw-tts:start-element ("tts:InformB") .
                            sw-tts:write-data-element ("pref:BRegId", tt-gds-act-tts.inform-B) no-error .
                        sw-tts:end-element ("tts:InformB") .
                    sw-tts:end-element ("tts:Position") .
    end.
                sw-tts:end-element ("tts:Content") .
            sw-tts:end-element ("ns:TransferToShop") .
        sw-tts:end-element ("ns:Document") .
    sw-tts:end-element ("ns:Documents") .
    sw-tts:end-document () .
    delete object sw-tts.
end procedure .
procedure makeXMLegais_v2-tts :
    create sax-writer sw-tts .
    sw-tts:formatted = true.
    sw-tts:set-output-destination ("file", v-file-tts).
    sw-tts:encoding = "UTF-8".
    sw-tts:start-document () .
    sw-tts:start-element ("ns:Documents") .
    sw-tts:insert-attribute ("Version", "1.0") .
    sw-tts:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw-tts:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
    sw-tts:insert-attribute ("xmlns:c", "http://fsrar.ru/WEGAIS/Common") .
    sw-tts:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw-tts:insert-attribute ("xmlns:tts", "http://fsrar.ru/WEGAIS/TransferToShop") .
        sw-tts:start-element ("ns:Owner") .
            sw-tts:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw-tts:end-element ("ns:Owner") .
        sw-tts:start-element ("ns:Document") .
            sw-tts:start-element ("ns:TransferToShop") .
                sw-tts:write-data-element ("tts:Identity", tt-act-header-tts.num) .
                sw-tts:start-element ("tts:Header") .
                    sw-tts:write-data-element ("tts:TransferNumber", tt-act-header-tts.num) .
                    sw-tts:write-data-element ("tts:TransferDate", string(iso-date(tt-act-header-tts.date_))) no-error .
                sw-tts:end-element ("tts:Header") .
                sw-tts:start-element ("tts:Content") .
    for each tt-gds-act-tts no-lock where tt-gds-act-tts.num = tt-act-header-tts.num :
        if tt-gds-act.qnty <= 0 or trim(tt-gds-act.inform-B) = "" or tt-gds-act-tts.inform-B = ? then next.
                    sw-tts:start-element ("tts:Position") .
                        sw-tts:write-data-element ("tts:Identity", string(tt-gds-act-tts.position_)) .
                        sw-tts:write-data-element ("tts:ProductCode", tt-gds-act-tts.alc-code) no-error .
                        sw-tts:write-data-element ("tts:Quantity", string(tt-gds-act-tts.qnty)) .
                        sw-tts:start-element ("tts:InformF2") .
                          sw-tts:write-data-element ("pref:F2RegId", tt-gds-act-tts.inform-B) .
                        sw-tts:end-element ("tts:InformF2") .
                    sw-tts:end-element ("tts:Position") .
    end.
                sw-tts:end-element ("tts:Content") .
            sw-tts:end-element ("ns:TransferToShop") .
        sw-tts:end-element ("ns:Document") .
    sw-tts:end-element ("ns:Documents") .
    sw-tts:end-document () .
    delete object sw-tts.
end procedure .
procedure parseXML-tts :
    define input parameter inFile as character no-undo .
    empty temp-table tt-act-header-tts .
    empty temp-table tt-gds-act-tts .
    CREATE X-DOCUMENT hDoc-tts.
    CREATE X-NODEREF hRoot-tts.
    hDoc-tts:encoding = 'utf-8'.
    hDoc-tts:LOAD("file", search(inFile),FALSE).
    hDoc-tts:GET-DOCUMENT-ELEMENT(hRoot-tts).
    RUN GetChildren-tts(hRoot-tts, 1).
    DELETE OBJECT hDoc-tts.
    DELETE OBJECT hRoot-tts.
end procedure .
procedure GetChildren-tts :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        hNoderef:GET-CHILD(hText, 1) no-error .
        IF hNoderef:NAME = "tts:Header" THEN do :
            create tt-act-header-tts .
            assign tt-act-header-tts.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value no-error.
        end .
        .
        IF hNoderef:NAME = "tts:TransferNumber" THEN assign tt-act-header-tts.num    = hText:node-value no-error .
        IF hNoderef:NAME = "tts:TransferDate" THEN
            assign tt-act-header-tts.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "tts:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act-tts .
            assign tt-gds-act-tts.num = tt-act-header-tts.num .
        end.
        IF hNoderef:NAME = "tts:Identity" THEN assign tt-gds-act-tts.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "tts:Quantity" THEN assign tt-gds-act-tts.qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "pref:BRegId"
        OR hNoderef:NAME = "pref:F2RegId" THEN assign tt-gds-act-tts.inform-B = (hText:node-value) no-error .
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act-tts.gds-code = integer(hText:node-value) no-error .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act-tts.gds-code no-error .
            if available buf_goods then assign tt-gds-act-tts.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act-tts.gds-name) = "" then assign tt-gds-act-tts.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code"
        OR hNoderef:NAME = "tts:ProductCode"    THEN assign tt-gds-act-tts.alc-code = (hText:node-value) no-error .
        run GetChildren-tts (hNoderef, (level + 1)).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
define buffer x_ext-classif-attr     for ub.ext-classif-attr .
define variable bh-act-header-awos  as handle no-undo .
define temp-table tt-act-header-awos
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field type_         as character        label "Основание списания" format "X(18)"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act-awos
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code
.
define     temp-table tt-marks-awos
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)"
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)"
    field flag                as logical              label "T"
    index pi as primary unique
        mark
.
define variable sw-awos as handle no-undo .
define variable v-file-awos              as character no-undo initial "ActWriteOff_Shop1.xml".
DEFINE VARIABLE hDoc-awos AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot-awos AS HANDLE NO-UNDO.
DEFINE VARIABLE good-awos AS LOGICAL NO-UNDO.
procedure makeXML-awos :
    create sax-writer sw-awos .
    sw-awos:formatted = true.
    sw-awos:set-output-destination ("file", v-file-awos).
    sw-awos:encoding = "UTF-8".
    sw-awos:start-document () .
    sw-awos:start-element ("ns:Documents") .
    sw-awos:insert-attribute ("Version", "1.0") .
    sw-awos:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw-awos:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw-awos:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw-awos:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff") .
        sw-awos:start-element ("ns:Owner") .
            sw-awos:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw-awos:end-element ("ns:Owner") .
        sw-awos:start-element ("ns:Document") .
            sw-awos:start-element ("ns:ActWriteOff") .
                sw-awos:write-data-element ("awr:Identity", tt-act-header-awos.num) no-error .
                sw-awos:start-element ("awr:Header") .
                    sw-awos:write-data-element ("awr:ActNumber", tt-act-header-awos.num) no-error .
                    sw-awos:write-data-element ("awr:ActDate", string(iso-date(tt-act-header-awos.date_))) no-error .
                    sw-awos:write-data-element ("awr:TypeWriteOff", tt-act-header-awos.type_) no-error .
                    sw-awos:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw-awos:end-element ("awr:Header") .
                sw-awos:start-element ("awr:Content") .
    for each tt-gds-act-awos no-lock where tt-gds-act-awos.num = tt-act-header-awos.num :
                    sw-awos:start-element ("awr:Position") .
                        sw-awos:write-data-element ("awr:Identity", string(tt-gds-act-awos.position_)) no-error .
                        sw-awos:write-data-element ("awr:Quantity", string(tt-gds-act-awos.qnty)) no-error .
                        sw-awos:write-data-element ("gds-code", string(tt-gds-act-awos.gds-code)) no-error .
                        sw-awos:write-data-element ("gds-name", tt-gds-act-awos.gds-name) no-error .
                        sw-awos:write-data-element ("alc-code", tt-gds-act-awos.alc-code) no-error .
                        sw-awos:start-element ("awr:MarkCodeInfo") .
            for each tt-marks-awos no-lock where tt-marks-awos.num = tt-gds-act-awos.num and tt-marks-awos.gds-part-position_ = tt-gds-act-awos.position_ :
                            sw-awos:write-data-element ("awr:MarkCode", tt-marks-awos.mark) .
            end.
                        sw-awos:end-element ("awr:MarkCodeInfo") .
                    sw-awos:end-element ("awr:Position") .
    end.
                sw-awos:end-element ("awr:Content") .
            sw-awos:end-element ("ns:ActWriteOff") .
        sw-awos:end-element ("ns:Document") .
    sw-awos:end-element ("ns:Documents") .
    sw-awos:end-document () .
    delete object sw-awos.
end procedure .
procedure makeXMLegais_v2-awos :
    create sax-writer sw-awos .
    sw-awos:formatted = true.
    sw-awos:set-output-destination ("file", v-file-awos).
    sw-awos:encoding = "UTF-8".
    sw-awos:start-document () .
    sw-awos:start-element ("ns:Documents") .
    sw-awos:insert-attribute ("Version", "1.0") .
    sw-awos:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw-awos:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw-awos:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef_v2") .
    sw-awos:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw-awos:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOffShop_v2") .
    sw-awos:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw-awos:start-element ("ns:Owner") .
            sw-awos:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw-awos:end-element ("ns:Owner") .
        sw-awos:start-element ("ns:Document") .
            sw-awos:start-element ("ns:ActWriteOffShop_v2") .
                sw-awos:write-data-element ("awr:Identity", tt-act-header-awos.num) .
                sw-awos:start-element ("awr:Header") .
                    sw-awos:write-data-element ("awr:ActNumber", tt-act-header-awos.num) .
                    sw-awos:write-data-element ("awr:ActDate", string(iso-date(tt-act-header-awos.date_))) no-error .
                    sw-awos:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                    sw-awos:write-data-element ("awr:TypeWriteOff", tt-act-header-awos.type_) .
                sw-awos:end-element ("awr:Header") .
                sw-awos:start-element ("awr:Content") .
    for each tt-gds-act-awos no-lock where tt-gds-act-awos.num = tt-act-header-awos.num :
        if tt-gds-act-awos.qnty <= 0 then next.
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
                    if not available buf_goods and (tt-gds-act.gds-code = 0 or tt-gds-act.gds-code =?)
                    then do :
                        find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                                               and X_ext-classif.db-num = 0
                                                               and X_ext-classif.Key#_two = v-ext-sys
                                                               and X_ext-classif.Key#_three = 0
                                                               and X_ext-classif.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif.CharKey_two = ""
                                                               and X_ext-classif.CharKey_three = ""
                                                               and X_ext-classif.nonunique = 0
                                                               no-error .
                        if available X_ext-classif
                        then do :
                            tt-gds-act.gds-code = X_ext-classif.Key#_One .
                            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                        end.
                    end.
                    sw-awos:start-element ("awr:Position") .
                        sw-awos:write-data-element ("awr:Identity", string(tt-gds-act-awos.position_)) .
                        sw-awos:start-element ("awr:Product") .
                            sw-awos:write-data-element ("pref:UnitType", (if buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1 then "Unpacked" else "Packed")) .
                            sw-awos:write-data-element ("pref:FullName", tt-gds-act-awos.egais-name) no-error .
                            sw-awos:write-data-element ("pref:ShortName", "") .
                            sw-awos:write-data-element ("pref:AlcCode", tt-gds-act-awos.alc-code) .
                            if not (buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1)
                            then sw-awos:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) .
                            sw-awos:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) .
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw-awos:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
                        end.
                        find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = 'goods':U
                                                               and X_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
                                                               and X_ext-classif-attr.db-num = 0
                                                               and X_ext-classif-attr.Key#_One = tt-gds-act.gds-code
                                                               and X_ext-classif-attr.Key#_two = v-ext-sys
                                                               and X_ext-classif-attr.Key#_three = 0
                                                               and X_ext-classif-attr.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif-attr.CharKey_two = ""
                                                               and X_ext-classif-attr.CharKey_three = ""
                                                               and X_ext-classif-attr.nonunique = 0
                                                               and X_ext-classif-attr.attr-code = 'egais-info'
                                                               no-error .
                        if available X_ext-classif-attr and num-entries(X_ext-classif-attr.attr-value, CHR(4)) >= 3 then do :
                          def var v-prod as char no-undo.
                          def var v-impor as char no-undo.
                          def var v-msg as char no-undo.
                          def var v-err as logical no-undo.
                          def var v-err-impor as logical no-undo.
                          v-err = false .
                          v-prod = ''.
                          v-impor = ''.
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 8
                          or entry (7, v-prod, chr(5)) = ""
                          then do:
                            message "У товара неизвестен производитель (или его тип) из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.
                            v-err = true .
                          end.
                          if not v-err then do :
                            sw-awos:start-element ("pref:Producer") .
                             sw-awos:start-element ("oref:" + entry (7, v-prod, chr(5))) .
                              if entry (7, v-prod, chr(5)) <> "TS" then do :
                                  if entry (2, v-prod, chr(5)) <> "" then sw-awos:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                                  if entry (3, v-prod, chr(5)) <> "" then sw-awos:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                              end.
                              else if entry (2, v-prod, chr(5)) <> "" then sw-awos:write-data-element ("oref:TSNUM", entry (2, v-prod, chr(5)) ).
                              sw-awos:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                              sw-awos:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                              sw-awos:start-element ("oref:address").
                                sw-awos:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                                if entry (8, v-prod, chr(5)) <> "" then sw-awos:write-data-element ("oref:RegionCode", entry (8, v-prod, chr(5)) ).
                                sw-awos:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                              sw-awos:end-element ("oref:address").
                             sw-awos:end-element ("oref:" + entry (7, v-prod, chr(5))) .
                            sw-awos:end-element ("pref:Producer") .
                          end.
                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act-awos.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        sw-awos:end-element ("awr:Product") .
                        sw-awos:write-data-element ("awr:Quantity", string(tt-gds-act-awos.qnty)) .
        find first tt-marks-awos where tt-marks-awos.num = tt-gds-act-awos.num and tt-marks-awos.gds-part-position_ = tt-gds-act-awos.position_ no-lock no-error.
        if available tt-marks-awos and (tt-act-header-awos.type_ = "Проверки" or tt-act-header-awos.type_ = "Арест") then do :
                        sw-awos:start-element ("awr:MarkCodeInfo") .
            for each tt-marks-awos no-lock where tt-marks-awos.num = tt-gds-act-awos.num and tt-marks-awos.gds-part-position_ = tt-gds-act-awos.position_ :
                            sw-awos:write-data-element ("awr:MarkCode", tt-marks-awos.mark) .
            end.
                        sw-awos:end-element ("awr:MarkCodeInfo") .
        end.
                    sw-awos:end-element ("awr:Position") .
    end.
                sw-awos:end-element ("awr:Content") .
            sw-awos:end-element ("ns:ActWriteOffShop_v2") .
        sw-awos:end-element ("ns:Document") .
    sw-awos:end-element ("ns:Documents") .
    sw-awos:end-document () .
    delete object sw-awos.
end procedure .
procedure parseXML-awos :
    define input parameter inFile as character no-undo .
    empty temp-table tt-act-header-awos .
    empty temp-table tt-gds-act-awos .
    CREATE X-DOCUMENT hDoc-awos.
    CREATE X-NODEREF hRoot-awos.
    hDoc-awos:encoding = 'utf-8'.
    hDoc-awos:LOAD("file", search(inFile),FALSE).
    hDoc-awos:GET-DOCUMENT-ELEMENT(hRoot-awos).
    RUN GetChildren-awos(hRoot-awos, 1).
    DELETE OBJECT hDoc-awos.
    DELETE OBJECT hRoot-awos.
end procedure .
procedure GetChildren-awos :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        hNoderef:GET-CHILD(hText, 1) no-error .
        IF hNoderef:NAME = "awr:Header" THEN do :
            create tt-act-header-awos .
            assign tt-act-header-awos.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "awr:ActNumber" THEN assign tt-act-header-awos.num    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:ActDate" THEN
            assign tt-act-header-awos.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "awr:TypeWriteOff" THEN assign tt-act-header-awos.type_    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act-awos .
            assign tt-gds-act-awos.num = tt-act-header-awos.num .
        end.
        IF hNoderef:NAME = "awr:Identity" THEN assign tt-gds-act-awos.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "awr:Quantity" THEN assign tt-gds-act-awos.qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act-awos.gds-code = integer(hText:node-value) no-error .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if available buf_goods then assign tt-gds-act-awos.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act-awos.gds-name) = "" then assign tt-gds-act-awos.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code"     THEN assign tt-gds-act-awos.alc-code = (hText:node-value) no-error .
        IF hNoderef:NAME = "awr:MarkCode" THEN do :
            create tt-marks-awos.
            assign
                tt-marks-awos.num                    = tt-gds-act-awos.num
                tt-marks-awos.gds-part-position_     = tt-gds-act-awos.position_
                tt-marks-awos.mark                   = hText:node-value
                tt-marks-awos.gds-code               = tt-gds-act-awos.gds-code
                tt-marks-awos.gds-name               = tt-gds-act-awos.gds-name
                tt-marks-awos.alc-code               = tt-gds-act-awos.alc-code
                ii = ii + 1.
            .
            assign tt-gds-act-awos.marks-qnty = ii .
        end.
        run GetChildren-awos (hNoderef, (level + 1)).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
FUNCTION get-mark RETURNS CHARACTER
(buffer local-gds for tt-gds-rests ):
if lookup (string (recid (local-gds)), select-list) > 0  then return "*".
                                                           else return "".
end function.
FUNCTION get-mark_shop RETURNS CHARACTER
(buffer local-gds_shop for tt-gds-rests_shop ):
if lookup (string (recid (local-gds_shop)), select-list_shop) > 0  then return "*".
                                                           else return "".
end function.
define menu m-func
    menu-item m-writeOff label "Сформировать акт о списании"
    menu-item m-tts label "Сформировать акт передачи в торговый зал"
    menu-item m-print label "Печать остатков на складе"
    menu-item m-print_shop label "Печать остатков в магазине"
    menu-item m-load-all label "Запрос по всем объектам"
    menu-item m-file label "Загрузить из файла"
.
define menu m-func_shop
    menu-item m-writeOff_shop label "Сформировать акт о списании из торгового зала"
    menu-item m-print label "Печать остатков на складе"
    menu-item m-print_shop label "Печать остатков в магазине"
    menu-item m-compare label "Сверка остатков"
    menu-item m-marks-compare label "Сверка по маркам"
    menu-item m-list label "Показать по списку"
    menu-item m-all label "Показать все"
    menu-item m-load-all label "Запрос по всем объектам"
    menu-item m-file label "Загрузить из файла"
.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.14 .
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-load
     LABEL "Запрос"
     tooltip "Отправить запрос в ЕГАИС"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-save
     LABEL "Сохранить"
     tooltip "Записать данные о справках A/B в партию"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-answer
     LABEL "Получить ответ"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-del
     LABEL "Удалить связку"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-connect
     LABEL "Связать"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-func
     LABEL "Функции"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-func_shop
     LABEL "Функции"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1.14 TOOLTIP "Отметить все объекты".
DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1.14 TOOLTIP "Снять все отметки".
defin variable t-negative_rests as logical view-as toggle-box label "Отрицательные остатки" initial no no-undo .
defin variable t-not_eq_rests as logical view-as toggle-box label "Расхождения кол-ва" initial no no-undo .
Define variable NameContext as character view-as fill-in size 30 by 1 fgcolor 12 no-undo.
define variable loc-alc  as character view-as fill-in size 25 by 1 fgcolor 12 no-undo format "x(25)":U.
define variable loc-code as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable a-n-c as character view-as radio-set horizontal radio-buttons
"Алк. Код","alc",
"Нач.слова","context",
"Код TH","code"
size 30 by 1    fgcolor 0  no-undo.
DEFINE QUERY br-rests FOR
      tt-gds-rests SCROLLING.
DEFINE QUERY br-rests_shop FOR
      tt-gds-list, tt-gds-rests_shop  SCROLLING.
DEFINE QUERY br-rests_all FOR
      tt-gds-rests SCROLLING.
DEFINE BROWSE br-rests
  QUERY br-rests  DISPLAY
    get-mark(BUFFER tt-gds-rests) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-gds-rests.alc-code COLUMN-LABEL "Алкогольный код" FORMAT "X(25)":U
    tt-gds-rests.gds-name COLUMN-LABEL "Наименование товара" FORMAT "X(100)":U width 39
    tt-gds-rests.gds-code COLUMN-LABEL "Код товара в TH" FORMAT ">>>>>>>>9"
    tt-gds-rests.alc-type-code COLUMN-LABEL "Код АП" FORMAT "X(4)":U
    tt-gds-rests.egais-qnty
    tt-gds-rests.informA_
    tt-gds-rests.informB_
    tt-gds-rests.TH-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 20 FIT-LAST-COLUMN.
DEFINE BROWSE br-rests_shop
  QUERY br-rests_shop  DISPLAY
    get-mark_shop(BUFFER tt-gds-rests_shop) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-gds-rests_shop.alc-code COLUMN-LABEL "Алкогольный код" FORMAT "X(25)":U
    tt-gds-rests_shop.gds-name COLUMN-LABEL "Наименование товара" FORMAT "X(100)":U width 39
    tt-gds-rests_shop.gds-code COLUMN-LABEL "Код товара в TH" FORMAT "X(25)"
    tt-gds-rests_shop.alc-type-code COLUMN-LABEL "Код АП" FORMAT "X(4)":U
    tt-gds-rests_shop.egais-qnty
    tt-gds-rests_shop.egais-qnty_stock
    tt-gds-rests_shop.TH-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 12 .
DEFINE BROWSE br-rests_all
  QUERY br-rests_all  DISPLAY
    tt-gds-rests.alc-code COLUMN-LABEL "Алкогольный код" FORMAT "X(25)":U
    tt-gds-rests.gds-name COLUMN-LABEL "Наименование товара" FORMAT "X(100)":U width 39
    tt-gds-rests.gds-code COLUMN-LABEL "Код товара в TH" FORMAT ">>>>>>>>9"
    tt-gds-rests.alc-type-code COLUMN-LABEL "Код АП" FORMAT "X(4)":U
    tt-gds-rests.egais-qnty
    tt-gds-rests.informB_
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 8 title "Остатки на складе по алкокоду в разрезе справок Б" .
DEFINE RECTANGLE Rect-Bottom
     EDGE-PIXELS 0
     SIZE 1 BY 1
     BGCOLOR 7 .
DEFINE RECTANGLE Rect-Left
     EDGE-PIXELS 0
     SIZE 1 BY 1
     BGCOLOR 15 .
DEFINE RECTANGLE Rect-Main
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 1 BY 1
     BGCOLOR 8 FGCOLOR 0 .
DEFINE RECTANGLE Rect-Right
     EDGE-PIXELS 0
     SIZE 1 BY 1
     BGCOLOR 7 .
DEFINE RECTANGLE Rect-Top
     EDGE-PIXELS 0
     SIZE 1 BY 1
     BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     b-mark AT ROW 2.5 COL 2
     b-sel-all AT ROW 2.5 COL 5
     b-unmark AT ROW 2.5 COL 8
     b-load AT ROW 1.24 COL 32
     b-answer AT ROW 1.24 COL 47
     b-save AT ROW 1.24 COL 17
     b-cancel AT ROW 1.24 COL 2
     v-fs-rar at row 2.7 col 17 label "ФСРАР ID"
     b-connect AT ROW 1.24 COL 62
     b-del at row 1.24 col 77
     b-func at row 1.24 col 92
     b-func_shop at row 1.24 col 92
     t-negative_rests at row 5.3 col 83
     t-not_eq_rests at row 5.3 col 60
     a-n-c at row 4 col 2 label "Поиск по"
     NameContext at row 4 col 50 label "Контекст"
     loc-alc at row 4 col 50 no-label
     loc-code at row 4 col 50 label "Код(весь)"
     v-DT-rests at row 2.8 col 48
     v-DT-rests_shop at row 2.8 col 48
     br-rests AT ROW 6.5 COL 2.2 WIDGET-ID 200
     br-rests_shop AT ROW 6.5 COL 2.2 WIDGET-ID 220
     br-rests_all AT ROW 18.5 COL 2.2 WIDGET-ID 240
     Rect-Main AT ROW 5 COL 5.75
     Rect-Bottom AT ROW 5 COL 3.5
     Rect-Left AT ROW 1 COL 1.25
     Rect-Right AT ROW 1 COL 34.25
     Rect-Top AT ROW 1 COL 1.25
     SPACE(106) SKIP(24.8)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Остатки ЕГАИС"
         DEFAULT-BUTTON b-load CANCEL-BUTTON b-cancel WIDGET-ID 100.
assign br-rests:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1 .
assign br-rests_shop:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1 .
assign br-rests_all:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 0 .
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
on F9 of frame Dialog-Frame anywhere do:
  if not available tt-gds-rests then  return no-apply.
  if tt-gds-rests.gds-code = 0  then  return no-apply.
  find first goods no-lock where goods.gds-code = tt-gds-rests.gds-code .
  gds-rec = recid(goods) .
  run ref/gds-form.w
    (input  parParentProc
    ,input  'ПРОСМОТР':U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input ?
    ,input-output gds-rec
    ).
end.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
    delete object Rests no-error .
    delete object Rests_shop no-error .
  APPLY "END-ERROR":U TO SELF.
END.
ON value-changed OF t-negative_rests in FRAME Dialog-Frame
DO:
    assign t-negative_rests.
    if t-not_eq_rests
    then do :
        t-not_eq_rests = false.
        display t-not_eq_rests with frame Dialog-Frame.
    end.
    if t-negative_rests
    then do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" and tt-gds-rests_shop.egais-qnty < 0 :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                and tt-gds-rests_shop.egais-qnty < 0 .
    end.
    else do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code <> ""
                                                                              and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                              and tt-gds-rests_shop.egais-qnty <> 0 .
    end.
END.
ON value-changed OF t-not_eq_rests in FRAME Dialog-Frame
DO:
    assign t-not_eq_rests.
    if t-negative_rests
    then do :
        t-negative_rests = false.
        display t-negative_rests with frame Dialog-Frame.
    end.
    if t-not_eq_rests
    then do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" and (tt-gds-rests_shop.egais-qnty <> tt-gds-rests_shop.TH-qnty)  :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                and tt-gds-rests_shop.egais-qnty <> tt-gds-rests_shop.TH-qnty .
    end.
    else do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code <> ""
                                                                              and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                              and tt-gds-rests_shop.egais-qnty <> 0 .
    end.
END.
ON value-changed OF a-n-c in FRAME Dialog-Frame
DO:
    assign a-n-c .
    assign NameContext = "" loc-code = "" loc-alc = "" loc-alc:screen-value = "" .
    case a-n-c :
        when "alc" then do :
            if v-page-current = 1
            then do :
                OPEN QUERY br-rests FOR EACH tt-gds-rests .
                hide NameContext loc-code in frame Dialog-Frame .
                display loc-alc with frame Dialog-Frame .
                apply "entry" to br-rests in frame Dialog-Frame .
            end.
            else do :
                open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code <> ""
                                                                              and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                              and tt-gds-rests_shop.egais-qnty <> 0 .
                hide NameContext loc-code in frame Dialog-Frame .
                display loc-alc with frame Dialog-Frame .
                apply "entry" to br-rests_shop in frame Dialog-Frame .
            end.
        end.
        when "context" then do :
            hide loc-alc loc-code in frame Dialog-Frame .
            enable NameContext with frame Dialog-Frame .
            apply "entry" to NameContext in frame Dialog-Frame .
        end.
        when "code" then do :
            OPEN QUERY br-rests FOR EACH tt-gds-rests .
            hide loc-alc NameContext in frame Dialog-Frame .
            enable loc-code with frame Dialog-Frame .
            apply "entry" to loc-code in frame Dialog-Frame .
        end.
    end case.
END.
ON return OF NameContext IN FRAME Dialog-Frame do:
    define variable letter as character no-undo .
    assign NameContext.
    if trim(NameContext) = "" then do :
        OPEN QUERY br-rests FOR EACH tt-gds-rests .
    end.
    else do :
        letter = substring(NameContext, length(NameContext), 1) .
        if letter = 'н'
        or letter = 'о'
        or letter = 'э'
        or letter = 'ю'
        or letter = 'я'
        then do :
            if v-page-current = 1
            then
                OPEN QUERY br-rests FOR EACH tt-gds-rests where tt-gds-rests.gds-name contains (trim(NameContext)) INDEXED-REPOSITION .
            else
                OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.gds-name contains (trim(NameContext))
                                                                                        and tt-gds-rests_shop.alc-code <> ""
                                                                                        and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                        and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                        and tt-gds-rests_shop.egais-qnty <> 0 INDEXED-REPOSITION .
        end.
        else do :
            if v-page-current = 1
            then
                OPEN QUERY br-rests FOR EACH tt-gds-rests where tt-gds-rests.gds-name contains (trim(NameContext) + "*") INDEXED-REPOSITION .
            else
                OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.gds-name contains (trim(NameContext) + "*")
                                                                                        and tt-gds-rests_shop.alc-code <> ""
                                                                                        and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                        and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                        and tt-gds-rests_shop.egais-qnty <> 0 INDEXED-REPOSITION .
        end.
    end.
end.
ON return OF loc-code IN FRAME Dialog-Frame do:
    assign loc-code.
    if v-page-current = 1
    then do :
        find first tt-gds-rests no-lock where tt-gds-rests.gds-code = integer(loc-code) no-error.
        if not available tt-gds-rests then do :
            message "Не найден товар с кодом " + loc-code view-as alert-box warning .
        end.
        else do :
            assign tt-rec = recid(tt-gds-rests) .
            reposition br-rests to recid tt-rec .
        end.
    end.
    else do :
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.gds-code matches ("*" + loc-code + "*") no-error.
        if not available tt-gds-rests_shop then do :
            message "Не найден товар с кодом " + loc-code view-as alert-box warning .
        end.
        else do :
            assign tt-row2 = rowid(tt-gds-rests_shop) .
            find first tt-gds-list no-lock where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                             and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code no-error.
            if not available tt-gds-list
            then do :
                message "В данной выборке не найден товар с кодом " + loc-code view-as alert-box warning .
            end.
            else do :
                assign tt-row = rowid(tt-gds-list) .
                reposition br-rests_shop to rowid tt-row, tt-row2 .
            end.
        end.
    end.
end.
ON any-printable OF br-rests IN FRAME Dialog-Frame do:
    if input frame Dialog-Frame a-n-c = "alc" then do:
        if last-event:label = " " and
           loc-alc = "" then
        return no-apply.
        find first tt-gds-rests no-lock where tt-gds-rests.alc-code begins (loc-alc + last-event:label) no-error.
        if available tt-gds-rests then do :
            loc-alc = loc-alc + last-event:label.
            disp loc-alc with frame Dialog-Frame.
            assign tt-rec = recid(tt-gds-rests) .
            reposition br-rests to recid tt-rec .
        end.
        else bell.
    end.
end.
ON backspace OF br-rests IN FRAME Dialog-Frame do:
    if input frame Dialog-Frame a-n-c = "alc" then do:
        if loc-alc = "" then
          return no-apply.
        loc-alc = substr (loc-alc, 1, length (loc-alc) - 1).
        find first tt-gds-rests no-lock where tt-gds-rests.alc-code begins loc-alc no-error.
        if available tt-gds-rests then do :
            disp loc-alc with frame Dialog-Frame.
            assign tt-rec = recid(tt-gds-rests) .
            reposition br-rests to recid tt-rec .
        end.
    end.
end.
ON any-printable OF br-rests_shop IN FRAME Dialog-Frame do:
    if input frame Dialog-Frame a-n-c = "alc" then do:
        if last-event:label = " " and
           loc-alc = "" then
        return no-apply.
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code begins (loc-alc + last-event:label) no-error.
        if available tt-gds-rests_shop then do :
            assign tt-row2 = rowid(tt-gds-rests_shop) .
            find first tt-gds-list no-lock where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                             and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code .
            loc-alc = loc-alc + last-event:label.
            disp loc-alc with frame Dialog-Frame.
            assign tt-row = rowid(tt-gds-list) .
            reposition br-rests_shop to rowid tt-row, tt-row2 .
        end.
        else bell.
    end.
end.
ON backspace OF br-rests_shop IN FRAME Dialog-Frame do:
    if input frame Dialog-Frame a-n-c = "alc" then do:
        if loc-alc = "" then
          return no-apply.
        loc-alc = substr (loc-alc, 1, length (loc-alc) - 1).
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code begins loc-alc no-error.
        if available tt-gds-rests_shop then do :
            assign tt-row2 = rowid(tt-gds-rests_shop) .
            find first tt-gds-list no-lock where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                             and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code .
            disp loc-alc with frame Dialog-Frame.
            assign tt-row = rowid(tt-gds-list) .
            reposition br-rests_shop to rowid tt-row, tt-row2 .
        end.
    end.
end.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
  if v-page-current = 1
  then do :
    run proc-b-mark in this-procedure no-error.
  end.
  else do :
    run proc-b-mark_shop in this-procedure no-error.
  end.
END.
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame
DO:
  if v-page-current = 1
  then do :
      assign select-list = "".
      if not available tt-gds-rests then return.
      for each tt-gds-rests no-lock :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid15 as character no-undo .
define variable v-num-entry15 as integer   no-undo .
assign
  v-str-recid15 = trim( string( recid( tt-gds-rests ) , "->>>>>>>>>>>9":U ) )
  v-num-entry15 = lookup( v-str-recid15 , select-list )
.
if v-num-entry15 > 0 then do:
  assign
    entry( v-num-entry15, select-list ) = "":U
    select-list = trim( replace( select-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    select-list = select-list + ( if select-list = "":U then "":U else chr(44) ) + v-str-recid15
  .
end.
      end.
      br-rests:refresh() in frame Dialog-Frame .
  end.
  else do :
      assign select-list_shop = "".
      if not available tt-gds-rests_shop then return.
      for each tt-gds-rests_shop no-lock :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid17 as character no-undo .
define variable v-num-entry17 as integer   no-undo .
assign
  v-str-recid17 = trim( string( recid( tt-gds-rests_shop ) , "->>>>>>>>>>>9":U ) )
  v-num-entry17 = lookup( v-str-recid17 , select-list_shop )
.
if v-num-entry17 > 0 then do:
  assign
    entry( v-num-entry17, select-list_shop ) = "":U
    select-list_shop = trim( replace( select-list_shop , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    select-list_shop = select-list_shop + ( if select-list_shop = "":U then "":U else chr(44) ) + v-str-recid17
  .
end.
      end.
      br-rests_shop:refresh() in frame Dialog-Frame .
  end.
END.
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame
DO:
  if v-page-current = 1
  then do :
      if not available tt-gds-rests then return.
      select-list  = "".
      br-rests:refresh() in frame Dialog-Frame .
  end.
  else do :
      if not available tt-gds-rests_shop then return.
      select-list_shop  = "".
      br-rests_shop:refresh() in frame Dialog-Frame .
  end.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
    message "Все несохранённые данные будут потеряны. Вы уверены, что хотите выйти?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply .
END.
ON CHOOSE OF b-connect IN FRAME Dialog-Frame
DO:
    if not available tt-gds-rests then return no-apply.
    if tt-gds-rests.gds-code = 0 or tt-gds-rests.gds-code = ? then do :
        message "Данный товар не синхронизирован с ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    assign v-rid = recid(tt-gds-rests) .
    run str/parts-l.w
     (
        input parparentproc
     ,  input v-cntxt-obj-type
     ,  input v-cntxt-obj-code
     ,  input tt-gds-rests.gds-code
     ,  input "":U
     ,  input 'ПРОСМОТР':U
     ,  input 'свободно':U
     ,  input 'текущий':U
     ,  input 'выбор':U
     , output v-prt-rec
     ) .
    for first buf_parts no-lock where recid(buf_parts) = v-prt-rec :
        if not can-do(tt-gds-rests.prt-rec,string(recid(buf_parts))) then
        assign
            tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts))
            tt-gds-rests.TH-qnty = tt-gds-rests.TH-qnty + buf_parts.fact-qnty
        .
    end.
    OPEN QUERY br-rests FOR EACH tt-gds-rests .
    reposition br-rests to recid v-rid .
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.
    do ii = 1 to num-entries(select-list) :
        v-sel-entry = entry(ii, select-list) .
        for first tt-gds-rests exclusive-lock where recid(tt-gds-rests) = integer(v-sel-entry)
                                                and tt-gds-rests.gds-code > 0
                                                and tt-gds-rests.prt-rec <> ? :
            do jj = 1 to num-entries(tt-gds-rests.prt-rec) :
                for first parts no-lock where recid(parts) = integer(entry(jj,tt-gds-rests.prt-rec)) :
                    run trg/partps.p ( input tt-gds-rests.gds-code
                                   , input parts.in-code
                                   , input 'free-zone':U
                                   , input parts.part-code
                                   , input v-cntxt-db-num-obj
                                   , input parts.mark-code
                                   , input parts.alc-bottling-date
                                   , input tt-gds-rests.informA_ + ',' + tt-gds-rests.informB_ + ',' + tt-gds-rests.alc-code + ',' + tt-gds-rests.alc-type-code
                                   , input parts.alc-quality-certif-path
                                   , input parts.alc-certif-path
                                   , input parts.alc-imp-type
                                   , input parts.alc-imp-code
                                   ) no-error .
                end.
            end.
        end.
    end.
    message "Сохранение завершено" view-as alert-box.
    br-rests:refresh () .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
    if not available tt-gds-rests then return no-apply.
    message "Вы уверены?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply .
    do jj = 1 to num-entries(tt-gds-rests.prt-rec) :
        for first parts no-lock where recid(parts) = integer(entry(jj,tt-gds-rests.prt-rec)) :
            run trg/partps.p ( input tt-gds-rests.gds-code
                           , input parts.in-code
                           , input 'free-zone':U
                           , input parts.part-code
                           , input v-cntxt-db-num-obj
                           , input parts.mark-code
                           , input parts.alc-bottling-date
                           , input ""
                           , input parts.alc-quality-certif-path
                           , input parts.alc-certif-path
                           , input parts.alc-imp-type
                           , input parts.alc-imp-code
                           ) no-error .
        end.
    end.
    assign
        tt-gds-rests.prt-rec = ""
        tt-gds-rests.TH-qnty = 0
    .
    br-rests:refresh () .
END.
ON CHOOSE OF b-load IN FRAME Dialog-Frame
DO:
    rests:SendRequestUTM() .
    rests_shop:SendRequestUTM() .
    glog = rests_shop:IsSent .
    if glog then enable b-answer WITH FRAME Dialog-Frame.
    else disable b-answer WITH FRAME Dialog-Frame .
    glog = rests_shop:StatusErr .
    if glog then do :
        message rests_shop:Msg view-as alert-box.
        return no-apply.
    end.
END.
ON CHOOSE OF b-answer IN FRAME Dialog-Frame
DO:
    run waitfram-show in this-procedure ("Ждите...") .
    bh-gds-egais = rests:GetHndlTable() .
    glog = rests:StatusErr .
    if glog then do :
        run waitfram-hide in this-procedure no-error .
        message rests:Msg view-as alert-box.
        return no-apply.
    end.
    if not valid-handle(bh-gds-egais) then do :
        run waitfram-hide in this-procedure no-error .
        message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
        return no-apply .
    end.
    empty temp-table tt-gds-rests .
    create query qh-gds-egais .
    qh-gds-egais:set-buffers (bh-gds-egais) .
    qh-gds-egais:query-prepare ("for each tt-gds-rests-eg").
    qh-gds-egais:query-open.
    _repeat:
    repeat:
        qh-gds-egais:get-next ().
        if qh-gds-egais:query-off-end then leave _repeat.
        create tt-gds-rests.
        buffer tt-gds-rests:handle:buffer-copy (bh-gds-egais) .
        assign tt-gds-rests.fromEgais = yes no-error.
        find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                           and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_ext-classif.charkey_one = tt-gds-rests.alc-code
                                           and X_ext-classif.charkey_two = ""
                                           and X_ext-classif.charkey_three = ""
                                           and X_ext-classif.nonunique = 0
                                           no-error.
        if available X_ext-classif then do :
            find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
            assign
                tt-gds-rests.gds-code   = buf_goods.gds-code
                tt-gds-rests.gds-name   = buf_goods.gds-name
            no-error .
        end.
        if available buf_goods then do :
            if (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then assign tt-gds-rests.egais-qnty = tt-gds-rests.egais-qnty * buf_goods.cli-base-rate .
            for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                           and buf_parts.prod-type  = buf_goods.prod-type
                                           and buf_parts.prod-code  = buf_goods.prod-code
                                           and buf_parts.obj-type   = v-cntxt-obj-type
                                           and buf_parts.obj-code   = v-cntxt-obj-code
                                           and buf_parts.out-code   = 'free-zone':U
                                           and num-entries(buf_parts.alc-ref-ab-path) = 4
                                           and entry(1, buf_parts.alc-ref-ab-path) = tt-gds-rests.informA_
                                           and entry(2, buf_parts.alc-ref-ab-path) = tt-gds-rests.informB_ :
                assign tt-gds-rests.TH-qnty = tt-gds-rests.TH-qnty + buf_parts.fact-qnty no-error .
                assign tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts)) no-error .
            end.
        end.
    end.
    OPEN QUERY br-rests FOR EACH tt-gds-rests .
    apply "value-changed" to br-rests .
    enable a-n-c with FRAME Dialog-Frame.
    apply "value-changed" to a-n-c in FRAME Dialog-Frame.
    v-DT-rests = substring(replace(rests:v-date-time, "T", " "), 1, length(rests:v-date-time) - 4) .
    if v-page-current = 1 then display v-DT-rests with FRAME Dialog-Frame.
    bh-gds-egais_shop = rests_shop:GetHndlTable() .
    glog = rests_shop:StatusErr .
    if glog then do :
        run waitfram-hide in this-procedure no-error .
        message rests_shop:Msg view-as alert-box.
        return no-apply.
    end.
    if not valid-handle(bh-gds-egais_shop) then do :
        run waitfram-hide in this-procedure no-error .
        message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
        return no-apply .
    end.
    empty temp-table tt-gds-rests_shop .
    empty temp-table tt-gds-list .
    create query qh-gds-egais_shop .
    qh-gds-egais_shop:set-buffers (bh-gds-egais_shop) .
    qh-gds-egais_shop:query-prepare ("for each tt-gds-rests-eg_shop").
    qh-gds-egais_shop:query-open.
    _repeat_shop:
    repeat:
        qh-gds-egais_shop:get-next ().
        if qh-gds-egais_shop:query-off-end then leave _repeat_shop.
        create tt-gds-rests_shop.
        buffer tt-gds-rests_shop:handle:buffer-copy (bh-gds-egais_shop) .
        assign tt-gds-rests_shop.fromEgais = yes .
        for each X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                           and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_ext-classif.charkey_one = tt-gds-rests_shop.alc-code
                                           and X_ext-classif.charkey_two = ""
                                           and X_ext-classif.charkey_three = ""
                                           and X_ext-classif.nonunique = 0 :
            find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
            assign
                tt-gds-rests_shop.gds-code   = if tt-gds-rests_shop.gds-code = "" then string(buf_goods.gds-code) else tt-gds-rests_shop.gds-code + ", " + string(buf_goods.gds-code)
                tt-gds-rests_shop.gds-name   = buf_goods.gds-name
            .
            if (not tt-gds-rests_shop.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then assign tt-gds-rests_shop.egais-qnty = tt-gds-rests_shop.egais-qnty * buf_goods.cli-base-rate .
            for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                           and buf_parts.prod-type  = buf_goods.prod-type
                                           and buf_parts.prod-code  = buf_goods.prod-code
                                           and buf_parts.obj-type   = v-cntxt-obj-type
                                           and buf_parts.obj-code   = v-cntxt-obj-code
                                           and buf_parts.out-code   = 'free-zone':U
                                           and num-entries(buf_parts.alc-ref-ab-path) = 4
                                           and entry(3, buf_parts.alc-ref-ab-path) = tt-gds-rests_shop.alc-code :
                assign tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.fact-qnty .
            end.
        end.
        for each tt-gds-rests no-lock where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code :
            assign tt-gds-rests_shop.egais-qnty_stock = tt-gds-rests_shop.egais-qnty_stock + tt-gds-rests.egais-qnty .
        end.
        find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                 and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                 no-error.
        if not available tt-gds-list
        then do :
            create tt-gds-list.
            assign
                tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
            .
        end.
    end.
    OPEN QUERY br-rests_shop FOR each tt-gds-list, EACH tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                            and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code .
    apply "value-changed" to br-rests_shop .
    run waitfram-hide in this-procedure no-error .
    v-DT-rests_shop = substring(replace(rests_shop:v-date-time, "T", " "), 1, length(rests_shop:v-date-time) - 4) .
    if v-page-current = 2 then display v-DT-rests_shop with FRAME Dialog-Frame.
    run waitfram-hide in this-procedure .
END.
ON CHOOSE OF menu-item m-writeOff in menu m-func
DO:
    define variable v-awo-num as character no-undo .
    define variable v-awo-date as date no-undo .
    define variable v-awo-type as character no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.
    empty temp-table tt-gds-act .
    run bge/egais-makeWriteOff.w  (input parparentproc,
                                   output v-awo-num,
                                   output v-awo-date,
                                   output v-awo-type,
                                   output v-ok) .
    if not v-ok then return no-apply .
    create tt-act-header.
    assign
        tt-act-header.num   = v-awo-num
        tt-act-header.date_ = v-awo-date
        tt-act-header.type_ = v-awo-type
        tt-act-header.is-sent = no
        v-position = 0
    .
    do ii = 1 to num-entries(select-list) :
        v-sel-entry = entry(ii, select-list) .
        for first tt-gds-rests exclusive-lock where recid(tt-gds-rests) = integer(v-sel-entry) :
            assign v-position = v-position + 1 .
            create tt-gds-act.
            assign
                tt-gds-act.num          = tt-act-header.num
                tt-gds-act.position_    = v-position
                tt-gds-act.alc-code     = tt-gds-rests.alc-code
                tt-gds-act.gds-code     = tt-gds-rests.gds-code
                tt-gds-act.gds-name     = tt-gds-rests.gds-name
                tt-gds-act.inform-B     = tt-gds-rests.informB_
                tt-gds-act.qnty         = tt-gds-rests.egais-qnty - tt-gds-rests.TH-qnty
            .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-rests.gds-code no-error .
            if available buf_goods
            and (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then do :
                tt-gds-act.qnty = tt-gds-act.qnty / buf_goods.cli-base-rate .
            end.
        end.
    end.
    run makeXML in this-procedure .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header.num + chr(4) + string(tt-act-header.date_) + chr(4) + tt-act-header.type_ + chr(4) + string(tt-act-header.is-sent) + chr(4) + tt-act-header.answer_
    .
    run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                          ,input ",yes"
                          ,input ?
                          ,input tt-act-header.num
                          ,input 'egais-awo':U
                          ,input v-info
                          ,input-output v-part-num
                          ,input 'egais-awo':U
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input search (v-file)
                          ,input ''
                          ) no-error .
    message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Акты о списании товаров'" view-as alert-box .
END.
ON CHOOSE OF menu-item m-writeOff_shop in menu m-func_shop
DO:
    define variable v-awos-num as character no-undo .
    define variable v-awos-date as date no-undo .
    define variable v-awos-type as character no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    if select-list_shop = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.
    empty temp-table tt-gds-act-awos .
    run bge/egais-makeWriteOff.w  (input parparentproc,
                                   output v-awos-num,
                                   output v-awos-date,
                                   output v-awos-type,
                                   output v-ok) .
    if not v-ok then return no-apply .
    create tt-act-header-awos.
    assign
        tt-act-header-awos.num   = substring(v-awos-num, 1, 3) + "S" + substring(v-awos-num, 4)
        tt-act-header-awos.date_ = v-awos-date
        tt-act-header-awos.type_ = v-awos-type
        tt-act-header-awos.is-sent = no
        v-position = 0
    .
    do ii = 1 to num-entries(select-list_shop) :
        v-sel-entry = entry(ii, select-list_shop) .
        for first tt-gds-rests_shop exclusive-lock where recid(tt-gds-rests_shop) = integer(v-sel-entry) :
            assign v-position = v-position + 1 .
            create tt-gds-act-awos.
            assign
                tt-gds-act-awos.num          = tt-act-header-awos.num
                tt-gds-act-awos.position_    = v-position
                tt-gds-act-awos.alc-code     = tt-gds-rests_shop.alc-code
                tt-gds-act-awos.gds-name     = tt-gds-rests_shop.gds-name
                tt-gds-act-awos.qnty         = tt-gds-rests_shop.egais-qnty - tt-gds-rests_shop.TH-qnty
            .
            tt-gds-act-awos.gds-code     = integer(tt-gds-rests_shop.gds-code) no-error .
            find first buf_goods no-lock where buf_goods.gds-code = integer(tt-gds-rests_shop.gds-code) no-error .
            if available buf_goods
            and (not tt-gds-rests_shop.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then do :
                tt-gds-act-awos.qnty = tt-gds-act-awos.qnty / buf_goods.cli-base-rate .
            end.
        end.
    end.
    run makeXML-awos in this-procedure .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header-awos.num + chr(4) + string(tt-act-header-awos.date_) + chr(4) + tt-act-header-awos.type_ + chr(4) + string(tt-act-header-awos.is-sent) + chr(4) + tt-act-header-awos.answer_
    .
    run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                          ,input ",yes"
                          ,input ?
                          ,input tt-act-header-awos.num
                          ,input 'egais-awo_shop':U
                          ,input v-info
                          ,input-output v-part-num
                          ,input 'egais-awo_shop':U
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input search (v-file-awos)
                          ,input ''
                          ) no-error .
    message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Акты о списании товаров из торгового зала'" view-as alert-box .
END.
ON CHOOSE OF menu-item m-tts in menu m-func
DO:
    define variable v-tts-num as character no-undo .
    define variable v-tts-date as date no-undo .
    define variable v-tts-type as character no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    empty temp-table tt-gds-act-tts .
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.
    run bge/egais-makeTTS.w  (input parparentproc,
                               output v-tts-num,
                               output v-tts-date,
                               output v-ok) .
    if not v-ok then return no-apply .
    create tt-act-header-tts.
    assign
        tt-act-header-tts.num   = v-tts-num
        tt-act-header-tts.date_ = v-tts-date
        tt-act-header-tts.is-sent = no
        v-position = 0
    .
    do ii = 1 to num-entries(select-list) :
        v-sel-entry = entry(ii, select-list) .
        for first tt-gds-rests exclusive-lock where recid(tt-gds-rests) = integer(v-sel-entry) :
            assign v-position = v-position + 1 .
            create tt-gds-act-tts.
            assign
                tt-gds-act-tts.num          = tt-act-header-tts.num
                tt-gds-act-tts.position_    = v-position
                tt-gds-act-tts.alc-code     = tt-gds-rests.alc-code
                tt-gds-act-tts.gds-code     = tt-gds-rests.gds-code
                tt-gds-act-tts.gds-name     = tt-gds-rests.gds-name
                tt-gds-act-tts.inform-B     = tt-gds-rests.informB_
                tt-gds-act-tts.qnty         = tt-gds-rests.egais-qnty
            .
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-rests.gds-code no-error .
            if available buf_goods
            and (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then do :
                tt-gds-act-tts.qnty = tt-gds-act-tts.qnty / buf_goods.cli-base-rate .
            end.
        end.
    end.
    run makeXML-tts in this-procedure .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header-tts.num + chr(4) + string(tt-act-header-tts.date_) + chr(4) + string(tt-act-header-tts.is-sent) + chr(4) + tt-act-header-tts.answer_
    .
    run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                          ,input ",yes"
                          ,input ?
                          ,input tt-act-header-tts.num
                          ,input 'egais-tts':U
                          ,input v-info
                          ,input-output v-part-num
                          ,input 'egais-tts':U
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input search (v-file-tts)
                          ,input ''
                          ) no-error .
    message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Передача продукции в торговый зал'" view-as alert-box .
END.
ON CHOOSE OF menu-item m-print in menu m-func
OR CHOOSE OF menu-item m-print in menu m-func_shop
DO:
    find first tt-gds-rests no-lock no-error .
    if not available tt-gds-rests
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run PrintRests.
END.
ON CHOOSE OF menu-item m-print_shop in menu m-func
OR CHOOSE OF menu-item m-print_shop in menu m-func_shop
DO:
    find first tt-gds-rests no-lock no-error .
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop and available tt-gds-rests
    then do :
        message "Нет остатков по второму регистру (магазину)" view-as alert-box .
        return no-apply .
    end.
    if not available tt-gds-rests_shop and not available tt-gds-rests
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run PrintRests_shop.
END.
ON CHOOSE OF menu-item m-compare in menu m-func_shop
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run CompareRests.
END.
ON CHOOSE OF menu-item m-marks-compare in menu m-func_shop
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run MarksCompareRests.
END.
ON CHOOSE OF menu-item m-list in menu m-func_shop
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run ListView.
    OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                            and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code .
END.
ON CHOOSE OF menu-item m-all in menu m-func_shop
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    empty temp-table tt-gds-list .
    for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" :
        find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                 and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                 no-error.
        if not available tt-gds-list
        then do :
            create tt-gds-list.
            assign
                tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
            .
        end.
    end.
    OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                            and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                            and tt-gds-rests_shop.egais-qnty <> 0 .
END.
ON CHOOSE OF menu-item m-load-all in menu m-func
OR CHOOSE OF menu-item m-load-all in menu m-func_shop
DO:
    v-num-objs = 0 .
    empty temp-table tt-obj-list .
    for each thbj-attr no-lock where thbj-attr.upper-prop-code = 'egais':U
                                 and thbj-attr.prop-code = 'egais-fsrar':U :
        if thbj-attr.obj-code <> 0
        then do :
            create tt-obj-list .
            assign
                tt-obj-list.obj-type = thbj-attr.obj-type
                tt-obj-list.obj-code = thbj-attr.obj-code
            .
            find first buf_clients no-lock where buf_clients.obj-type = tt-obj-list.obj-type and buf_clients.obj-code = tt-obj-list.obj-code.
            find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code .
            assign tt-obj-list.inn = buf_firm.inn .
            v-num-objs = v-num-objs + 1 .
        end.
    end.
    v-num-loads = 0 .
    for each tt-obj-list no-lock :
          empty temp-table thbjattr_thbj-attr .
          run adm/shattri.p (
               input "get":U
              ,input tt-obj-list.obj-type
              ,input tt-obj-list.obj-code
              ,input 'egais':U
              ,input 'egais-fsrar':U
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-value-type
              ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
              ) no-error .
          assign
            v-fs-rar-list = v-value-character
          .
          rests = new Rests(tt-obj-list.obj-type, tt-obj-list.obj-code, v-fs-rar-list, tt-obj-list.inn) .
          rests:DbNum = v-cntxt-db-num .
          rests:User_Id = v-cntxt-userid .
          rests_shop = new Rests_shop(tt-obj-list.obj-type, tt-obj-list.obj-code, v-fs-rar-list, tt-obj-list.inn) .
          rests_shop:DbNum = v-cntxt-db-num .
          rests_shop:User_Id = v-cntxt-userid .
          rests:SendRequestUTM() .
          rests_shop:SendRequestUTM() .
          glog = rests_shop:IsSent .
          if glog and v-cntxt-obj-type = tt-obj-list.obj-type
                  and v-cntxt-obj-code = tt-obj-list.obj-code
          then enable b-answer WITH FRAME Dialog-Frame.
          else disable b-answer WITH FRAME Dialog-Frame .
          glog = rests_shop:StatusErr .
          if glog then do :
              message tt-obj-list.obj-type string(tt-obj-list.obj-code) skip rests_shop:Msg view-as alert-box.
              next.
          end.
          v-num-loads = v-num-loads + 1 .
    end.
    rests = new Rests(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
    rests:DbNum = v-cntxt-db-num .
    rests:User_Id = v-cntxt-userid .
    rests_shop = new Rests_shop(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
    rests_shop:DbNum = v-cntxt-db-num .
    rests_shop:User_Id = v-cntxt-userid .
    message "Отправлен запрос остатков на " string(v-num-loads) " из " string(v-num-objs) " объектах" view-as alert-box.
END.
ON CHOOSE OF menu-item m-file in menu m-func
OR CHOOSE OF menu-item m-file in menu m-func_shop
DO:
    if search(v-fn-rests) = ? and search(v-fn-rests_shop) = ?
    then do :
        message "Не найдены файлы с последними остатками из ЕГАИС" view-as alert-box .
        return no-apply.
    end.
    else if search(v-fn-rests) = ?
    then do :
        message "Не найден файл с последними остатками на Складе из ЕГАИС" skip
                "Будут загружены остатки в Магазине" view-as alert-box .
    end.
    else if search(v-fn-rests_shop) = ?
    then do :
        message "Не найден файл с последними остатками в Магазине из ЕГАИС" skip
                "Будут загружены остатки на Складе" view-as alert-box .
    end.
    if search(v-fn-rests) <> ?
    then do :
        run waitfram-show in this-procedure ("Ждите...") .
        empty temp-table tt-gds-rests .
        bh-gds-egais = rests:ParseResponse(v-fn-rests) .
        glog = rests:StatusErr .
        if glog then do :
            run waitfram-hide in this-procedure no-error .
            message rests:Msg view-as alert-box.
            return no-apply.
        end.
        if not valid-handle(bh-gds-egais) then do :
            run waitfram-hide in this-procedure no-error .
            message "Ошибка при загрузке остатков на Складе ЕГАИС" view-as alert-box error .
            return no-apply .
        end.
        create query qh-gds-egais .
        qh-gds-egais:set-buffers (bh-gds-egais) .
        qh-gds-egais:query-prepare ("for each tt-gds-rests-eg").
        qh-gds-egais:query-open.
        _repeat:
        repeat:
            qh-gds-egais:get-next ().
            if qh-gds-egais:query-off-end then leave _repeat.
            create tt-gds-rests.
            buffer tt-gds-rests:handle:buffer-copy (bh-gds-egais) .
            assign tt-gds-rests.fromEgais = yes no-error.
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.key#_two = v-ext-sys
                                               and X_ext-classif.key#_three = 0
                                               and X_ext-classif.charkey_one = tt-gds-rests.alc-code
                                               and X_ext-classif.charkey_two = ""
                                               and X_ext-classif.charkey_three = ""
                                               and X_ext-classif.nonunique = 0
                                               no-error.
            if available X_ext-classif then do :
                find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
                assign
                    tt-gds-rests.gds-code   = buf_goods.gds-code
                    tt-gds-rests.gds-name   = buf_goods.gds-name
                no-error .
            end.
            if available buf_goods then do :
                if (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
                then assign tt-gds-rests.egais-qnty = tt-gds-rests.egais-qnty * buf_goods.cli-base-rate .
                for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                               and buf_parts.prod-type  = buf_goods.prod-type
                                               and buf_parts.prod-code  = buf_goods.prod-code
                                               and buf_parts.obj-type   = v-cntxt-obj-type
                                               and buf_parts.obj-code   = v-cntxt-obj-code
                                               and buf_parts.out-code   = 'free-zone':U
                                               and num-entries(buf_parts.alc-ref-ab-path) = 4
                                               and entry(1, buf_parts.alc-ref-ab-path) = tt-gds-rests.informA_
                                               and entry(2, buf_parts.alc-ref-ab-path) = tt-gds-rests.informB_ :
                    assign tt-gds-rests.TH-qnty = tt-gds-rests.TH-qnty + buf_parts.fact-qnty no-error .
                    assign tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts)) no-error .
                end.
            end.
        end.
        OPEN QUERY br-rests FOR EACH tt-gds-rests .
        apply "value-changed" to br-rests in FRAME Dialog-Frame.
        enable a-n-c with FRAME Dialog-Frame.
        apply "value-changed" to a-n-c in FRAME Dialog-Frame.
        v-DT-rests = substring(replace(rests:v-date-time, "T", " "), 1, length(rests:v-date-time) - 4) .
        if v-page-current = 1 then display v-DT-rests with FRAME Dialog-Frame.
    end.
    if search(v-fn-rests_shop) <> ?
    then do :
        empty temp-table tt-gds-rests_shop .
        empty temp-table tt-gds-list .
        bh-gds-egais_shop = rests_shop:ParseResponse(v-fn-rests_shop) .
        glog = rests_shop:StatusErr .
        if glog then do :
            run waitfram-hide in this-procedure no-error .
            message rests_shop:Msg view-as alert-box.
            return no-apply.
        end.
        if not valid-handle(bh-gds-egais_shop) then do :
            run waitfram-hide in this-procedure no-error .
            message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
            return no-apply .
        end.
        create query qh-gds-egais_shop .
        qh-gds-egais_shop:set-buffers (bh-gds-egais_shop) .
        qh-gds-egais_shop:query-prepare ("for each tt-gds-rests-eg_shop").
        qh-gds-egais_shop:query-open.
        _repeat_shop:
        repeat:
            qh-gds-egais_shop:get-next ().
            if qh-gds-egais_shop:query-off-end then leave _repeat_shop.
            create tt-gds-rests_shop.
            buffer tt-gds-rests_shop:handle:buffer-copy (bh-gds-egais_shop) .
            assign tt-gds-rests_shop.fromEgais = yes .
            for each X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.key#_two = v-ext-sys
                                               and X_ext-classif.key#_three = 0
                                               and X_ext-classif.charkey_one = tt-gds-rests_shop.alc-code
                                               and X_ext-classif.charkey_two = ""
                                               and X_ext-classif.charkey_three = ""
                                               and X_ext-classif.nonunique = 0 :
                find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
                assign
                    tt-gds-rests_shop.gds-code   = if tt-gds-rests_shop.gds-code = "" then string(buf_goods.gds-code) else tt-gds-rests_shop.gds-code + ", " + string(buf_goods.gds-code)
                    tt-gds-rests_shop.gds-name   = buf_goods.gds-name
                .
                if (not tt-gds-rests_shop.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
                then assign tt-gds-rests_shop.egais-qnty = tt-gds-rests_shop.egais-qnty * buf_goods.cli-base-rate .
                for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                               and buf_parts.prod-type  = buf_goods.prod-type
                                               and buf_parts.prod-code  = buf_goods.prod-code
                                               and buf_parts.obj-type   = v-cntxt-obj-type
                                               and buf_parts.obj-code   = v-cntxt-obj-code
                                               and buf_parts.out-code   = 'free-zone':U
                                               and num-entries(buf_parts.alc-ref-ab-path) = 4
                                               and entry(3, buf_parts.alc-ref-ab-path) = tt-gds-rests_shop.alc-code :
                    assign tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.fact-qnty .
                end.
            end.
            for each tt-gds-rests no-lock where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code :
                assign tt-gds-rests_shop.egais-qnty_stock = tt-gds-rests_shop.egais-qnty_stock + tt-gds-rests.egais-qnty .
            end.
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        OPEN QUERY br-rests_shop FOR each tt-gds-list, EACH tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code .
        apply "value-changed" to br-rests_shop in FRAME Dialog-Frame.
        run waitfram-hide in this-procedure no-error .
        v-DT-rests_shop = substring(replace(rests_shop:v-date-time, "T", " "), 1, length(rests_shop:v-date-time) - 4) .
        if v-page-current = 2 then display v-DT-rests_shop with FRAME Dialog-Frame.
    end.
    run waitfram-hide in this-procedure .
END.
ON 'right-mouse-down':U of br-rests_all
DO:
    RUN set_focus (SELF).
    IF SELF:TYPE = 'BROWSE' THEN DO:
        RETURN NO-APPLY.
    END.
    ELSE DO:
        APPLY 'menu-drop' TO SELF.
    END.
END.
ON 'right-mouse-down':U of br-rests
DO:
    RUN set_focus (SELF).
    IF SELF:TYPE = 'BROWSE' THEN DO:
        RETURN NO-APPLY.
    END.
    ELSE DO:
        APPLY 'menu-drop' TO SELF.
    END.
END.
PROCEDURE set_focus.
DEF INPUT PARAM i_object            AS HANDLE   NO-UNDO.
DEF VAR l_was_row_one_selected      AS LOG      NO-UNDO.
DEF VAR l_header_y                  AS DEC      NO-UNDO.
DEF VAR w_browse_title_bar_height   AS DEC      NO-UNDO INITIAL 19.
DEF VAR o_labels                    AS CHAR     NO-UNDO.
DEF VAR o_procedures                AS CHAR     NO-UNDO.
DEF VAR h_menu                      AS HANDLE   NO-UNDO.
DEF VAR h_menu_item                 AS HANDLE   NO-UNDO.
DEF VAR l_count                     AS INT      NO-UNDO.
    IF i_object:TYPE = 'browse' THEN DO:
        IF i_object:NUM-SELECTED-ROWS = 0
            THEN ASSIGN l_was_row_one_selected = FALSE.
            ELSE ASSIGN l_was_row_one_selected = i_object:IS-ROW-SELECTED(1) NO-ERROR.
        i_object:SELECT-ROW(1) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN RETURN.
        l_header_y = MAX(1,i_object:FIRST-COLUMN:Y).
        IF i_object:TITLE <> ? THEN l_header_y = l_header_y - w_browse_title_bar_height.
        IF l_was_row_one_selected = FALSE THEN i_object:DESELECT-SELECTED-ROW(1) NO-ERROR.
        i_object:SELECT-ROW(
            INT(
                1 +
                TRUNC(
                      (LAST-EVENT:Y - l_header_y) / i_object:FIRST-COLUMN:HEIGHT-PIXELS
                     ,0)
                )
            )
            NO-ERROR.
        APPLY 'ENTRY':u TO i_object.
        APPLY 'VALUE-CHANGED':u TO i_object.
        o_labels = "Добавить в акт о передаче продукции в торговый зал" .
        h_menu = i_object:POPUP-MENU NO-ERROR.
        IF VALID-HANDLE(h_menu) THEN RETURN.
        CREATE MENU h_menu.
        ASSIGN
            h_menu:POPUP-ONLY   = TRUE
            i_object:POPUP-MENU = h_menu
            .
        CREATE MENU-ITEM h_menu_item
            ASSIGN
                PARENT      = h_menu
                LABEL       = o_labels
                SENSITIVE   = TRUE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN make-TTS IN THIS-PROCEDURE.
            END TRIGGERS.
    END.
    IF VALID-HANDLE(h_menu)
        THEN APPLY 'menu-drop' TO h_menu.
END PROCEDURE.
on value-changed of br-rests IN FRAME Dialog-Frame
DO:
    if available tt-gds-rests then do :
        if trim(tt-gds-rests.prt-rec) = "" then disable b-del with frame Dialog-Frame .
        else enable b-del with frame Dialog-Frame .
    end.
    if not available tt-gds-rests or recid(tt-gds-rests) <> tt-rec then do :
        hide loc-alc in frame Dialog-Frame.
        loc-alc = "".
    end.
end.
on value-changed of br-rests_shop IN FRAME Dialog-Frame
DO:
    if available tt-gds-rests_shop then do :
        OPEN QUERY br-rests_all FOR EACH tt-gds-rests where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code .
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  v-page-current = 1.
  v-section-names = "Склад|Магазин".
  assign
    b-func:popup-menu in frame Dialog-Frame = menu m-func:handle
    b-func:menu-mouse = 1
    b-func_shop:popup-menu in frame Dialog-Frame = menu m-func_shop:handle
    b-func_shop:menu-mouse = 1
  .
  find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = v-cntxt-host-code-obj.
  find first buf_firm no-lock where buf_firm.firm-code = v-cntxt-host-code-obj.
  if valid-handle(bh-gds-egais) then do :
      delete object bh-gds-egais .
  end.
  if valid-handle(qh-gds-egais) then do :
      delete object qh-gds-egais .
  end.
    if valid-handle(bh-gds-egais_shop) then do :
      delete object bh-gds-egais_shop .
  end.
  if valid-handle(qh-gds-egais_shop) then do :
      delete object qh-gds-egais_shop .
  end.
  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'egais':U
      ,input 'egais-fsrar':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign
    v-org = buf_clients.obj-name
    v-fs-rar = v-value-character
    v-org-inn = buf_firm.inn
  .
  display v-fs-rar format "X(30)" with frame Dialog-Frame.
  run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input 'egais':U
      ,input 'egais-exsys':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer .
  release buf_clients .
  rests = new Rests(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
  rests:DbNum = v-cntxt-db-num .
  rests:User_Id = v-cntxt-userid .
  rests_shop = new Rests_shop(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
  rests_shop:DbNum = v-cntxt-db-num .
  rests_shop:User_Id = v-cntxt-userid .
  run set-size(input frame Dialog-Frame:height-pixels - 182, input frame Dialog-Frame:width-pixels - 40).
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-rests :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
  run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-rests_shop :handle
  ) .
  run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-rests_all :handle
  ) .
  run diasize_init in this-procedure .
  RUN enable_UI.
  hide br-rests_shop br-rests_all t-negative_rests t-not_eq_rests v-DT-rests_shop b-func_shop in frame Dialog-Frame.
  v-fn-rests = "Rests-" + v-fs-rar + ".xml" .
  v-fn-rests_shop = "Rests_Shop-" + v-fs-rar + ".xml" .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE proc-b-mark :
  define variable varlog as logical   no-undo .
  if not available tt-gds-rests then return.
  run local-mark in this-procedure.
  assign varlog = br-rests :select-next-row( ) in frame Dialog-Frame.
  apply "ENTRY":U to br-rests in frame Dialog-Frame.
  br-rests:refresh() in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-mark_shop :
  define variable varlog as logical   no-undo .
  if not available tt-gds-rests_shop then return.
  run local-mark_shop in this-procedure.
  assign varlog = br-rests_shop :select-next-row( ) in frame Dialog-Frame.
  apply "ENTRY":U to br-rests_shop in frame Dialog-Frame.
  br-rests_shop:refresh() in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE local-mark :
  if not available tt-gds-rests then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid20 as character no-undo .
define variable v-num-entry20 as integer   no-undo .
assign
  v-str-recid20 = trim( string( recid( tt-gds-rests ) , "->>>>>>>>>>>9":U ) )
  v-num-entry20 = lookup( v-str-recid20 , select-list )
.
if v-num-entry20 > 0 then do:
  assign
    entry( v-num-entry20, select-list ) = "":U
    select-list = trim( replace( select-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    select-list = select-list + ( if select-list = "":U then "":U else chr(44) ) + v-str-recid20
  .
end.
  br-rests:refresh() in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE local-mark_shop :
  if not available tt-gds-rests_shop then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid22 as character no-undo .
define variable v-num-entry22 as integer   no-undo .
assign
  v-str-recid22 = trim( string( recid( tt-gds-rests_shop ) , "->>>>>>>>>>>9":U ) )
  v-num-entry22 = lookup( v-str-recid22 , select-list_shop )
.
if v-num-entry22 > 0 then do:
  assign
    entry( v-num-entry22, select-list_shop ) = "":U
    select-list_shop = trim( replace( select-list_shop , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    select-list_shop = select-list_shop + ( if select-list_shop = "":U then "":U else chr(44) ) + v-str-recid22
  .
end.
  br-rests_shop:refresh() in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE initialize-folder :
  define input parameter folder-labels as character no-undo.
  define variable i             as integer   no-undo.
  define variable temp-hdl      as handle    no-undo.
  define variable del-hdl       as handle    no-undo.
  define variable rebuild       as logical   no-undo init no.
  define variable sts           as logical   no-undo.
  assign
    tab-type = 1 .
  assign
    number-of-pages = num-entries(folder-labels,'|':U).
  if valid-handle(up-image) then
  do:
    temp-hdl = frame Dialog-Frame:HANDLE.
    temp-hdl = temp-hdl:first-child.
    temp-hdl = temp-hdl:first-child.
    do while valid-handle(temp-hdl):
      del-hdl = temp-hdl.
      temp-hdl = temp-hdl:next-sibling.
      if del-hdl:private-data = "Tab-Folder":U then delete widget del-hdl.
    end.
  end.
  create image up-image
    assign
    frame             = frame Dialog-Frame:HANDLE
    x                 = 0 + pos-x
    y                 = 0 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = 25 + 4
    private-data      = "Tab-Folder":U
    hidden            = no.
  assign
    sts = up-image:load-image("adeicon/ts-up":U +
         STRING(width-tab-values[tab-type])).
  do i = 1 to number-of-pages:
    if entry(i,folder-labels,'|':U) ne "":U then
      run create-folder-label (i, entry(i, folder-labels,'|':U)).
  end.
  view frame Dialog-Frame.
  run change-folder-page.
  return.
end procedure.
PROCEDURE change-folder-page :
  define variable sts   as logical no-undo.
  define variable page# as integer no-undo.
  if page# > 0 and page# <= 2 and
    VALID-HANDLE (page-label[page#]) then
  do:
    assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4
      up-image:hidden = no
      sts             = up-image:move-to-top().
  end.
  return.
end procedure.
PROCEDURE create-folder-label :
  define input parameter p-page#        as integer   no-undo.
  define input parameter p-page-label   as character no-undo.
  define variable sts as log no-undo.
  create image image-hdl[p-page#]
    assign
    frame             = frame Dialog-Frame:HANDLE
    x                 = (p-page# - 1) * width-tab-values[tab-type] + pos-x
    y                 = 2 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = 25
    private-data      = "Tab-Folder":U
    sensitive         = yes
    triggers:
      on mouse-select-click
        persistent run label-trigger in THIS-PROCEDURE (p-page#).
    end triggers.
  create text page-label[p-page#]
    assign
    frame             = frame Dialog-Frame:HANDLE
    y                 = image-hdl[p-page#]:y + 2
    x                 = image-hdl[p-page#]:x + 9
    width-pixel       = image-hdl[p-page#]:WIDTH-PIXEL - 18
    height-pixel      = image-hdl[p-page#]:HEIGHT-PIXEL - 4
    format            = "X(13)":U
    sensitive         = yes
    font              = if tab-type = 1 then ? else 4
    bgcolor           = 8
    screen-value      = p-page-label
    private-data      = "Tab-Folder":U
    triggers:
      on mouse-select-click
        persistent run label-trigger in THIS-PROCEDURE (p-page#).
    end triggers.
  assign
    sts = image-hdl[p-page#]:load-image("adeicon/ts-dn":U +
                STRING(width-tab-values[tab-type])).
  sts = image-hdl[p-page#]:move-to-top().
  sts = page-label[p-page#]:move-to-top().
  assign
    page-enabled[p-page#]      = yes
    image-hdl[p-page#]:hidden  = no
    page-label[p-page#]:hidden = no.
  return.
end procedure.
PROCEDURE create-folder-page :
  define input parameter p-page#      as integer   no-undo.
  define input parameter p-new-label  as character no-undo.
  define variable i          as integer   no-undo.
  define variable num-labels as integer   no-undo.
  define variable labels     as character no-undo.
  define variable new-labels as character no-undo init "".
  run get-attribute ('FOLDER-LABELS':U).
  assign
    labels = return-value.
  if labels = ? then labels = "".
  num-labels = num-entries(labels,'|':U).
  if p-page# <= num-labels then
  do i = 1 to num-labels:
    new-labels = new-labels +
      if i = p-page# then p-new-label
      else entry(i, labels, '|':U).
    if i < num-labels then new-labels = new-labels + '|':U.
  end.
  else
  do:
    new-labels = labels.
    do i = 1 to p-page# - num-labels - if num-labels = 0 then 1 else 0:
      new-labels = new-labels + '|':U.
    end.
    new-labels = new-labels + p-new-label.
  end.
  run set-attribute-list in THIS-PROCEDURE
    ('FOLDER-LABELS = ':U + new-labels).
  run initialize-folder.
  return.
end procedure.
PROCEDURE delete-folder-page :
  define input parameter p-page#  as integer no-undo.
  define variable i      as integer   no-undo.
  define variable pos1   as integer   no-undo init 0.
  define variable pos2   as integer   no-undo.
  define variable labels as character no-undo.
  run get-attribute ('FOLDER-LABELS':U).
  assign
    labels = return-value.
  if valid-handle (page-label[p-page#]) then
    delete widget page-label[p-page#].
  if valid-handle (image-hdl[p-page#]) then
    delete widget image-hdl[p-page#].
  do i = 1 to p-page# - 1:
    pos1 = index(labels,'|':U, pos1 + 1).
  end.
  pos2 = index(labels,'|':U, pos1 + 1).
  labels = if pos2 ne 0 then SUBSTR(labels, 1, pos1, "CHARACTER":U) +
    SUBSTR(labels, pos2, -1, "CHARACTER":U)
    else SUBSTR(labels, 1, pos1 - 1, "CHARACTER":U).
  run set-attribute-list in THIS-PROCEDURE
    ('FOLDER-LABELS = ':U + labels).
  return.
end procedure.
PROCEDURE disable-folder-page :
  define input parameter p-page#  as integer no-undo.
  assign
    page-enabled[p-page#]       = no
    page-label[p-page#]:fgcolor = 7.
  return.
end procedure.
PROCEDURE enable-folder-page :
  define input parameter p-page#  as integer no-undo.
  assign
    page-enabled[p-page#]       = yes
    page-label[p-page#]:fgcolor = ?.
  return.
end procedure.
PROCEDURE label-trigger :
  define input parameter p-page# as integer no-undo.
  v-page = p-page#.
  run trg-folder in this-procedure no-error.
  if error-status:error
    then return.
  run show-current-page(input p-page#).
  return.
end procedure.
PROCEDURE local-initialize :
  run initialize-folder.
  run dispatch in THIS-PROCEDURE ('initialize':U).
  return.
end procedure.
PROCEDURE set-size :
  define input parameter p-height as decimal no-undo.
  define input parameter p-width  as decimal no-undo.
  define variable sts as logical.
  if p-height < 1.35 then p-height = 1.35.
  do with frame Dialog-Frame:
    assign
      Rect-Main:X               = 0 + pos-x
      Rect-Main:Y               = 25 + pos-y
      Rect-Main:WIDTH-PIXELS    = p-width
      Rect-Main:HEIGHT-PIXELS   = p-height
                                     - 25
      Rect-Top:X                = 1 + pos-x
      Rect-Top:Y                = 25 + 1 + pos-y
      Rect-Top:WIDTH-PIXELS     = p-width
                                     - 3
      Rect-Top:HEIGHT-PIXELS    = 3
      Rect-Bottom:X             = 1 + pos-x
      Rect-Bottom:Y             = p-height - 4 + pos-y
      Rect-Bottom:HEIGHT-PIXELS = 3
      Rect-Bottom:WIDTH-PIXELS  = p-width
                                     - 2
      Rect-Left:X               = 1 + pos-x
      Rect-Left:Y               = 25 + 1 + pos-y
      Rect-Left:WIDTH-PIXELS    = 3
      Rect-Left:HEIGHT-PIXELS   = p-height
                                     - 25 - 2
      Rect-Right:X              = p-width + pos-x
                                     - 4
      Rect-Right:Y              = 25 + 4 + pos-y
      Rect-Right:WIDTH-PIXELS   = 3
      Rect-Right:HEIGHT-PIXELS  = p-height
                                     - 25 - 5
      Rect-Main:HIDDEN          = no
      Rect-Top:HIDDEN           = no
      Rect-Bottom:HIDDEN        = no
      Rect-Left:HIDDEN          = no
      Rect-Right:HIDDEN         = no.
  end.
  return.
end procedure.
PROCEDURE show-current-page :
  define input parameter page# as integer no-undo.
  define variable sts as logical no-undo.
  if page# > 0 and page# <= 2 and
    VALID-HANDLE (page-label[page#])
    then assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4
      up-image:hidden = no
      sts             = up-image:move-to-top().
  else if number-of-pages > 0 then
      assign up-image:hidden = yes.
end procedure.
PROCEDURE state-changed :
  define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.
PROCEDURE trg-folder :
  v-page-current = v-page.
  assign NameContext = "" loc-code = "" loc-alc = ""  .
  loc-alc:screen-value in frame Dialog-Frame = ""  .
  if v-page-current = 1 then do :
    display b-save b-connect b-del br-rests v-DT-rests b-func with frame Dialog-Frame.
    hide br-rests_shop br-rests_all t-negative_rests t-not_eq_rests v-DT-rests_shop b-func_shop in frame Dialog-Frame.
  end.
  else
  if v-page-current = 2 then do :
    display br-rests_shop br-rests_all t-negative_rests t-not_eq_rests v-DT-rests_shop b-func_shop with frame Dialog-Frame.
    hide b-save b-connect b-del br-rests v-DT-rests b-func in frame Dialog-Frame.
  end.
end.
procedure make-tts.
    define variable v-tts-num as character no-undo .
    define variable v-tts-date as date no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    define variable v-sent as character no-undo .
    define variable v-rec-clob as recid no-undo .
    define buffer buf_clob-bind for ub.clob-bind.
    define buffer buf_clob-data for ub.clob-data.
    if not available tt-gds-rests then do :
        message "Ошибка при выборе строки" view-as alert-box.
        return no-apply.
    end.
    clob_ :
    for each buf_clob-bind where buf_clob-bind.field-name_ = 'egais-tts':U
                             and buf_clob-bind.part-num = 1 and entry(1, buf_clob-bind.descr, chr(4)) matches "*" + substring(v-cntxt-obj-type,1,1) + string(v-cntxt-obj-code) + "*"
                             break by sys-date descending by sys-time descending :
        v-sent =  entry(3, buf_clob-bind.descr, chr(4)).
        if not logical(v-sent)
        then do :
            v-rec-clob = recid(buf_clob-bind) .
            leave clob_ .
        end.
    end.
    find first buf_clob-bind where recid(buf_clob-bind) = v-rec-clob no-error .
    if not available buf_clob-bind
        then do :
        run bge/egais-makeTTS.w  (input parparentproc,
                                       output v-tts-num,
                                       output v-tts-date,
                                       output v-ok) .
        if not v-ok then return no-apply .
        create tt-act-header-tts.
        assign
            tt-act-header-tts.num   = v-tts-num
            tt-act-header-tts.date_ = v-tts-date
            tt-act-header-tts.is-sent = no
            v-position = 0
        .
        assign v-position = v-position + 1 .
        create tt-gds-act-tts.
        assign
            tt-gds-act-tts.num          = tt-act-header-tts.num
            tt-gds-act-tts.position_    = v-position
            tt-gds-act-tts.alc-code     = tt-gds-rests.alc-code
            tt-gds-act-tts.gds-code     = tt-gds-rests.gds-code
            tt-gds-act-tts.gds-name     = tt-gds-rests.gds-name
            tt-gds-act-tts.inform-B     = tt-gds-rests.informB_
            tt-gds-act-tts.qnty         = tt-gds-rests.egais-qnty
        .
        run makeXML-tts in this-procedure .
        assign
            v-clob-db-num = ?
            v-int64-id = 0
            v-info = tt-act-header-tts.num + chr(4) + string(tt-act-header-tts.date_) + chr(4) + string(tt-act-header-tts.is-sent) + chr(4) + tt-act-header-tts.answer_
        .
        run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                              ,input ",yes"
                              ,input ?
                              ,input tt-act-header-tts.num
                              ,input 'egais-tts':U
                              ,input v-info
                              ,input-output v-part-num
                              ,input 'egais-tts':U
                              ,input-output v-clob-db-num
                              ,input-output v-int64-id
                              ,input search (v-file-tts)
                              ,input ''
                              ) no-error .
        message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Передача продукции в торговый зал'" view-as alert-box .
    end.
    else do :
        find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id.
        copy-lob
        from  object buf_clob-data.cdata
        to  file 'temp-tts.xml'
        no-convert
        no-error .
        run parseXML-tts in this-procedure (input "temp-tts.xml") .
        v-position = 1 .
        for each tt-gds-act-tts no-lock :
            v-position = v-position + 1 .
        end.
        create tt-gds-act-tts .
        assign
            tt-gds-act-tts.num          = tt-act-header-tts.num
            tt-gds-act-tts.position_    = v-position
            tt-gds-act-tts.alc-code     = tt-gds-rests.alc-code
            tt-gds-act-tts.gds-code     = tt-gds-rests.gds-code
            tt-gds-act-tts.gds-name     = tt-gds-rests.gds-name
            tt-gds-act-tts.inform-B     = tt-gds-rests.informB_
            tt-gds-act-tts.qnty         = tt-gds-rests.egais-qnty
        .
        run makeXML-tts in this-procedure .
        assign
            v-clob-db-num = buf_clob-bind.db-num
            v-int64-id = buf_clob-bind.int64-id
            v-part-num = buf_clob-bind.part-num
            v-info = tt-act-header-tts.num + chr(4) + string(tt-act-header-tts.date_) + chr(4) + string(tt-act-header-tts.is-sent) + chr(4) + tt-act-header-tts.answer_
        .
        run gbl/file2clb.p ( input 'ИЗМЕНЕНИЕ':U
                  ,input "add-new,yes"
                  ,input ?
                  ,input tt-act-header-tts.num
                  ,input 'egais-tts':U
                  ,input v-info
                  ,input-output v-part-num
                  ,input 'egais-tts':U
                  ,input-output v-clob-db-num
                  ,input-output v-int64-id
                  ,input search (v-file-tts)
                  ,input ''
                  ) no-error .
         if error-status:error then message return-value view-as alert-box.
         message "Строка добавлена" view-as alert-box.
    end.
end.
procedure PrintRests_shop :
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + "rpt" +  "egais-rests_shop.html".
    run waitfram-show in this-procedure ( input "Ждите...").
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        substitute(
        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="7" style="front-weight: bold; text-align: center;">Остатки ЕГАИС торговый зал</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС торговый зал</th>
                <th>Остаток ЕГАИС склад</th>
                <th>Остаток TH</th>
                </tr>').
    for each tt-gds-rests_shop no-lock :
        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             </tr>
             </tbody>',
            tt-gds-rests_shop.alc-code,
            tt-gds-rests_shop.gds-name,
            tt-gds-rests_shop.gds-code,
            tt-gds-rests_shop.alc-type-code,
            tt-gds-rests_shop.egais-qnty,
            tt-gds-rests_shop.egais-qnty_stock,
            tt-gds-rests_shop.TH-qnty
            ).
    end.
    run waitfram-hide in this-procedure.
    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
end.
procedure PrintRests :
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + "rpt" +  "egais-rests.html".
    run waitfram-show in this-procedure ( input "Ждите...").
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        substitute(
        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:210px"></td>
                        <td style="width:210px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="8" style="front-weight: bold; text-align: center;">Остатки ЕГАИС склад</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС</th>
                <th>ID справки А</th>
                <th>ID справки Б</th>
                <th>Остаток TH</th>
                </tr>').
    for each tt-gds-rests no-lock:
        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             <td text_wrap="true"> &8 </td>
             </tr>
             </tbody>',
            tt-gds-rests.alc-code,
            tt-gds-rests.gds-name,
            tt-gds-rests.gds-code,
            tt-gds-rests.alc-type-code,
            tt-gds-rests.egais-qnty,
            tt-gds-rests.informA_,
            tt-gds-rests.informB_,
            tt-gds-rests.TH-qnty
            ).
    end.
    run waitfram-hide in this-procedure.
    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
end.
procedure CompareRests :
    define variable v-gds-entry as character no-undo .
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + "rpt" +  "egais-rests_compare.html".
    empty temp-table tt-compare-rests .
    empty temp-table gds-list .
    goods-list = "" .
    run str/gds-list.w ( input parparentproc, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
    for each gds-list no-lock :
        find goods where
             goods.gds-code = gds-list.gds-code
             no-lock no-error.
        if available goods then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid24 as character no-undo .
define variable v-num-entry24 as integer   no-undo .
assign
  v-str-recid24 = trim( string( recid( goods ) , "->>>>>>>>>>>9":U ) )
  v-num-entry24 = lookup( v-str-recid24 , goods-list )
.
if v-num-entry24 > 0 then do:
  assign
    entry( v-num-entry24, goods-list ) = "":U
    goods-list = trim( replace( goods-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    goods-list = goods-list + ( if goods-list = "":U then "":U else chr(44) ) + v-str-recid24
  .
end.
        end.
    end.
    empty temp-table tt-compare-rests .
    run waitfram-show(INPUT "Ждите...") .
    _ii_ :
    do ii = 1 to num-entries(goods-list) :
    v-gds-entry = entry(ii, goods-list) .
    for first buf_goods no-lock where recid(buf_goods) = integer(v-gds-entry) :
        run gds-attr-value(
          buf_goods.gds-code,
          'alcohol-prod':U,
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next _ii_ .
        _parts_ :
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic
                                    and buf_parts.prod-type = buf_goods.prod-type
                                    and buf_parts.prod-code = buf_goods.prod-code
                                    and buf_parts.obj-type = v-cntxt-obj-type
                                    and buf_parts.obj-code = v-cntxt-obj-code
                                    and buf_parts.out-code = 'free-zone':U :
            if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                find first tt-compare-rests exclusive-lock where tt-compare-rests.alc-code = entry(3, buf_parts.alc-ref-ab-path) no-error.
                if not available tt-compare-rests then do :
                    create tt-compare-rests .
                    assign
                        tt-compare-rests.alc-code   = entry(3, buf_parts.alc-ref-ab-path)
                        tt-compare-rests.gds-code   = string(buf_goods.gds-code)
                        tt-compare-rests.gds-name   = buf_goods.gds-name
                    .
                    if entry(4, buf_parts.alc-ref-ab-path) <> "" then tt-compare-rests.alc-type-code = entry(4, buf_parts.alc-ref-ab-path) .
                end.
                assign tt-compare-rests.TH-qnty = tt-compare-rests.TH-qnty + buf_parts.qnty .
            end.
            else do :
                find first tt-compare-rests exclusive-lock where tt-compare-rests.gds-code = string(buf_goods.gds-code)
                                                             and tt-compare-rests.alc-code = "" no-error.
                if not available tt-compare-rests then do :
                    create tt-compare-rests .
                    assign
                        tt-compare-rests.alc-code   = ""
                        tt-compare-rests.gds-code   = string(buf_goods.gds-code)
                        tt-compare-rests.gds-name   = buf_goods.gds-name
                    .
                end.
                assign tt-compare-rests.TH-qnty = tt-compare-rests.TH-qnty + buf_parts.qnty .
            end.
        end.
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.gds-code = string(buf_goods.gds-code)
                                              or num-entries(tt-gds-rests_shop.gds-code) > 1 :
            find first tt-compare-rests exclusive-lock where tt-compare-rests.alc-code = tt-gds-rests_shop.alc-code no-error .
            if not available tt-compare-rests then do :
                create tt-compare-rests .
                assign
                    tt-compare-rests.alc-code   = tt-gds-rests_shop.alc-code
                    tt-compare-rests.gds-code   = tt-gds-rests_shop.gds-code
                    tt-compare-rests.gds-name   = tt-gds-rests_shop.gds-name
                    tt-compare-rests.alc-type-code = tt-gds-rests_shop.alc-type-code
                .
            end.
            assign tt-compare-rests.shop-qnty = tt-gds-rests_shop.egais-qnty .
        end.
        for each tt-gds-rests no-lock where tt-gds-rests.gds-code = buf_goods.gds-code :
            find first tt-compare-rests exclusive-lock where tt-compare-rests.alc-code = tt-gds-rests.alc-code no-error .
            if not available tt-compare-rests then do :
                create tt-compare-rests .
                assign
                    tt-compare-rests.alc-code   = tt-gds-rests.alc-code
                    tt-compare-rests.gds-code   = string(tt-gds-rests.gds-code)
                    tt-compare-rests.gds-name   = tt-gds-rests.gds-name
                    tt-compare-rests.alc-type-code = tt-gds-rests.alc-type-code
                .
            end.
            assign tt-compare-rests.stock-qnty = tt-compare-rests.stock-qnty + tt-gds-rests.egais-qnty .
        end.
    end.
    end.
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        substitute(
        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="7" style="front-weight: bold; text-align: center;">Сверка остатков ЕГАИС</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС торговый зал</th>
                <th>Остаток ЕГАИС склад</th>
                <th>Остаток TH</th>
                </tr>').
    for each tt-compare-rests :
        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             </tr>
             </tbody>',
            tt-compare-rests.alc-code,
            tt-compare-rests.gds-name,
            tt-compare-rests.gds-code,
            tt-compare-rests.alc-type-code,
            tt-compare-rests.shop-qnty,
            tt-compare-rests.stock-qnty,
            tt-compare-rests.TH-qnty
            ).
    end.
    run waitfram-hide in this-procedure.
    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
end.
procedure MarksCompareRests :
    define variable v-gds-entry as character no-undo .
    define variable v-mark      as character no-undo .
    define variable v-alc-code    as character    no-undo .
    define variable v-error-lang  as logical      no-undo .
    define variable l-error         as logical   no-undo INIT NO.
    define variable v-user-action   as character no-undo.
    define variable v-printed       as logical   no-undo.
    define var v-act-file as char no-undo.
    define variable v_os-file   AS CHAR NO-UNDO INIT "".
    define variable ll_commit AS LOG    NO-UNDO INIT NO.
    define variable v-proc-name-err as character no-undo initial 'imp_mark.err'.
    if search (v-proc-name-err) <> ? then
    do:
      os-delete value(v-proc-name-err).
    end.
    v-act-file  = session:temp-directory + "rpt" +  "egais-rests_marks-compare.html".
    empty temp-table tt-marks-compare-rests .
    empty temp-table tt-marks-qnty .
    empty temp-table gds-list .
    goods-list = "" .
    run str/gds-list.w ( input parparentproc, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
    for each gds-list no-lock :
        find goods where
             goods.gds-code = gds-list.gds-code
             no-lock no-error.
        if available goods then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid26 as character no-undo .
define variable v-num-entry26 as integer   no-undo .
assign
  v-str-recid26 = trim( string( recid( goods ) , "->>>>>>>>>>>9":U ) )
  v-num-entry26 = lookup( v-str-recid26 , goods-list )
.
if v-num-entry26 > 0 then do:
  assign
    entry( v-num-entry26, goods-list ) = "":U
    goods-list = trim( replace( goods-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    goods-list = goods-list + ( if goods-list = "":U then "":U else chr(44) ) + v-str-recid26
  .
end.
        end.
    end.
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл с марками"
        FILTERS
          " Все текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".txt"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    run waitfram-show(INPUT "Ждите...") .
    output stream str-err to value(v-proc-name-err) .
    INPUT FROM value(v_os-file).
    REPEAT:
        IMPORT v-mark.
        v-mark = trim(v-mark) .
        run ProcAlcCode  IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang ) no-error.
        if v-error-lang then
        do:
          put stream str-err unformatted
            "Не корректно считана акцизная марка " v-mark ", акцизная марка содержит не допустимые символы или русские буквы."
            skip .
          v-alc-code = "".
          l-error = yes .
        end.
        else
        do:
            find first tt-marks-qnty exclusive-lock where tt-marks-qnty.alc-code = v-alc-code no-error.
            if not available tt-marks-qnty
            then do :
                create tt-marks-qnty .
                assign
                    tt-marks-qnty.alc-code = v-alc-code
                    tt-marks-qnty.qnty = 0
                .
            end.
            tt-marks-qnty.qnty = tt-marks-qnty.qnty + 1 .
        end.
    end.
    INPUT CLOSE.
    output stream str-err close.
    if l-error then
    do:
      if search (v-proc-name-err) <> ? then
      do:
        run gbl/prnfilen.w
          (input  substitute ("Не все марки были загружены")
          ,input  0
          ,input  v-proc-name-err
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
    end.
    _ii_ :
    do ii = 1 to num-entries(goods-list) :
    v-gds-entry = entry(ii, goods-list) .
    for first buf_goods no-lock where recid(buf_goods) = integer(v-gds-entry) :
        run gds-attr-value(
          buf_goods.gds-code,
          'alcohol-prod':U,
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next _ii_ .
        _parts_ :
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic
                                    and buf_parts.prod-type = buf_goods.prod-type
                                    and buf_parts.prod-code = buf_goods.prod-code
                                    and buf_parts.obj-type = v-cntxt-obj-type
                                    and buf_parts.obj-code = v-cntxt-obj-code
                                    and buf_parts.out-code = 'free-zone':U :
            if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                find first tt-marks-compare-rests exclusive-lock where tt-marks-compare-rests.alc-code = entry(3, buf_parts.alc-ref-ab-path) no-error.
                if not available tt-marks-compare-rests then do :
                    create tt-marks-compare-rests .
                    assign
                        tt-marks-compare-rests.alc-code   = entry(3, buf_parts.alc-ref-ab-path)
                        tt-marks-compare-rests.gds-code   = buf_goods.gds-code
                        tt-marks-compare-rests.gds-name   = buf_goods.gds-name
                    .
                    if entry(4, buf_parts.alc-ref-ab-path) <> "" then tt-marks-compare-rests.alc-type-code = entry(4, buf_parts.alc-ref-ab-path) .
                end.
                assign tt-marks-compare-rests.TH-qnty = tt-marks-compare-rests.TH-qnty + buf_parts.qnty .
            end.
            else do :
                find first tt-marks-compare-rests exclusive-lock where tt-marks-compare-rests.gds-code = buf_goods.gds-code
                                                             and tt-marks-compare-rests.alc-code = "" no-error.
                if not available tt-marks-compare-rests then do :
                    create tt-marks-compare-rests .
                    assign
                        tt-marks-compare-rests.alc-code   = ""
                        tt-marks-compare-rests.gds-code   = buf_goods.gds-code
                        tt-marks-compare-rests.gds-name   = buf_goods.gds-name
                    .
                end.
                assign tt-marks-compare-rests.TH-qnty = tt-marks-compare-rests.TH-qnty + buf_parts.qnty .
            end.
        end.
    end.
    end.
    for each tt-marks-qnty no-lock :
        find first tt-marks-compare-rests exclusive-lock where tt-marks-compare-rests.alc-code = tt-marks-qnty.alc-code no-error .
        if not available tt-marks-compare-rests then do :
            create tt-marks-compare-rests .
            assign
                tt-marks-compare-rests.alc-code   = tt-marks-qnty.alc-code
                tt-marks-compare-rests.gds-code   = 0
                tt-marks-compare-rests.gds-name   = ""
                tt-marks-compare-rests.alc-type-code = ""
            .
            for each X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                           and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_ext-classif.charkey_one = tt-marks-compare-rests.alc-code
                                           and X_ext-classif.charkey_two = ""
                                           and X_ext-classif.charkey_three = ""
                                           and X_ext-classif.nonunique = 0 :
                tt-marks-compare-rests.gds-codes = tt-marks-compare-rests.gds-codes + (if tt-marks-compare-rests.gds-codes = "" then "" else ",") + string(X_ext-classif.key#_one) .
            end.
        end.
        assign tt-marks-compare-rests.marks-qnty = tt-marks-qnty.qnty .
    end.
    for each tt-marks-compare-rests exclusive-lock :
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code = tt-marks-compare-rests.alc-code no-error.
        if available tt-gds-rests_shop
        then do :
            assign tt-marks-compare-rests.shop-qnty = tt-gds-rests_shop.egais-qnty .
            assign tt-marks-compare-rests.stock-qnty = tt-gds-rests_shop.egais-qnty_stock .
        end.
    end.
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        substitute(
        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="8" style="front-weight: bold; text-align: center;">Сверка остатков по маркам ЕГАИС</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС торговый зал</th>
                <th>Остаток ЕГАИС склад</th>
                <th>Остаток TH</th>
                <th>Кол-во марок</th>
                </tr>').
    for each tt-marks-compare-rests :
        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             <td text_wrap="true"> &8 </td>
             </tr>
             </tbody>',
            tt-marks-compare-rests.alc-code,
            tt-marks-compare-rests.gds-name,
            (if tt-marks-compare-rests.gds-code <> 0 then string(tt-marks-compare-rests.gds-code) else tt-marks-compare-rests.gds-codes),
            tt-marks-compare-rests.alc-type-code,
            tt-marks-compare-rests.shop-qnty,
            tt-marks-compare-rests.stock-qnty,
            tt-marks-compare-rests.TH-qnty,
            tt-marks-compare-rests.marks-qnty
            ).
    end.
    run waitfram-hide in this-procedure.
    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
end.
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define output parameter p-error as logical no-undo initial no.
  define output parameter p-error-lang as logical no-undo initial no.
  define variable v-kol              as integer    no-undo .
  define variable v-alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  ASSIGN
    v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U .
  v-alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  do ii = 1 to length (v-alc-code):
    if LOOKUP( SUBSTRING( v-alc-code, ii, 1 ), v_list )  < 1 then
    do:
      p-error-lang = yes .
      leave .
    end.
  end.
  p-alc-code = string (Base2Int64 (v-alc-code, 36) ) no-error.
  if (Base2Int64 (v-alc-code, 36) ) < 0 then
  do:
    p-error = yes.
  end.
  else
  do:
    if length(p-alc-code) < 20 then
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.
  end.
END PROCEDURE.
procedure ListView :
    define variable v-gds-entry as character no-undo .
    empty temp-table tt-gds-list .
    empty temp-table gds-list .
    goods-list = "" .
    run str/gds-list.w ( input parparentproc, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
    for each gds-list no-lock :
        find goods where
             goods.gds-code = gds-list.gds-code
             no-lock no-error.
        if available goods then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid28 as character no-undo .
define variable v-num-entry28 as integer   no-undo .
assign
  v-str-recid28 = trim( string( recid( goods ) , "->>>>>>>>>>>9":U ) )
  v-num-entry28 = lookup( v-str-recid28 , goods-list )
.
if v-num-entry28 > 0 then do:
  assign
    entry( v-num-entry28, goods-list ) = "":U
    goods-list = trim( replace( goods-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    goods-list = goods-list + ( if goods-list = "":U then "":U else chr(44) ) + v-str-recid28
  .
end.
        end.
    end.
    _ii_ :
    do ii = 1 to num-entries(goods-list) :
    v-gds-entry = entry(ii, goods-list) .
    for first buf_goods no-lock where recid(buf_goods) = integer(v-gds-entry) :
        run gds-attr-value(
          buf_goods.gds-code,
          'alcohol-prod':U,
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next _ii_ .
        _parts_ :
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic
                                    and buf_parts.prod-type = buf_goods.prod-type
                                    and buf_parts.prod-code = buf_goods.prod-code
                                    and buf_parts.obj-type = v-cntxt-obj-type
                                    and buf_parts.obj-code = v-cntxt-obj-code
                                    and buf_parts.out-code = 'free-zone':U :
            if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                find first tt-gds-list exclusive-lock where tt-gds-list.alc-code = entry(3, buf_parts.alc-ref-ab-path)
                                                        and tt-gds-list.gds-code = string(buf_goods.gds-code) no-error .
                if not available tt-gds-list
                then do :
                    create tt-gds-list.
                    assign
                        tt-gds-list.alc-code = entry(3, buf_parts.alc-ref-ab-path)
                        tt-gds-list.gds-code = string(buf_goods.gds-code)
                    .
                end.
                find first tt-gds-rests_shop exclusive-lock where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                              and tt-gds-rests_shop.in-list <> true no-error.
                if not available tt-gds-rests_shop then do :
                    create tt-gds-rests_shop .
                    assign
                        tt-gds-rests_shop.alc-code   = tt-gds-list.alc-code
                        tt-gds-rests_shop.gds-code   = string(buf_goods.gds-code)
                        tt-gds-rests_shop.gds-name   = buf_goods.gds-name
                        tt-gds-rests_shop.egais-qnty = 0
                        tt-gds-rests_shop.in-list    = true
                    .
                    if entry(4, buf_parts.alc-ref-ab-path) <> "" then tt-gds-rests_shop.alc-type-code = entry(4, buf_parts.alc-ref-ab-path) .
                    for each tt-gds-rests no-lock where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code :
                        tt-gds-rests_shop.egais-qnty_stock = tt-gds-rests_shop.egais-qnty_stock + tt-gds-rests.egais-qnty .
                    end.
                end.
                find first tt-gds-rests_shop exclusive-lock where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                              and tt-gds-rests_shop.in-list  = true no-error.
                if available tt-gds-rests_shop
                then do :
                    tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.qnty .
                end.
            end.
            else do :
                find first tt-gds-list exclusive-lock where tt-gds-list.alc-code = ""
                                                        and tt-gds-list.gds-code = string(buf_goods.gds-code) no-error .
                if not available tt-gds-list
                then do :
                    create tt-gds-list.
                    assign
                        tt-gds-list.alc-code = ""
                        tt-gds-list.gds-code = string(buf_goods.gds-code)
                    .
                end.
                find first tt-gds-rests_shop exclusive-lock where tt-gds-rests_shop.alc-code = ""
                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code no-error.
                if not available tt-gds-rests_shop
                then do :
                    create tt-gds-rests_shop .
                    assign
                        tt-gds-rests_shop.alc-code   = ""
                        tt-gds-rests_shop.gds-code   = string(buf_goods.gds-code)
                        tt-gds-rests_shop.gds-name   = buf_goods.gds-name
                        tt-gds-rests_shop.egais-qnty = 0
                        tt-gds-rests_shop.egais-qnty_stock = 0
                        tt-gds-rests_shop.in-list    = true
                    .
                end.
                tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.qnty .
            end.
        end.
    end.
    end.
end.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-mark b-sel-all b-unmark b-load b-func b-save b-cancel br-rests br-rests_shop br-rests_all
         b-connect b-del b-func t-negative_rests t-not_eq_rests b-func_shop
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  hide NameContext loc-alc loc-code in FRAME Dialog-Frame.
  br-rests:column-resizable in FRAME Dialog-Frame = true .
  br-rests_shop:column-resizable in FRAME Dialog-Frame = true .
  br-rests_all:column-resizable in FRAME Dialog-Frame = true .
  glog = rests:IsSent .
  if glog then enable b-answer WITH FRAME Dialog-Frame.
  OPEN QUERY br-rests FOR EACH tt-gds-rests .
END PROCEDURE.
