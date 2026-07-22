CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Smart browser общения с записями резервуар-ТРК-пистолет".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable varmes-log as logical no-undo.
define variable parparentproc as widget-handle no-undo .
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varbuttons  as   character        no-undo.
define variable varps-upd   as   logical          no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function nzpl-spl returns logical
(input p-obj-type as character
                                , input p-obj-code as integer):
define variable v-dopi    as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-tth as handle no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type2 as character no-undo .
define variable v-value-date2 as date no-undo .
define variable v-value-decimal2 as decimal no-undo .
define variable v-value-integer2 as INTEGER no-undo .
define variable v-value-logical2 AS LOGICAL no-undo .
define variable v-tth2 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date2
    ,output v-value-decimal2
    ,output v-value-integer2
    ,output v-value-logical2
    ,output v-param-type2
    ,INPUT-OUTPUT table-handle v-tth2
    ) no-error .
delete object v-tth2 no-error.
if dflt-cd <> 'IBM':U
and dflt-cd <> 'IBM-XML':U then return no.
if dflt-cd = 'IBM-XML':U then return yes.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-type-ibm':U
    ,input  'ibmspool':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return no.
end.
delete object v-tth.
assign
v-dopi = v-value-integer no-error .
if v-dopi >= 6 then return yes.
end. // FUNCTION/method
FUNCTION nzpl-two returns logical
                                 (input p-obj-type as character
                                  , input p-obj-code as integer):
  define variable v-nzpl-two as logical no-undo.
  run
  nzpl-two-proc (input p-obj-type, input p-obj-code, output v-nzpl-two).
  return v-nzpl-two.
end. // FUNCTION/method
procedure nzpl-two-proc :
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define output parameter varge-two-pl as logical   no-undo.
define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
//do on error undo, return error return-value :
assign
  varge-two-pl = no.
for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = p-obj-type        and
                              bf_pl-gds-pump.obj-code = p-obj-code        and
                              bf_pl-gds-pump.status_  = 'тек':U no-lock on error undo, return error return-value :
  find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                                        bf-other_pl-gds-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                                        bf-other_pl-gds-pump.pump-code =  bf_pl-gds-pump.pump-code and
                                        bf-other_pl-gds-pump.gds-code  =  bf_pl-gds-pump.gds-code  and
                                        bf-other_pl-gds-pump.status_   =  'тек':U        and
                                        bf-other_pl-gds-pump.pl-code   <> bf_pl-gds-pump.pl-code   no-lock no-error.
  if available bf-other_pl-gds-pump then do:
    assign
      varge-two-pl = yes.
    leave.
  end.
end.
//end.
end. // procedure/method .
procedure plpmnzdv:
define input parameter parobj-type    like ub.clients.obj-type   no-undo.
define input parameter parobj-code    like ub.clients.obj-code   no-undo.
define input parameter parpl-code     like ub.place.pl-code      no-undo.
define input parameter parpump-code   like ub.pump.pump-code     no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.
define buffer bf_clients        for ub.clients.
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
define variable varrec-id as recid no-undo.
define variable varmes-log as logical no-undo.
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varbuttons  as   character        no-undo.
define variable varps-upd   as   logical          no-undo.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
run chkcsptr (input parobj-type,
              input parobj-code) no-error.
if error-status:error then return error trim(return-value) +
                                        trim(error-status:get-message(1)) +
                                        trim(error-status:get-message(2)) +
                                        trim(error-status:get-message(3)) +
                                        trim(error-status:get-message(4)) +
                                        trim(error-status:get-message(5)).
tr:
do transaction on error undo tr, return error
               on stop  undo tr, return error
               on quit  undo tr, return error :
   find first bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = parobj-type    and
                                      bf_pl-pump-nozzle.obj-code    = parobj-code    and
                                      bf_pl-pump-nozzle.pl-code     = parpl-code     and
                                      bf_pl-pump-nozzle.pump-code   = parpump-code   and
                                      bf_pl-pump-nozzle.nozzle-code = parnozzle-code exclusive-lock no-error.
   if not available bf_pl-pump-nozzle then
      return error SUBSTITUTE("Не найдена запись для удаления резевуар &1 ТРК &2 пистолет &3",
                              parpl-code,
                              parpump-code,
                              parnozzle-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
   delete bf_pl-pump-nozzle.
end.
end procedure.
procedure chkcsptr:
define input parameter parobj-type   like ub.clients.obj-type     no-undo.
define input parameter parobj-code   like ub.clients.obj-code     no-undo.
define variable        varretobjat   as   character            no-undo.
define variable        varshift-date like ub.shift-obj.shift-date no-undo.
define variable        varshift-num  like ub.shift-obj.shift-num  no-undo.
define buffer bf_clients   for ub.clients.
define buffer bf_shift-obj for ub.shift-obj.
define buffer bf_rvs-doc   for ub.rvs-doc.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then return error "Нет такого объекта " + parobj-type +
                                              " "                   + string(parobj-code) + ".".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output varretobjat
  ) no-error .
