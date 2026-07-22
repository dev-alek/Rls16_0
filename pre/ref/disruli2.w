DEFINE BUFFER locked_dis-rule FOR ub.dis-rule.
DEFINE BUFFER root_dis-rule FOR ub.dis-rule.
DEFINE BUFFER template_dis-rule FOR ub.dis-rule.
DEFINE BUFFER term_dis-rule FOR ub.dis-rule.
DEFINE TEMP-TABLE tt-bc-dis-rule NO-UNDO LIKE ub.bar-code
       field rule-num like ub.dis-rule.rule-num
       field price-brutto like ub.gds-obj.price-sale
       field price-netto like ub.gds-obj.price-sale
       field price-discnt like ub.gds-obj.price-sale
       field sum-brutto like ub.trn-doc.tot-sale
       field sum-netto like ub.trn-doc.tot-sale
       field sum-discnt like ub.trn-doc.tot-sale
       field d-pcnt like ub.dis-rule.discnt-value
       field sale-qnty like ub.dis-rule.doc-qnty
       index pi is unique primary rule-num.
DEFINE TEMP-TABLE tt-dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE INPUT PARAMETER parparentproc AS widget-handle NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root like ub.dis-rule.templ-rl-root NO-UNDO.
DEFINE INPUT PARAMETER p-host-code LIKE ub.sysconf.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT PARAMETER p-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define input parameter p-upper-rule-num like ub.dis-rule.upper-rule-num no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-recid AS recid NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование правил скидок по шаблону 75".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
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
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gtregion RETURNS CHARACTER
  ( input parhost-code as integer
  , input parobj-type as character
  , input parobj-code as integer
  , input p-tab as logical
  ) :
  def var par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = if p-tab then fill(chr(32), 2) else "":U +
                    "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    par-region = if p-tab then fill(chr(32), 4) else "":U +
                 parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
define variable  v-rule-num          like ub.dis-rule.rule-num          no-undo .
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-dis-kat-tree      as logical no-undo .
define variable  v-doc-qnty-tree     as logical no-undo .
define variable  v-tot-sum-tree      as logical no-undo .
define variable  v-charkey_one-tree  as logical no-undo .
define variable  v-charkey_two-tree  as logical no-undo .
define variable  v-charkey_three-tree  as logical no-undo .
define variable  v-deckey_one-tree  as logical no-undo .
define variable  v-deckey_two-tree  as logical no-undo .
define variable  v-deckey_three-tree  as logical no-undo .
define variable  v-key#_one-tree  as logical no-undo .
define variable  v-key#_two-tree  as logical no-undo .
define variable  v-key#_three-tree  as logical no-undo .
define variable  v-time-rule-num-tree as logical no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-global         as integer no-undo .
define variable  v-host           as integer no-undo .
define variable  v-object         as integer no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other          as character no-undo .
DEFINE VARIABLE v-tab-order       AS CHARACTER NO-UNDO.
define variable  is-good-mode as logical   no-undo .
define variable v-meas as integer no-undo init 3.
DEFINE VARIABLE v-price-sale LIKE ub.price-list.price-sale NO-UNDO.
DEFINE VARIABLE v-doc-num LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE v-road-tax LIKE ub.price-list.road-tax NO-UNDO.
DEFINE VARIABLE v-excise LIKE ub.price-list.excise NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable v-radio-integer-handle as handle no-undo .
define variable v-pos-type as character no-undo .
define variable v-is-copy as logical no-undo .
define variable v-ref-dr-templ-rl-root  as integer no-undo .
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
define buffer buf_units for ub.units.
define buffer buf_temp-drt-prop for temp-drt-prop.
DEFINE BUFFER dr-chk_dis-rule FOR ub.dis-rule.
DEFINE BUTTON B-dis-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-dis-time-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-rule-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-time-rule-lookup
     LABEL "&Распис."
     SIZE 10 BY 1.