if error-status:error then  return error "Ошибка при вызове файла library.p: objat".
if varretobjat <> "yes" then do:
   return error "Фатальная ошибка. На объекте " + parobj-type + " " + string(parobj-code) + " не включены смены.".
end.
find first bf_shift-obj
     where bf_shift-obj.obj-type = parobj-type
       and bf_shift-obj.obj-code = parobj-code
       and bf_shift-obj.status_  = 'тек':U
      use-index pi no-error .
if available bf_shift-obj then do:
   find first bf_rvs-doc where bf_rvs-doc.obj-type   = parobj-type             and
                               bf_rvs-doc.obj-code   = parobj-code             and
                               bf_rvs-doc.shift-date = bf_shift-obj.shift-date and
                               bf_rvs-doc.shift-num  = bf_shift-obj.shift-num  and
                               bf_rvs-doc.status_    = 'факт':U                 and
                               bf_rvs-doc.rvs-type   = 'смена':U            no-lock no-error.
   if not available bf_rvs-doc then
   return error "Смена открыта и не сделан документ сверки типа 'смена' за текущую смену.".
end.
end procedure.
      define variable varartic            like ub.goods.artic no-undo.
      define variable varname             like ub.goods.gds-name no-undo.
      define variable varstatus           as character no-undo.
      define variable varloc1             as character no-undo.
      define variable varpetcode          like ub.prod-bc.b-str no-undo.
      define variable vargds-code         like ub.goods.gds-code no-undo.
      define variable vargds-recid        AS recid     no-undo.
      define variable gds-rec             AS recid     no-undo.
      define variable v-chk-act-host-code as integer   no-undo .
      define variable glog                as logical   no-undo .
      define variable v-userid            as character no-undo .
      define variable v-db-num            as integer   no-undo .
      define variable v-host-code         as integer   no-undo .
      define variable v-obj-type          as character no-undo .
      define variable v-obj-code          as integer   no-undo .
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = ':U).
RUN set-attribute-list (
    'SortBy-Options = ""':U).
FUNCTION gds-artic RETURNS CHARACTER
  ( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle)  FORWARD.
FUNCTION gds-name RETURNS CHARACTER
  ( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle)  FORWARD.
FUNCTION loc-code RETURNS CHARACTER
  ( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle )  FORWARD.
FUNCTION nz-status RETURNS CHARACTER
( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle)  FORWARD.
FUNCTION pet-code RETURNS CHARACTER
  ( INPUT p-gds-code AS INTEGER )  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1.
DEFINE BUTTON b-hist
     LABEL "&История"
     SIZE 10 BY 1.
DEFINE VARIABLE varps AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97.25 BY 1.88 NO-UNDO.
DEFINE QUERY br_table FOR
      ub.pl-pump-nozzle SCROLLING.
DEFINE BROWSE br_table
  QUERY br_table NO-LOCK DISPLAY
      ub.pl-pump-nozzle.pl-code FORMAT "99999999999":U column-label "Бар-код резервуара"
loc-code (buffer ub.pl-pump-nozzle) @ varloc1 format "x(3)" column-label "Код"
ub.pl-pump-nozzle.pump-code
ub.pl-pump-nozzle.nozzle-code column-label "Пистолет"
gds-artic (buffer ub.pl-pump-nozzle) @ varartic
pet-code (vargds-code) @ varpetcode FORMAT "X(9)" COLUMN-LABEL "Код топл."
gds-name (buffer ub.pl-pump-nozzle) @ varname format "x(20)"
nz-status (buffer ub.pl-pump-nozzle) @ varstatus format "x(15)" column-label "Статус"
    WITH NO-ASSIGN SEPARATORS SIZE 97.25 BY 7.29.
DEFINE FRAME F-Main
     br_table AT ROW 1 COL 1
     varps AT ROW 8.38 COL 1 NO-LABEL
     b-add AT ROW 10.54 COL 1.38
     b-del AT ROW 10.54 COL 11.75
     b-hist AT ROW 10.54 COL 22.13
     b-help AT ROW 10.54 COL 32.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE adm-sts           AS LOGICAL NO-UNDO.
DEFINE VARIABLE adm-brs-in-update AS LOGICAL NO-UNDO INIT no.
DEFINE VARIABLE adm-brs-initted   AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
      adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartObject~`':U +
     '~`':U +
     'YES~`':U +
     '~`':U +
     'ub.pl-pump-nozzle~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Initial-Lock,Hide-on-Init,Disable-on-Init,Key-Name,Layout,Create-On-Add,SortBy-Case~`':U +
     'Record-Source,Record-Target,TableIO-Target~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE br_table varps b-add b-del b-hist b-help WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/browserd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN br_table varps b-add b-del b-hist b-help WITH FRAME F-Main.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
  DEFINE VARIABLE adm-first-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-second-table        AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-third-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-adding-record       AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE adm-return-status       AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-first-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-second-prev-rowid   AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-third-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-first-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-second-tmpl-recid   AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-third-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-index-pos           AS INTEGER   NO-UNDO.
  DEFINE VARIABLE adm-query-empty         AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-complete     AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-on-add       AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-assign-target     AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-target-list       AS CHARACTER NO-UNDO INIT ?.
  IF "":U = "":U THEN
    RUN modify-list-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, "REMOVE":U, "SUPPORTED-LINKS":U, "TABLEIO-TARGET":U).
  RUN use-create-on-add(?).
PROCEDURE adm-add-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
       "must have at least one Enabled Table to perform Add.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-assign-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Assign.":U
           VIEW-AS ALERT-BOX ERROR.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-assign-statement :
  RETURN.
END PROCEDURE.
PROCEDURE adm-cancel-record :
   RETURN.
  END PROCEDURE.
PROCEDURE adm-copy-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
     "must have at least one Enabled Table to perform Copy.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-create-record :
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
  RETURN.
END PROCEDURE.
PROCEDURE adm-delete-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Delete.":U
           VIEW-AS ALERT-BOX ERROR.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-disable-fields :
      RUN notify ('disable-fields, GROUP-ASSIGN-TARGET':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-enable-fields :
    RETURN.
END PROCEDURE.
PROCEDURE adm-end-update :
  RETURN.
END PROCEDURE.
PROCEDURE adm-reset-record :
    RETURN.
END PROCEDURE.
PROCEDURE adm-update-record :
    MESSAGE
      "Object ":U THIS-PROCEDURE:FILE-NAME
        "must have at least one Enabled Table to perform Update.":U
          VIEW-AS ALERT-BOX ERROR.
   RETURN.
END PROCEDURE.
PROCEDURE check-modified :
DEFINE INPUT PARAMETER check-state AS CHARACTER NO-UNDO.
DEFINE VARIABLE curr-widget       AS HANDLE      NO-UNDO.
DEFINE VARIABLE container-hdl-str AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i                 AS INTEGER     NO-UNDO.
  IF check-state = "check":U THEN
  DO:
    RUN get-link-handle IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT 'GROUP-ASSIGN-TARGET':U,
         OUTPUT group-target-list).
    IF group-target-list NE "":U THEN
    DO i = 1 TO NUM-ENTRIES(group-target-list):
      curr-widget = WIDGET-HANDLE(ENTRY(i, group-target-list)).
      RUN check-modified IN curr-widget ('group-check':U).
      IF RETURN-VALUE NE "":U THEN
      DO:
        RUN check-modified-message(RETURN-VALUE).
        RETURN "":U.
      END.
    END.
  END.
  RETURN "":U.
END PROCEDURE.
PROCEDURE check-modified-message :
  DEFINE INPUT PARAMETER p-changed-table AS CHARACTER NO-UNDO.
     RUN request-attribute IN adm-broker-hdl (THIS-PROCEDURE,
        'CONTAINER-SOURCE':U, 'HIDDEN':U).
     IF RETURN-VALUE = "YES":U THEN
        RUN notify ('view,CONTAINER-SOURCE':U).
     MESSAGE IF p-changed-table NE ? THEN
        SUBSTITUTE ("Current &1 record has been changed.", p-changed-table)
        ELSE "Current values have been changed."
        SKIP "  Do you wish to save those changes?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ANS AS LOGICAL.
     IF ANS THEN
     DO:
        IF group-assign-target THEN
          RUN notify('update-record,GROUP-ASSIGN-SOURCE':U).
        ELSE RUN dispatch('update-record':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
            MESSAGE "Changes to the previous record were not saved."
              VIEW-AS ALERT-BOX ERROR.
            IF group-assign-target THEN
              RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
            ELSE RUN dispatch ('cancel-record':U).
        END.
     END.
     ELSE DO:
       IF group-assign-target THEN
          RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
       ELSE RUN dispatch('cancel-record':U).
     END.
     RETURN.
END PROCEDURE.
PROCEDURE get-rowid :
    DEFINE OUTPUT PARAMETER p-table           AS ROWID NO-UNDO.
    ASSIGN
    p-table   =   adm-first-table.
    RETURN.
END PROCEDURE.
PROCEDURE init-group-assign :
    RUN request-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, 'ENABLED-TABLES':U).
    IF LOOKUP("":U, RETURN-VALUE, " ":U) NE 0 THEN
      group-assign-target = yes.
    ELSE group-assign-target = no.
    RETURN.