DEFINE VARIABLE f-pos-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Место исп."
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE s-discnt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип скидки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE s-subject-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект скидки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-region AS CHARACTER FORMAT "X(256)":U
     LABEL "Действует"
      VIEW-AS TEXT
     SIZE 22.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE key#_one-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 96.5 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-dis-rule,
      locked_dis-rule SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-time-rule-lookup AT ROW 1 COL 41
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-dis-rule.des AT ROW 2 COL 10 COLON-ALIGNED
          LABEL "Описание"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
          FGCOLOR 4
     tt-dis-rule.value-type AT ROW 3 COL 10 COLON-ALIGNED WIDGET-ID 2
          LABEL "Тип знач."
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "0",1
          DROP-DOWN-LIST
          SIZE 31 BY 1
     s-discnt-type AT ROW 3.93 COL 14 COLON-ALIGNED
     f-pos-type AT ROW 3.93 COL 46 COLON-ALIGNED WIDGET-ID 6
     s-subject-type AT ROW 4.93 COL 14 COLON-ALIGNED
     tt-dis-rule.Key#_One AT ROW 6.6 COL 28 COLON-ALIGNED WIDGET-ID 10
          LABEL "ИПоле1"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-dis-rule AT ROW 6.6 COL 41 WIDGET-ID 16
     b-rule-lookup AT ROW 6.6 COL 45 WIDGET-ID 18
     key#_one-name AT ROW 7.93 COL 2 NO-LABEL WIDGET-ID 12
     tt-dis-rule.time-rule-num AT ROW 9.53 COL 11 COLON-ALIGNED
          LABEL "№ распис."
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     B-dis-time-rule AT ROW 9.53 COL 21.5
     tt-dis-rule.rule-num AT ROW 1.27 COL 71.5 COLON-ALIGNED
          LABEL "№ правила"
           VIEW-AS TEXT
          SIZE 14 BY .67
          FGCOLOR 4
     F-region AT ROW 3 COL 74.5 COLON-ALIGNED
     SPACE(0.29) SKIP(18.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правило скидки ТИПА:"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-dis-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-dis-time-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-time-rule-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-rule.Key#_One:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       key#_one-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       tt-dis-rule.time-rule-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-dis-rule IN FRAME Dialog-Frame
DO:
   RUN local-dr-chk ("key#_one", "button").
  apply "entry" to tt-dis-rule.key#_one in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-dis-time-rule IN FRAME Dialog-Frame
DO:
 run proc-b-dis-time-rule in this-procedure no-error.
 if error-status:error then return no-apply.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  if NOT available locked_dis-rule then return no-apply.
  run ref/discruls.w (
                   INPUT parParentProc
                  ,input "":U
                  ,input "rl-root":U
                  ,input tt-dis-rule.rule-num
                  ,input tt-dis-rule.upper-rule-num
                  ,input "":U
                  ,input 0
                  ,input-output v-rid-list ).
END.
ON CHOOSE OF b-rule-lookup IN FRAME Dialog-Frame
DO:
  IF AVAILABLE dr-chk_dis-rule THEN DO:
    run ref/show-dr.p ( input parparentproc
                      ,input dr-chk_dis-rule.rule-num) no-error.
  END.
END.
ON CHOOSE OF B-time-rule-lookup IN FRAME Dialog-Frame
DO:
  RUN proc-time-rule-lookup IN THIS-PROCEDURE (V-TREE) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON LEAVE OF tt-dis-rule.Key#_One IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if input frame Dialog-Frame tt-dis-rule.key#_one <> tt-dis-rule.key#_one then do:
    run local-dr-chk ("key#_one", "leave-message").
  end.
END.
ON RETURN OF tt-dis-rule.Key#_One IN FRAME Dialog-Frame
DO:
  run local-dr-chk ("key#_one", "ret-mouse").
  apply "entry" to tt-dis-rule.key#_one in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-dis-rule.time-rule-num IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    if   input frame Dialog-Frame tt-dis-rule.time-rule-num <> 0 then do:
    run check-time-rule in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure disrules-override-labels :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
define buffer bufformat_temp-drt-prop for ub.drt-prop.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  if not can-find(first temp-drt-prop) then do:
    run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
  end.
  if can-find(first buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
                and buf_temp-drt-prop.prop-code = "Label"
                ) then do:
    for each buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
                and buf_temp-drt-prop.prop-code = "Label":U:
      assign
      fh = frame Dialog-Frame:first-child
      hh = fh:first-child
      .
      do while valid-handle(hh):
        if index(hh:name, buf_temp-drt-prop.upper-prop-code) > 0
        and (index(hh:name, buf_temp-drt-prop.upper-prop-code) + length(buf_temp-drt-prop.upper-prop-code) - 1 =
             length(hh:name))
        then do:
          assign
          hh:label = buf_temp-drt-prop.property-value
          .
        end.
        hh = hh:next-sibling.
      end.
    end.
  end.
end.
end procedure.
~
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode <> 'ДОБАВЛЕНИЕ':U
  and p-mode <> 'ПРОСМОТР':U
  and p-mode <> 'ИЗМЕНЕНИЕ':U
  and p-mode <> 'КОПИРОВАНИЕ':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
  END.
  if p-mode = 'КОПИРОВАНИЕ':U then do:
    v-is-copy = yes.
    p-mode = 'ДОБАВЛЕНИЕ':U.
  end.
  for each tt-dis-rule:
    delete tt-dis-rule.
  end.
  for each tt0-term_dis-rule:
    delete tt0-term_dis-rule.
  end.
  run dr-code  in this-procedure (
     input  p-templ-rl-root
    ,output v-des
    ,output v-discnt-type
    ,output v-subject-type
    ,output v-value-type
    ,output v-level-1
    ,output v-level-2
    ,output v-global
    ,output v-host
    ,output v-object
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-templ-rl-root" p-templ-rl-root SKIP
     error-status:get-message(1) SKIP
     RETURN-VALUE
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
  if can-find(first temp-drt-prop where
                   temp-drt-prop.templ-rl-root = p-templ-rl-root
               and temp-drt-prop.prop-code = "CalcGoodsPrice":U
               and temp-drt-prop.upper-prop-code = "":U
               and temp-drt-prop.property-value  = "no") then do:
    assign
    p-b-code = 0
    .
  end.
  IF p-b-code <> 0  THEN DO:
    IF v-subject-type <> INTEGER('1':U) THEN DO:
        MESSAGE
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра p-b-code" p-b-code SKIP
             error-status:get-message(1) SKIP
             RETURN-VALUE
            VIEW-AS ALERT-BOX ERROR.
            UNDO, RETURN ERROR.
    END.
    FIND FIRST X_bar-code NO-LOCK WHERE
                X_bar-code.b-code = p-b-code NO-ERROR.
    IF NOT AVAILABLE X_bar-code THEN DO:
      MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-b-code" p-b-code SKIP
         error-status:get-message(1) SKIP
         RETURN-VALUE
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
     END.
     FIND FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_bar-code.gds-code NO-ERROR.
     IF NOT AVAILABLE X_goods THEN DO:
    MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-b-code" p-b-code SKIP
         error-status:get-message(1) SKIP
         RETURN-VALUE
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
     END.
    ASSIGN
    is-good-mode = YES.
    find first buf_units no-lock where
               buf_units.unit-name = X_goods.unit-base no-error.
    if available buf_units then do:
      assign
      v-meas = if( LOOKUP('шту':U, buf_units.type) > 0 or LOOKUP('сер':U, buf_units.type) > 0 )
               then 0
               else v-meas.
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
  END.
  run fill-main-table in this-procedure.
  if p-upper-rule-num > 99999 then do:
    assign
    v-tree = "":U.
  end.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-time-rule :
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = input frame Dialog-Frame tt-dis-rule.time-rule-num
         no-error.
if not available buf_dis-time-rule then do:
  if input frame Dialog-Frame tt-dis-rule.time-rule-num <> ?  then
    message "Неправильный номер расписания" .
  apply "entry" to tt-dis-rule.time-rule-num in frame Dialog-Frame.
  return error.
end.
find first X_dis-time-rule no-lock where recid(X_dis-time-rule) = recid(buf_dis-time-rule).
assign
tt-dis-rule.time-rule-num = buf_dis-time-rule.time-rule-num
tt-dis-rule.time-templ-rl-root = buf_dis-time-rule.templ-rl-root
.
display
tt-dis-rule.time-rule-num
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-hide-fields :
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-main AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-display-hide AS integer NO-UNDO.
CASE p-display-hide:
  WHEN 1 THEN DO:
    IF lookup("time-rule-num":U, v-level-1) > 0 THEN DO:
      ASSIGN
      b-time-rule-lookup:ROW in frame Dialog-Frame = 1
      b-time-rule-lookup:column = b-hist:COLUMN - 10
      .
      DISPLAY
      tt-dis-rule.time-rule-num
      b-dis-time-rule
      b-time-rule-lookup
      WITH FRAME Dialog-Frame.
      ENABLE
      tt-dis-rule.time-rule-num WHEN p-mode <> 'ПРОСМОТР':U
      b-dis-time-rule WHEN p-mode <> 'ПРОСМОТР':U
      b-time-rule-LOOKUP
      WITH FRAME Dialog-Frame.
    END.
    else do:
      hide
      tt-dis-rule.time-rule-num
      b-dis-time-rule
      b-time-rule-lookup
      in FRAME Dialog-Frame.
    END.
    DISPLAY
    tt-dis-rule.key#_one
    WITH FRAME Dialog-Frame.
    ENABLE
    tt-dis-rule.key#_one WHEN p-mode <> 'ПРОСМОТР':U
    b-dis-rule WHEN p-mode <> 'ПРОСМОТР':U
    b-rule-LOOKUP
    WITH FRAME Dialog-Frame.
  END.
  WHEN 0 THEN DO:
    HIDE
    tt-dis-rule.key#_one
    tt-dis-rule.time-rule-num
    b-time-rule-lookup
    b-dis-time-rule
    b-dis-rule
    b-rule-lookup
    in FRAME Dialog-Frame.
  END.
END CASE.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-dis-rule SHARE-LOCK,       EACH locked_dis-rule WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY s-discnt-type f-pos-type s-subject-type key#_one-name F-region
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-rule THEN
    DISPLAY tt-dis-rule.des tt-dis-rule.value-type tt-dis-rule.Key#_One
          tt-dis-rule.time-rule-num tt-dis-rule.rule-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-time-rule-lookup B-hist B-Help tt-dis-rule.des
         tt-dis-rule.value-type f-pos-type tt-dis-rule.Key#_One B-dis-rule
         b-rule-lookup tt-dis-rule.time-rule-num B-dis-time-rule
         tt-dis-rule.rule-num F-region
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-main-table :
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U
or (p-mode = 'ДОБАВЛЕНИЕ':U and v-is-copy)
then do:
  find first locked_dis-rule no-lock where
          recid(locked_dis-rule) = p-recid no-error .
  if not available locked_dis-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена запись ПРАВИЛО СКИДОК с номером" p-rule-num
    view-as alert-box error .
    undo, return error.
  end.
  if locked_dis-rule.root = no then do:
    message
    substitute("Невозможен просмотр не корневого правила &1", p-rule-num)
    view-as alert-box error .
    undo, return error .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first locked_dis-rule EXclusive-lock where
                  recid(locked_dis-rule) = p-recid no-wait no-error.
    if locked locked_dis-rule then do:
      message
      vss-workfile vss-revision vss-description skip
        "Запись ПРАВИЛО СКИДОК занята"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_dis-rule no-lock where
                      recid(locked_dis-rule) = p-recid no-error .
    if not avail locked_dis-rule then do:
      find first locked_dis-rule no-lock where
                  locked_dis-rule.rule-num = p-rule-num no-error .
    end.
  end.
  if locked_dis-rule.rule-num <= 99999
  and p-mode = 'ИЗМЕНЕНИЕ':U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя редактировать ШАБЛОНЫ СКИДОК"
    view-as alert-box error .
    undo, return error.
  end.
  create tt-dis-rule.
  buffer-copy locked_dis-rule to tt-dis-rule
  .
  if p-mode = 'ДОБАВЛЕНИЕ':U
  and v-is-copy = yes then do:
    assign
    tt-dis-rule.rule-num = locked_dis-rule.templ-rl-root
    tt-dis-rule.host-code = p-host-code
    tt-dis-rule.obj-type = p-obj-type
    tt-dis-rule.obj-code = p-obj-code
    .
  end.
  end.
  else do:
      FIND FIRST template_dis-rule NO-LOCK WHERE
                  template_dis-rule.rule-num = p-templ-rl-root .
      create tt-dis-rule.
      BUFFER-COPY template_dis-rule TO tt-dis-rule
      ASSIGN
      tt-dis-rule.upper-rule-num = template_dis-rule.rule-num
      tt-dis-rule.templ-rl-root  = template_dis-rule.rule-num
      tt-dis-rule.root        = yes
      tt-dis-rule.host-code = p-host-code
      tt-dis-rule.obj-type = p-obj-type
      tt-dis-rule.obj-code = p-obj-code
      tt-dis-rule.des = trim(template_dis-rule.des, "@":U)
      tt-dis-rule.lvl-num = 1
      .
  end.
END PROCEDURE.
PROCEDURE fill-tables :
define variable glog as logical no-undo .
define variable v-ii as integer no-undo .
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
IF p-mode = 'ДОБАВЛЕНИЕ':U AND tt-dis-rule.is-term = no and not v-is-copy then  RETURN.
IF tt-dis-rule.time-rule-num <> 0 THEN
FIND FIRST X_dis-time-rule WHERE X_dis-time-rule.time-rule-num = tt-dis-rule.time-rule-num NO-ERROR.
FOR EACH buf_tt0-term_dis-rule:
    DELETE buf_tt0-term_dis-rule.
END.
run ref/dcr-pos.p (
                   input p-mode
                  ,input no
                  ,input p-templ-rl-root
                  ,input tt-dis-rule.host-code
                  ,input tt-dis-rule.obj-type
                  ,input tt-dis-rule.obj-code
                  ,input tt-dis-rule.sts
                  ,input tt-dis-rule.rule-num
                  ,output v-pos-type) no-error.
if error-status:error then do:
message
 error-status:get-message(1) skip
 return-value
 view-as alert-box error .
 undo, return error .
end.
find first buf_dis-cfg-rule no-lock where
          buf_Dis-cfg-rule.pos-type = v-pos-type
      and buf_Dis-cfg-rule.table-name = 'dis-thbj-rule':U
      and buf_Dis-cfg-rule.link-prop = integer('3':U) no-error.
if available buf_dis-cfg-rule then do:
  assign
  v-ref-dr-templ-rl-root = buf_Dis-cfg-rule.templ-rl-root
  .
end.
else do:
  message
  "Не удается определить типа шаблона для правила по умолчанию"
  view-as alert-box error .
  undo, return error .
end.
END PROCEDURE.
PROCEDURE local-dr-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "key#_one" and p-action = "ret-mouse" then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec10   as recid no-undo .
define variable v-rid-list10   as character no-undo .
define variable v-sts10   as integer no-undo .
  find first dr-chk_dis-rule where
            dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
        and dr-chk_dis-rule.upper-rule-num > 0
    no-lock no-error.
  if not available dr-chk_dis-rule then do:
    v-rid-list10 = string(v-ref-rec10).
    run ref/dis-ruls.w (   input  parparentproc
                          ,input p-host-code
                          ,input p-obj-type
                          ,input p-obj-code
                          ,input "b-sel,b-add"
                          ,input (if p-obj-type = 'маг':U
                                  or p-obj-type = 'скл':U
                                  then "upper-rule-num-object"
                                  else "upper-rule-num")
                          ,input v-ref-dr-templ-rl-root
                          ,input ?
                          ,input 0
                          ,input-output v-sts10
                          ,input-OUTPUT v-rid-list10) NO-ERROR.
    assign v-ref-rec10 = integer( v-rid-list10 ).
    find first dr-chk_dis-rule where
            recid (dr-chk_dis-rule) = v-ref-rec10  no-lock no-error.
    if not available dr-chk_dis-rule then do:
      find first dr-chk_dis-rule where
                dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
            and dr-chk_dis-rule.upper-rule-num > 0
      no-lock no-error.
    end.
    if available dr-chk_dis-rule
    and v-ref-dr-templ-rl-root <> 0
    and dr-chk_dis-rule.templ-rl-root <> v-ref-dr-templ-rl-root then do:
      message
      substitute("Правило скидки должно быть типа &1", v-ref-dr-templ-rl-root)
      view-as alert-box error .
      find first dr-chk_dis-rule where
               dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
           and dr-chk_dis-rule.upper-rule-num > 0
      no-lock no-error.
    end.
  end.
  if available dr-chk_dis-rule then do:
    display
    dr-chk_dis-rule.rule-num @ tt-dis-rule.key#_one
    dr-chk_dis-rule.des @ key#_one-name
    with frame Dialog-Frame.
    assign frame Dialog-Frame tt-dis-rule.key#_one.
  end.
  else display ? @ tt-dis-rule.key#_one
               ? @ key#_one-name with frame Dialog-Frame.
  apply "entry" to  b-exit  in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "key#_one" and p-action = "button" then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec11   as recid no-undo .
define variable v-rid-list11   as character no-undo .
define variable v-sts11   as integer no-undo .
  find dr-chk_dis-rule where
       dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
   and dr-chk_dis-rule.upper-rule-num > 0
     no-lock no-error.
  assign
  v-ref-rec11 = ( if available dr-chk_dis-rule then recid( dr-chk_dis-rule) else ? ).
  release dr-chk_dis-rule.
  if not available dr-chk_dis-rule then do:
    v-rid-list11 = string(v-ref-rec11).
    run ref/dis-ruls.w (   input  parparentproc
                          ,input p-host-code
                          ,input p-obj-type
                          ,input p-obj-code
                          ,input "b-sel,b-add"
                          ,input (if p-obj-type = 'маг':U
                                  or p-obj-type = 'скл':U
                                  then "upper-rule-num-object"
                                  else "upper-rule-num")
                          ,input v-ref-dr-templ-rl-root
                          ,input ?
                          ,input 0
                          ,input-output v-sts11
                          ,input-OUTPUT v-rid-list11) NO-ERROR.
    assign v-ref-rec11 = integer( v-rid-list11 ).
    find first dr-chk_dis-rule where
            recid (dr-chk_dis-rule) = v-ref-rec11  no-lock no-error.
    if not available dr-chk_dis-rule then do:
      find first dr-chk_dis-rule where
                dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
            and dr-chk_dis-rule.upper-rule-num > 0
      no-lock no-error.
    end.
    if available dr-chk_dis-rule
    and v-ref-dr-templ-rl-root <> 0
    and dr-chk_dis-rule.templ-rl-root <> v-ref-dr-templ-rl-root then do:
      message
      substitute("Правило скидки должно быть типа &1", v-ref-dr-templ-rl-root)
      view-as alert-box error .
      find first dr-chk_dis-rule where
               dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
           and dr-chk_dis-rule.upper-rule-num > 0
      no-lock no-error.
    end.
  end.
  if available dr-chk_dis-rule then do:
    display
    dr-chk_dis-rule.rule-num @ tt-dis-rule.key#_one
    dr-chk_dis-rule.des @ key#_one-name
    with frame Dialog-Frame.
    assign frame Dialog-Frame tt-dis-rule.key#_one.
  end.
  else display ? @ tt-dis-rule.key#_one
               ? @ key#_one-name with frame Dialog-Frame.
  apply "entry" to  b-exit  in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "key#_one" and p-action = "leave-message" then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec12   as recid no-undo .
define variable v-rid-list12   as character no-undo .
define variable v-sts12   as integer no-undo .
  find first dr-chk_dis-rule where
            dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
        and dr-chk_dis-rule.upper-rule-num > 0
    no-lock no-error.
if available dr-chk_dis-rule then do:
    display
    dr-chk_dis-rule.rule-num @ tt-dis-rule.key#_one
    dr-chk_dis-rule.des @ key#_one-name
    with frame Dialog-Frame.
        assign frame Dialog-Frame tt-dis-rule.key#_one.
end.
else do:
  display
  ? @ tt-dis-rule.key#_one
  ? @ key#_one-name
  with frame Dialog-Frame.
end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable ii AS INTEGER NO-UNDO.
define variable v-lookup-dtr1 AS CHARACTER NO-UNDO.
define variable v-lookup-dtr2 AS CHARACTER NO-UNDO.
define variable v-dop as character no-undo .
define variable v-entry as character no-undo .
define variable jj as integer no-undo .
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-h AS handle NO-UNDO.
v-list-items = "":U + chr(44) + "":U.
DO v-ii = 1 TO NUM-ENTRIES('IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U):
    ASSIGN
    v-list-items = v-list-items +  chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,MARIA,Накладная,Бэкофис':U) + chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U).
END.
assign
f-pos-type:list-item-pairs in frame Dialog-Frame = v-list-items.
if can-find( first ub.dis-cfg-rule no-lock where
                   ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
               and ub.dis-cfg-rule.table-name = 'dis-thbj-rule':U)
or p-mode = 'ДОБАВЛЕНИЕ':U then do:
  f-pos-type = v-pos-type.
  f-pos-type:VISIBLE IN FRAME Dialog-Frame = YES.
  display f-pos-type
  with frame Dialog-Frame .
END.
ASSIGN
v-lookup-dtr1 = IF lookup("time-rule-num":U, v-level-1) > 0 THEN "b-time-rule-lookup"
                ELSE "":U
v-lookup-dtr2 = if lookup("time-rule-num":U, v-level-2) > 0 THEN "b-time-rule-lookup"
                ELSE "":U
v-tab-order = "b-exit,b-quit," + v-lookup-dtr1 +
              "des," + v-lookup-dtr2 +
              "key#_one,b-rule-num,time-rule-num,b-dis-time-rule"
              s-discnt-type:LIST-ITEMS IN FRAME Dialog-Frame = '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U
s-discnt-type:PRIVATE-DATA = '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U
S-subject-type:LIST-ITEMS = 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U
s-subject-type:PRIVATE-DATA = '0,1,2,3,4,5,7,8':U
FRAME Dialog-Frame:TITLE = FRAME Dialog-Frame:TITLE + chr(32) + v-des
f-region = gtregion(tt-dis-rule.host-code, tt-dis-rule.obj-type, tt-dis-rule.obj-code, no)
.
DO ii = 1 TO NUM-ENTRIES('0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U):
    ASSIGN
    tt-dis-rule.value-type:list-item-pairs = (if ii = 1 then "":U else tt-dis-rule.value-type:list-item-pairs) +
                                           (IF ii = 1 THEN "":U ELSE chr(44)) +
                                           ENTRY(ii, '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) + chr(44) +
                                           ENTRY(ii, '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U)
    .
END.
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, YES , 1 ).
assign
s-discnt-type = entry (lookup (string(tt-dis-rule.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U)
.
ASSIGN
s-subject-type =  entry (lookup (string(tt-dis-rule.subject-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U)
.
DISPLAY
S-discnt-type
S-subject-type
f-region
WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-rule THEN
  DISPLAY
  tt-dis-rule.des
  tt-dis-rule.rule-num
  tt-dis-rule.value-type
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-exit WHEN p-mode <> 'ПРОСМОТР':U
  b-hist when p-mode <> 'ДОБАВЛЕНИЕ':U
  B-Help
  tt-dis-rule.des WHEN p-mode <> 'ПРОСМОТР':U
  WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
  HIDE
  b-exit
  B-dis-time-rule
  b-dis-rule
  IN FRAME Dialog-Frame.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:column = 1
.
END.
IF p-mode = 'ПРОСМОТР':U THEN APPLY "ENTRY" TO b-exit.
run disrules-override-labels(input p-templ-rl-root) no-error .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec13   as recid no-undo .
define variable v-rid-list13   as character no-undo .
define variable v-sts13   as integer no-undo .
  find first dr-chk_dis-rule where
            dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
        and dr-chk_dis-rule.upper-rule-num > 0
    no-lock no-error.
if not available dr-chk_dis-rule then do:
  if input frame Dialog-Frame tt-dis-rule.key#_one <> 0
      and input frame Dialog-Frame tt-dis-rule.key#_one <> ? then
    message "Из справочника правил кидко Вы должны выбрать правило скидки.".
  display tt-dis-rule.key#_one with frame Dialog-Frame.
  find first dr-chk_dis-rule no-lock where
            dr-chk_dis-rule.rule-num = input frame Dialog-Frame tt-dis-rule.key#_one
        and dr-chk_dis-rule.upper-rule-num > 0
   no-error.
end.
if available dr-chk_dis-rule then do:
    display
    dr-chk_dis-rule.rule-num @ tt-dis-rule.key#_one
    dr-chk_dis-rule.des @ key#_one-name
    with frame Dialog-Frame.
end.
else do:
  display
  ? @ tt-dis-rule.key#_one
  ? @ key#_one-name
  with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-b-dis-time-rule :
define variable v-time-rule-num like ub.dis-rule.time-rule-num no-undo .
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO INIT -1.
DEFINE VARIABLE v-rid-list AS character NO-UNDO  .
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if input frame Dialog-Frame tt-dis-rule.time-rule-num <> 0
and input frame Dialog-Frame tt-dis-rule.time-rule-num <> ? then do:
  find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = input frame Dialog-Frame tt-dis-rule.time-rule-num no-error .
  if available buf_dis-time-rule then do:
    assign
    v-rid-list = string(recid(buf_dis-time-rule)).
  end.
end.
run ref/dist-rls.w (
                input parparentproc
              ,input "b-sel,b-add"
              ,input "dis-rule"
              ,input tt-dis-rule.templ-rl-root
              ,input 0
              ,input ''
              ,input-output v-sts
              ,input-output v-rid-list) no-error .
IF v-rid-list = "":U THEN RETURN ERROR.
FIND FIRST buf_dis-time-rule NO-LOCK WHERE
          RECID(buf_dis-time-rule) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
if error-status:error
  then  do:
  return error.
end.
ASSIGN
v-time-rule-num = buf_dis-time-rule.time-rule-num.
find first X_dis-time-rule no-lock where
          X_dis-time-rule.time-rule-num = v-time-rule-num NO-ERROR.
      .
assign
tt-dis-rule.time-rule-num =  X_dis-time-rule.time-rule-num
tt-dis-rule.time-templ-rl-root = X_dis-time-rule.templ-rl-root
.
display
tt-dis-rule.time-rule-num
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-log AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-dub-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-dis-rule then do:
    create tt-dis-rule.
end.
assign frame Dialog-Frame
tt-dis-rule.des
.
  IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
  tt-dis-rule.time-rule-num
    .
  else do:
    if lookup("time-rule-num", v-level-1) = 0 then do:
      assign
      tt-dis-rule.time-rule-num = 0
      tt-dis-rule.time-templ-rl-root = 0
      .
    end.
  end.
  IF tt-dis-rule.key#_one:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
  tt-dis-rule.key#_one
    .
run ref/diffdisr.p ( input p-mode
              , INPUT TABLE tt-dis-rule
              , INPUT TABLE tt0-term_dis-rule
              , OUTPUT v-dub-rule-num) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-dub-rule-num <> 0 THEN DO:
   MESSAGE
    substitute("В системе уже существует точно такое же правило скидок (правило № &1)", v-dub-rule-num) SKIP
    "Вы уверены, что хотите создать еще одно такое же правило?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-log.
    IF NOT v-log THEN undo, RETURN ERROR.
END.
run ref/dis-rul1.p (
input (IF p-mode = 'ДОБАВЛЕНИЕ':U THEN ? ELSE tt-dis-rule.rule-num )
,input v-pos-type
,input p-templ-rl-root
,input p-templ-rl-root
,input tt-dis-rule.des
,input tt-dis-rule.dis-kat
,input tt-dis-rule.discnt-type
,input tt-dis-rule.doc-qnty
,input tt-dis-rule.tot-sum
,input tt-dis-rule.charkey_one
,input tt-dis-rule.charkey_two
,input tt-dis-rule.charkey_three
,input tt-dis-rule.deckey_one
,input tt-dis-rule.deckey_two
,input tt-dis-rule.deckey_three
,input tt-dis-rule.key#_one
,input tt-dis-rule.key#_two
,input tt-dis-rule.key#_three
,input tt-dis-rule.subject-type
,input tt-dis-rule.time-templ-rl-root
,input tt-dis-rule.time-rule-num
,input tt-dis-rule.upper-rule-num
,input tt-dis-rule.value-type
,input tt-dis-rule.host-code
,INPUT tt-dis-rule.obj-type
,INPUT tt-dis-rule.obj-code
,INPUT tt-dis-rule.discnt-value
,input table tt0-term_dis-rule
,input-output p-recid
,input p-mode
,input NO
) NO-ERROR.
if error-status:error then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END PROCEDURE.
PROCEDURE proc-time-rule-lookup :
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
IF lookup("time-rule-num", v-level-1) > 0
or lookup("time-rule-num", v-level-2) > 0
tHEN DO:
  IF lookup("time-rule-num":U, v-level-1) > 0 THEN DO:
        run ref/dis-timi.w (
                   input parParentProc
                  ,input 'ПРОСМОТР':U
                  ,input 0
                  ,input tt-dis-rule.time-rule-num
                  ,input 0
                  ,input-output loc-doc-rec
                  ) no-error .
  END.
  ELSE DO:
   IF AVAILABLE tt0-term_dis-rule THEN DO:
     run ref/dis-timi.w (
                   input parParentProc
                  ,input 'ПРОСМОТР':U
                  ,input 0
                  ,input tt0-term_dis-rule.time-rule-num
                  ,input 0
                  ,input-output loc-doc-rec
                  ) no-error .
    END.
  END.
END.
END PROCEDURE.