END PROCEDURE.
PROCEDURE set-editors :
    DEFINE INPUT PARAMETER p-field-setting  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE curr-widget             AS HANDLE    NO-UNDO.
    DEFINE VARIABLE read-only-list          AS CHARACTER NO-UNDO INIT "":U.
    ASSIGN curr-widget = FRAME F-Main:CURRENT-ITERATION.
    ASSIGN curr-widget = curr-widget:FIRST-CHILD.
    DO WHILE VALID-HANDLE (curr-widget):
        IF curr-widget:TYPE = "EDITOR":U AND curr-widget:TABLE NE ? AND
           curr-widget:HIDDEN = no THEN DO:
          CASE p-field-setting:
            WHEN "INITIALIZE":U THEN
            DO:
              IF curr-widget:READ-ONLY = yes THEN read-only-list =
                  read-only-list +
                    (IF read-only-list NE "":U THEN ",":U ELSE "":U) +
                     STRING(curr-widget).
            END.
            WHEN "DISABLE":U OR
            WHEN "ENABLE":U THEN
            DO:
                curr-widget:SENSITIVE = yes.
                RUN get-attribute ('Read-Only-Editors':U).
                IF RETURN-VALUE = ? OR
                  LOOKUP (STRING(curr-widget), RETURN-VALUE) EQ 0 THEN
                    curr-widget:READ-ONLY =
                      IF p-field-setting = "ENABLE":U THEN no ELSE yes.
            END.
            WHEN "CLEAR":U THEN
                curr-widget:SCREEN-VALUE = "":U.
          END CASE.
        END.
        ASSIGN curr-widget = curr-widget:NEXT-SIBLING.
    END.
    IF p-field-setting = "INITIALIZE":U AND read-only-list NE "":U THEN
      RUN set-attribute-list ('Read-Only-Editors = "':U + read-only-list
        + '"':U).
    RETURN.
END PROCEDURE.
PROCEDURE use-check-modified-all :
 DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-check-modified-all = IF p-attr-value = "YES":U THEN yes ELSE no.
  RETURN.
END PROCEDURE.
PROCEDURE use-create-on-add :
DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
   RETURN.
END PROCEDURE.
PROCEDURE use-initial-lock :
  DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-initial-lock = p-attr-value.
  RETURN.
END PROCEDURE.
PROCEDURE adm-display-fields :
      IF AVAILABLE ub.pl-pump-nozzle THEN
          DISPLAY ub.pl-pump-nozzle.pl-code loc-code (buffer ub.pl-pump-nozzle) @ varloc1 ub.pl-pump-nozzle.pump-code ub.pl-pump-nozzle.nozzle-code gds-artic (buffer ub.pl-pump-nozzle) @ varartic pet-code (vargds-code) @ varpetcode gds-name (buffer ub.pl-pump-nozzle) @ varname nz-status (buffer ub.pl-pump-nozzle) @ varstatus WITH BROWSE br_table
            NO-ERROR.
      DISPLAY UNLESS-HIDDEN varps
          WITH FRAME F-Main NO-ERROR.
    RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-open-query :
            RUN dispatch ('open-query-cases':U).
        adm-query-opened = yes.
        IF NUM-RESULTS("br_table":U) = 0 THEN
            RUN new-state ('no-record-available,SELF':U).
        ELSE DO:
            RUN new-state ('record-available,SELF':U).
            RUN new-state ('first-record,SELF':U).
        END.
        IF NOT adm-updating-record THEN
            RUN dispatch IN THIS-PROCEDURE ('row-changed':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-row-changed :
      IF VALID-HANDLE(adm-object-hdl) THEN
        RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
      RUN notify ('row-available':U).
      RETURN.
END PROCEDURE.
PROCEDURE reposition-query :
    DEFINE INPUT PARAMETER p-requestor-hdl     AS HANDLE NO-UNDO.
    DEFINE VARIABLE table-name                 AS ROWID NO-UNDO.
    RUN get-rowid IN p-requestor-hdl (OUTPUT table-name).
    IF table-name <> ? THEN
        REPOSITION br_table TO ROWID table-name NO-ERROR.
    RUN set-attribute-list ('REPOSITION-PENDING = NO':U).
    RETURN.
END PROCEDURE.
  adm-sts = br_table:SET-REPOSITIONED-ROW
    (br_table:DOWN,"CONDITIONAL":U).
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
PROCEDURE set-size :
  DEFINE INPUT PARAMETER pd_height AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pd_width  AS DECIMAL NO-UNDO.
  DEFINE VARIABLE hBrowse     AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFieldGroup AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFrame      AS HANDLE           NO-UNDO.
  DEFINE VARIABLE htmpWidget  AS HANDLE           NO-UNDO.
  DEFINE VARIABLE otherWidget AS LOGICAL          NO-UNDO.
  ASSIGN pd_height = MAX(pd_height, 2.0)
         pd_width  = MAX(pd_width, 2.0)
         hBrowse     = br_table:HANDLE IN FRAME F-Main
         hFieldGroup = hBrowse:PARENT
         htmpWidget  = hFieldGroup:FIRST-CHILD
         hFrame      = hFieldGroup:PARENT.
  Search-For-Siblings:
  REPEAT WHILE VALID-HANDLE(htmpWidget):
    IF htmpWidget NE hBrowse THEN DO:
      IF htmpWidget:TYPE NE "BUTTON" OR
         htmpWidget:X    NE 4 OR
         htmpWidget:Y    NE 4 THEN DO:
        RETURN.
      END.
    END.
    htmpWidget = htmpWidget:NEXT-SIBLING.
  END.
  IF pd_width < hBrowse:WIDTH THEN
    ASSIGN hBrowse:WIDTH = pd_width
           hFrame:WIDTH  = pd_width     NO-ERROR.
  ELSE
    ASSIGN hFrame:WIDTH  = pd_width
           hBrowse:WIDTH = pd_width     NO-ERROR.
  IF pd_height < hBrowse:HEIGHT THEN
    ASSIGN hBrowse:HEIGHT = pd_height
           hFrame:HEIGHT  = pd_height     NO-ERROR.
  ELSE
    ASSIGN hFrame:HEIGHT  = pd_height
           hBrowse:HEIGHT = pd_height     NO-ERROR.
END PROCEDURE.
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
ON CHOOSE OF b-add IN FRAME F-Main
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-db-num
    ,input  v-userid
    ,input  0
    ,input  'actn_pump-reference_work':U
    ,input  'object':U
    ,input  v-host-code
    ,input  v-obj-type
    ,input  v-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if NOT glog then return no-apply.
define variable varrec-id as recid no-undo.
  CASE "plpmnz"
  :
   WHEN "nozzle" THEN DO:
     run str/d-nozzle.w (input  varobj-type,
                     input  varobj-code,
                     output varrec-id) no-error.
   END.
   WHEN "plpmnz" THEN DO:
     run str/d-plpmnz.w
      ( input parparentproc
       ,input varobj-type
       ,input varobj-code
       ,output varrec-id
      ) no-error.
   END.
   WHEN "plpump" THEN DO:
     run str/d-plpump.w
      ( input parparentproc
       ,input varobj-type
       ,input varobj-code
       ,output varrec-id
      ) no-error.
   END.
   WHEN "pump" THEN DO:
     run str/d-pump.w
      ( input parparentproc
       ,input varobj-type
       ,input  varobj-code
       ,output varrec-id
      ) no-error.
   END.
   WHEN "pumpnz" THEN DO:
     run str/d-pumpnz.w
      ( input parparentproc
       ,input varobj-type
       ,input varobj-code
       ,output varrec-id
      ) no-error.
   END.
   OTHERWISE DO:
message
  vss-workfile vss-revision vss-description skip
  "Неверное имя файла d-plpmnz.w." skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
     return no-apply.
   END.
  END CASE.
  if error-status:error then do:
message
  vss-workfile vss-revision vss-description skip
  "Ошибка при вызове файла d-plpmnz.w." skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
     return no-apply.
  end.
  if varrec-id <> ? then do:
     RUN dispatch IN THIS-PROCEDURE ('open-query':U).
     REPOSITION br_table to recid varrec-id.
  end.
END.
ON CHOOSE OF b-del IN FRAME F-Main
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-db-num
    ,input  v-userid
    ,input  0
    ,input  'actn_pump-reference_work':U
    ,input  'object':U
    ,input  v-host-code
    ,input  v-obj-type
    ,input  v-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if NOT glog then return no-apply.
if available ub.pl-pump-nozzle then do:
   assign varmes-log = no.
   message "Вы хотите удалить запись <<резервуар-ТРК-пистолета>> с номером резервуара" ub.pl-pump-nozzle.pl-code
           " номером ТРК " ub.pl-pump-nozzle.pump-code " и номером пистолета "
           ub.pl-pump-nozzle.nozzle-code " ?" skip
           "Вы уверены?"
           view-as alert-box question buttons yes-no update varmes-log.
  if varmes-log = yes then do:
     run plpmnzdv (input ub.pl-pump-nozzle.obj-type,
                   input ub.pl-pump-nozzle.obj-code,
                   input ub.pl-pump-nozzle.pl-code,
                   input ub.pl-pump-nozzle.pump-code,
                   input ub.pl-pump-nozzle.nozzle-code) no-error.
     if error-status:error then do:
message
  vss-workfile vss-revision vss-description skip
  "Ошибка при удалении записи резервуар-ТРК-пистолет." skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
        return no-apply.
     end.
     RUN dispatch IN THIS-PROCEDURE ('open-query':U).
  end.
end.
END.
ON CHOOSE OF b-hist IN FRAME F-Main
DO:
  define variable v-rec-list as character no-undo.
  if available ub.pl-pump-nozzle then do:
      run ref/cplchist.w (
                       INPUT parParentProc
                     , input ub.pl-pump-nozzle.obj-type
                     , input  ub.pl-pump-nozzle.obj-code
                     , input "":U
                     , "subject":U
                     , input ub.pl-pump-nozzle.obj-type
                     , input ub.pl-pump-nozzle.obj-code
                     , input ub.pl-pump-nozzle.pl-code
                     , input 0
                     , input ub.pl-pump-nozzle.pump-code
                     , input ub.pl-pump-nozzle.nozzle-code
                     , input 'pl-pump-nozzle':U
                     , input-output v-rec-list
                     ) no-error .
  end.
  apply "ENTRY":U to browse br_table.
END.
ON ROW-ENTRY OF br_table IN FRAME F-Main
DO:
END.
ON ROW-LEAVE OF br_table IN FRAME F-Main
DO:
DEFINE VARIABLE widget-enter  AS HANDLE NO-UNDO.
DEFINE VARIABLE widget-frame  AS HANDLE NO-UNDO.
DEFINE VARIABLE widget-parent AS HANDLE NO-UNDO.
  widget-enter = last-event:widget-enter.
  IF VALID-HANDLE(widget-enter) THEN widget-parent = widget-enter:PARENT.
  IF VALID-HANDLE(widget-parent) AND widget-parent:TYPE NE "BROWSE":U
    THEN widget-frame = widget-enter:FRAME.
  IF ((NOT VALID-HANDLE(widget-enter)) OR
      (widget-parent:TYPE = "BROWSE":U) OR
      (NOT VALID-HANDLE(widget-frame)) OR
      (NOT CAN-DO(widget-frame:PRIVATE-DATA, "ADM-PANEL":U)))
  THEN DO:
      IF adm-brs-in-update THEN
      DO:
        MESSAGE
        "You must complete or cancel the update before leaving the current row."
            VIEW-AS ALERT-BOX WARNING.
        RETURN NO-APPLY.
      END.
      IF br_table:CURRENT-ROW-MODIFIED  OR
        (adm-new-record AND BROWSE br_table:NUM-SELECTED-ROWS = 1) THEN
      DO:
        IF VALID-HANDLE (widget-parent) AND widget-parent:TYPE NE "BROWSE":U
        THEN DO:
          MESSAGE
          "Current record has been changed. " SKIP
          "Do you wish to save those changes?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE l-save AS LOGICAL.
          IF l-save THEN
          DO:
             RUN dispatch('update-record':U).
             IF RETURN-VALUE = "ADM-ERROR":U THEN
                 RETURN NO-APPLY.
          END.
          ELSE RUN dispatch ('cancel-record':U).
        END.
        ELSE DO:
          RUN dispatch('update-record':U).
          IF RETURN-VALUE = "ADM-ERROR":U THEN
              RETURN NO-APPLY.
        END.
      END.
  END.
END.
ON VALUE-CHANGED OF br_table IN FRAME F-Main
DO:
RUN get-attribute('ADM-NEW-RECORD':U).
IF RETURN-VALUE NE "YES":U THEN
  RUN notify ('row-available':U).
  if available ub.pl-pump-nozzle then do:
     assign varPS = ub.pl-pump-nozzle.pS.
     display varPS with frame F-Main.
  end.
END.
ON LEAVE OF varps IN FRAME F-Main
DO:
  define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
  if available ub.pl-pump-nozzle then do:
    if ub.pl-pump-nozzle.ps <> input frame F-Main varps then do:
      if varps-upd = no then do:
          message
            "Вы не можете изменять примечание!"
            view-as alert-box.
          display
            ub.pl-pump-nozzle.ps @ varps
            with frame F-Main
          .
      end.
      else do:
        assign
          varmes-log = yes
        .
        message
          "Вы хотите изменить примечание к " "резервуар-ТРК-пистолет"
          view-as alert-box question buttons yes-no update varmes-log.
        if varmes-log = true then do:
          do transaction
          on error  undo, retry
          on stop   undo, retry
          on endkey undo, retry
          :
            if retry then do:
              message
                vss-workfile vss-revision vss-description skip(1)
                "Ошибка при сохранении PS!!!" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              return no-apply.
            end.
            find first bf_pl-pump-nozzle exclusive-lock
              where recid(bf_pl-pump-nozzle) = recid(ub.pl-pump-nozzle)
            .
            assign
              frame F-Main varps
            .
            assign
              bf_pl-pump-nozzle.ps = varps
            .
          end.
        end.
        else do:
          assign
            varps = ub.pl-pump-nozzle.ps
          .
          display
            varps
            with frame F-Main
          .
        end.
      end.
    end.
  end.
END.
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame F-Main
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
on choose of b-help in frame F-Main
do:
  apply "help":u to frame F-Main .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame F-Main:width - 0.3
                fh            = frame F-Main:first-child
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame F-Main anywhere do:
  run get-gds-recid.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br_table in frame F-Main.
  return no-apply.
end.
PROCEDURE adm-open-query-cases :
  OPEN QUERY br_table FOR EACH ub.pl-pump-nozzle WHERE ub.pl-pump-nozzle.obj-type = varobj-type and                                                       ub.pl-pump-nozzle.obj-code = varobj-code NO-LOCK      INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
  IF key-name ne ? OR different-row
  THEN RUN dispatch IN THIS-PROCEDURE ('open-query':U).
  ELSE RUN notify IN THIS-PROCEDURE('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE get-gds-recid :
gds-rec = vargds-recid.
END PROCEDURE.
PROCEDURE local-initialize :
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,
     INPUT 'Container-Source':U,
     INPUT 'parparentproc':U) NO-ERROR.
if return-value = "" or return-value = ? or return-value = "?" then do:                        message "Нет атрибута: " + "parparentproc" + " для получения данных." view-as alert-box error. return error.                    end.
assign parparentproc = widget-handle(return-value).
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,
     INPUT 'Container-Source':U,
     INPUT 'obj-type':U) NO-ERROR.
if return-value = "" or return-value = ? or return-value = "?" then do:                        message "Нет атрибута: " + "obj-type" + " для получения данных." view-as alert-box error. return error.                    end.
assign varobj-type = return-value.
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,
     INPUT 'Container-Source':U,
     INPUT 'obj-code':U) NO-ERROR.
if return-value = "" or return-value = ? or return-value = "?" then do:                        message "Нет атрибута: " + "obj-code" + " для получения данных." view-as alert-box error. return error.                    end.
assign varobj-code = integer(return-value).
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,
     INPUT 'Container-Source':U,
     INPUT 'buttons':U) NO-ERROR.
if return-value = "" or return-value = ? or return-value = "?" then do:                        message "Нет атрибута: " + "buttons" + " для получения данных." view-as alert-box error. return error.                    end.
assign varbuttons = return-value.
assign varbuttons = replace (varbuttons, "|", ",").
if lookup('b-add', varbuttons) = 0 then do:
  assign
    b-add:sensitive in frame F-Main = no
    b-add:visible   in frame F-Main = no
    varps:read-only in frame F-Main = yes
    varps-upd                    = no
  .
end.
else do:
  assign
    varps-upd = yes
  .
end.
if lookup('b-del', varbuttons) = 0 then
   assign b-del:sensitive in frame F-Main = no
          b-del:visible   in frame F-Main = no.
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      assign
        v-db-num    = v-cntxt-db-num
        v-host-code = v-cntxt-host-code-obj
        v-obj-code  = v-cntxt-obj-code
        v-obj-type  = v-cntxt-obj-type
        v-userid    = v-cntxt-userid
        .
  if available ub.pl-pump-nozzle then do:
     assign varps     = ub.pl-pump-nozzle.ps.
     display varps with frame F-Main.
  end.
END PROCEDURE.
PROCEDURE send-key :
END PROCEDURE.
PROCEDURE send-records :
  DEFINE INPUT PARAMETER p-tbl-list AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rowid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE link-handle  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rowid-string AS CHARACTER NO-UNDO.
  DO i = 1 TO NUM-ENTRIES(p-tbl-list):
      IF i > 1 THEN p-rowid-list = p-rowid-list + ",":U.
      CASE ENTRY(i, p-tbl-list):
    WHEN "ub.pl-pump-nozzle":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE ub.pl-pump-nozzle THEN STRING(ROWID(ub.pl-pump-nozzle))
        ELSE "?":U.
        OTHERWISE
        DO:
            RUN get-link-handle IN adm-broker-hdl (INPUT THIS-PROCEDURE,
                INPUT "RECORD-SOURCE":U, OUTPUT link-handle) NO-ERROR.
            IF link-handle NE "":U THEN
            DO:
                IF NUM-ENTRIES(link-handle) > 1 THEN
                    MESSAGE "send-records in ":U THIS-PROCEDURE:FILE-NAME
                            "encountered more than one RECORD-SOURCE.":U SKIP
                            "The first will be used.":U
                            VIEW-AS ALERT-BOX ERROR.
                RUN send-records IN WIDGET-HANDLE(ENTRY(1,link-handle))
                    (INPUT ENTRY(i, p-tbl-list), OUTPUT rowid-string).
                p-rowid-list = p-rowid-list + rowid-string.
            END.
            ELSE
            DO:
                MESSAGE "Requested table":U ENTRY(i, p-tbl-list)
                        "does not match tables in send-records":U
                        "in procedure":U THIS-PROCEDURE:FILE-NAME ".":U SKIP
                        "Check that objects are linked properly and that":U
                        "database qualification is consistent.":U
                    VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END.
        END CASE.
    END.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
    WHEN "update-begin":U THEN
    DO:
        adm-brs-in-update = yes.
        RUN dispatch ('enable-fields':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
          RUN new-state('update-failed,TABLEIO-SOURCE':U).
          RUN new-state('update-complete':U).
        END.
        ELSE DO:
          RUN dispatch ('apply-entry':U).
          RUN new-state('update':U).
        END.
    END.
    WHEN "update":U THEN
      DO:
        DEFINE VARIABLE group-link AS CHARACTER NO-UNDO INIT "":U.
        RUN get-link-handle IN adm-broker-hdl
            (INPUT THIS-PROCEDURE, 'GROUP-ASSIGN-TARGET':U, OUTPUT group-link)
                NO-ERROR.
        IF LOOKUP(STRING(p-issuer-hdl), group-link) EQ 0 THEN
          br_table:SENSITIVE IN FRAME F-Main = no.
      END.
    WHEN "update-complete":U THEN DO:
        br_table:SENSITIVE IN FRAME F-Main = yes.
        adm-brs-in-update = no.
        RUN get-attribute IN p-issuer-hdl ('QUERY-OBJECT':U).
        IF RETURN-VALUE NE "YES":U THEN
        DO:
          IF NUM-RESULTS("br_table":U) NE ? AND
             NUM-RESULTS("br_table":U) NE 0
          THEN DO:
            GET CURRENT br_table.
            RUN dispatch ('row-changed':U).
          END.
        END.
        RUN new-state ('update-complete':U).
    END.
    WHEN "delete-complete":U THEN DO:
       DEFINE VARIABLE sts AS LOGICAL NO-UNDO.
       sts = br_table:DELETE-CURRENT-ROW() IN FRAME F-Main.
       IF NUM-RESULTS("br_table":U) = 0 THEN
         RUN notify('row-available':U).
    END.
    WHEN   'first-record':U        OR
      WHEN 'last-record':U         OR
      WHEN 'only-record':U         OR
      WHEN 'not-first-or-last':U   OR
      WHEN 'no-record-available':U OR
      WHEN 'no-external-record-available':U THEN
        RUN set-attribute-list('Query-Position=':U + p-state).
  END CASE.
END PROCEDURE.
FUNCTION gds-artic RETURNS CHARACTER
  ( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle) :
define buffer bf_pl-gds for ub.pl-gds.
define buffer bf_goods for ub.goods.
find first bf_pl-gds where
   bf_pl-gds.obj-type = local-pl-pump-nozzle.obj-type and
   bf_pl-gds.obj-code = local-pl-pump-nozzle.obj-code and
   bf_pl-gds.pl-code = local-pl-pump-nozzle.pl-code no-lock no-error.
if available bf_pl-gds then do:
  find first bf_goods where bf_goods.gds-code = bf_pl-gds.gds-code no-lock.
  ASSIGN
  vargds-code = bf_goods.gds-code
  vargds-recid = recid(bf_goods).
  return bf_goods.artic.
end.
else do:
  RETURN "".
end.
END FUNCTION.
FUNCTION gds-name RETURNS CHARACTER
  ( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle) :
define buffer bf_pl-gds for ub.pl-gds.
define buffer bf_goods for ub.goods.
find first bf_pl-gds where
   bf_pl-gds.obj-type = local-pl-pump-nozzle.obj-type and
   bf_pl-gds.obj-code = local-pl-pump-nozzle.obj-code and
   bf_pl-gds.pl-code = local-pl-pump-nozzle.pl-code no-lock no-error.
if available bf_pl-gds then do:
  find first bf_goods where bf_goods.gds-code = bf_pl-gds.gds-code no-lock.
  return bf_goods.gds-name.
end.
else do:
  RETURN "".
end.
END FUNCTION.
FUNCTION loc-code RETURNS CHARACTER
  ( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle ) :
define buffer bf_place for ub.place.
find first bf_place where bf_place.obj-type = local-pl-pump-nozzle.obj-type and
                                   bf_place.obj-code = local-pl-pump-nozzle.obj-code and
                                   bf_place.pl-code = local-pl-pump-nozzle.pl-code no-lock.
  RETURN bf_place.loc1.
END FUNCTION.
FUNCTION nz-status RETURNS CHARACTER
( buffer local-pl-pump-nozzle for ub.pl-pump-nozzle) :
define buffer bf_pl-gds-pump for ub.pl-gds-pump.
find first bf_pl-gds-pump where bf_pl-gds-pump.obj-type = local-pl-pump-nozzle.obj-type and
                                              bf_pl-gds-pump.obj-code = local-pl-pump-nozzle.obj-code and
                                              bf_pl-gds-pump.pl-code = local-pl-pump-nozzle.pl-code and
                                              bf_pl-gds-pump.pump-code = local-pl-pump-nozzle.pump-code no-lock no-error.
if available bf_pl-gds-pump then do:
  return bf_pl-gds-pump.status_.
end.
else do:
  return "".
end.
END FUNCTION.
FUNCTION pet-code RETURNS CHARACTER
  ( INPUT p-gds-code AS INTEGER ) :
DEFINE VARIABLE main-b-code LIKE ub.bar-code.b-code NO-UNDO.
DEFINE VARIABLE l-is-petrol-code AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
if p-gds-code = 0 then return "":U.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  vargds-code
  ,input  ?
  ,output main-b-code
  ) NO-ERROR .
IF ERROR-STATUS:ERROR THEN RETURN "":U.
FOR EACH buf_prod-bc NO-LOCK WHERE
        buf_prod-bc.b-code = main-b-code:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'petrolium=request'
  ,output l-is-petrol-code
  ) NO-ERROR .
  IF l-is-petrol-code THEN RETURN buf_prod-bc.b-str.
END.
RETURN "".
END FUNCTION.
