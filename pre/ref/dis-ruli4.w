DEFINE BUFFER locked_dis-rule FOR ub.dis-rule.
DEFINE BUFFER root_dis-rule FOR ub.dis-rule.
DEFINE BUFFER template_dis-rule FOR ub.dis-rule.
DEFINE BUFFER term_dis-rule FOR ub.dis-rule.
DEFINE TEMP-TABLE tt-dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
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
define variable vss-description as character no-undo init "Редактирование правил скидок - временная скидка, задаваемая через ТПЛ".
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
define variable  v-term-value-type   like ub.dis-rule.value-type        no-undo .
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
DEFINE VARIABLE v-doc-num LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE v-road-tax LIKE ub.price-list.road-tax NO-UNDO.
DEFINE VARIABLE v-excise LIKE ub.price-list.excise NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable v-radio-integer-handle as handle no-undo .
define variable v-pos-type as character no-undo .
define variable v-is-copy as logical no-undo .
define variable v-start-br-term-dr-format as logical no-undo init yes.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
define buffer buf_temp-drt-prop for temp-drt-prop.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
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
DEFINE BUTTON B-exit-1
     LABEL "Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-plt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-plt-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit-1
     LABEL "Отмена"
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
DEFINE VARIABLE charkey_one-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 96.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-region AS CHARACTER FORMAT "X(256)":U
     LABEL "Действует"
      VIEW-AS TEXT
     SIZE 22.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-term-dr FOR
      tt0-term_dis-rule SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-dis-rule,
      locked_dis-rule SCROLLING.
DEFINE BROWSE BR-term-dr
  QUERY BR-term-dr NO-LOCK DISPLAY
      entry (lookup (string(tt0-term_dis-rule.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) COLUMN-LABEL "Тип" FORMAT "X(10)":U
tt0-term_dis-rule.time-rule-num FORMAT "->>>>>>>>9":U
tt0-term_dis-rule.charkey_one FORMAT "X(12)":U
tt0-term_dis-rule.des FORMAT "X(255)":U
tt0-term_dis-rule.rule-num FORMAT ">>>>>>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56.5 BY 13.29
         FONT 4
         TITLE "Детализация" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
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
     s-discnt-type AT ROW 3.92 COL 14 COLON-ALIGNED
     f-pos-type AT ROW 3.92 COL 46 COLON-ALIGNED WIDGET-ID 6
     s-subject-type AT ROW 4.92 COL 14 COLON-ALIGNED
     B-plt AT ROW 5.92 COL 50.5 WIDGET-ID 16
     tt-dis-rule.time-rule-num AT ROW 5.92 COL 65.5 COLON-ALIGNED
          LABEL "№ расп."
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     B-dis-time-rule AT ROW 5.92 COL 76
     tt-dis-rule.CharKey_One AT ROW 6 COL 31 COLON-ALIGNED WIDGET-ID 8
          LABEL "Поле1"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     charkey_one-name AT ROW 6.92 COL 2.5 NO-LABEL WIDGET-ID 12
     B-exit-1 AT ROW 7.92 COL 22
     B-quit-1 AT ROW 7.92 COL 32
     B-add AT ROW 7.92 COL 59
     B-del AT ROW 7.92 COL 69
     b-plt-lookup AT ROW 7.92 COL 79 WIDGET-ID 18
     B-time-rule-lookup AT ROW 7.92 COL 89
     BR-term-dr AT ROW 8.92 COL 42.5
     tt-dis-rule.rule-num AT ROW 1.25 COL 71.5 COLON-ALIGNED
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
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-dis-time-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-exit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-plt:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-quit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-time-rule-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-rule.CharKey_One:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       charkey_one-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       tt-dis-rule.time-rule-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
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
  IF b-exit-1:VISIBLE IN FRAME Dialog-Frame THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
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
IF b-exit-1:VISIBLE IN FRAME Dialog-Frame THEN DO:
    BELL.
    RETURN NO-APPLY.
END.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
ON CHOOSE OF B-exit-1 IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN proc-b-exit-1 IN THIS-PROCEDURE NO-ERROR.
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
ON CHOOSE OF B-plt IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-charkey_one AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 DEFINE BUFFER local_price-list-type FOR ub.price-list-type.
 DEFINE BUFFER local2_price-list-type FOR ub.price-list-type.
 IF AVAILABLE tt0-term_dis-rule
 and tt0-term_dis-rule.charkey_one <> '' then do:
    find first local_price-list-type no-lock where
              local_price-list-type.plt-id = integer(entry(1, tt0-term_dis-rule.charkey_one, "-") )
          and local_price-list-type.plt-db-num = integer(entry(2, tt0-term_dis-rule.charkey_one, "-") ) no-error.
    if available local_price-list-type then do:
      v-rid-list = STRING(RECID(local_price-list-type)).
      charkey_one-name =     local_price-list-type.NAME .
      display
      tt0-term_dis-rule.charkey_one @ tt-dis-rule.charkey_one
      charkey_one-name
      with frame Dialog-Frame .
    end.
 END.
 v-rid-list = string(p-templ-rl-root).
 run ref/typepric.w (
                      input  parParentProc
                     ,INPUT "b-sel,mode=ban-discnt"
                     ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
IF error-status:error
or v-rid-list = ""
THEN RETURN NO-APPLY.
 IF (available local_price-list-type and v-rid-list <> string(p-templ-rl-root))
 or not available local_price-list-type
 THEN DO:
     FIND FIRST local2_price-list-type NO-LOCK WHERE
                recid(local2_price-list-type) = INTEGER(v-rid-list) NO-ERROR.
    IF AVAILABLE local2_price-list-type THEN DO:
        ASSIGN
        tt-dis-rule.charkey_one = SUBSTITUTE("&1-&2"
                                             , local2_price-list-type.plt-id
                                             , local2_price-list-type.plt-db-num)
        charkey_one-name =     local2_price-list-type.NAME
        .
        DISPLAY
        tt-dis-rule.charkey_one
        charkey_one-name
        WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
        MESSAGE
        substitute("Не удалось найти ТПЛ с recid=&1", v-rid-list)
        VIEW-AS ALERT-BOX ERROR.
    END.
 END.
 apply "entry" to tt-dis-rule.charkey_one in FRAME Dialog-Frame.
 return no-apply.
END.
ON CHOOSE OF b-plt-lookup IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-recid AS RECID NO-UNDO.
define buffer loc_price-list-type for ub.price-list-type.
  IF AVAILABLE tt0-term_dis-rule then do:
    if tt0-term_dis-rule.charkey_one <> '' then do:
        find first loc_price-list-type where
                  loc_price-list-type.plt-id = integer(entry(1, tt0-term_dis-rule.charkey_one, "-"))
               and loc_price-list-type.plt-db-num = integer(entry(2, tt0-term_dis-rule.charkey_one, "-")) no-error.
        if available loc_price-list-type then do:
            v-recid = RECID(loc_price-list-type).
            run ref/tp-price.w ( input parparentproc
                              ,input NO
                              ,INPUT 'ПРОСМОТР':U
                               ,INPUT-OUTPUT v-recid ) NO-ERROR.
        end.
        ELSE DO:
           MESSAGE
           "Тип прайс-листа не определен, возможно удален"
           VIEW-AS ALERT-BOX ERROR.
         END.
    end.
    ELSE DO:
      MESSAGE
      "Тип прайс-листа не определен"
      VIEW-AS ALERT-BOX ERROR.
    END.
  END.
END.
ON CHOOSE OF B-quit-1 IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN proc-b-quit-1 IN THIS-PROCEDURE.
END.
ON CHOOSE OF B-time-rule-lookup IN FRAME Dialog-Frame
DO:
  RUN proc-time-rule-lookup IN THIS-PROCEDURE (V-TREE) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF BR-term-dr IN FRAME Dialog-Frame
DO:
  IF AVAILABLE tt0-term_dis-rule
  AND tt0-term_dis-rule.time-rule-num > 0
  AND lookup("time-rule-num", v-level-2) > 0 THEN DO:
     ENABLE
     b-time-rule-lookup
     WITH FRAME Dialog-Frame.
  END.
  if available tt0-term_dis-rule then do:
    assign
    v-term-value-type = tt0-term_dis-rule.value-type.
  end.
  else do:
    assign
    v-term-value-type = v-value-type.
  end.
END.
ON LEAVE OF tt-dis-rule.time-rule-num IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-term-dr :handle
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
    run diasize_init in this-procedure .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    for each buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
                and buf_temp-drt-prop.prop-code = "Column-Label":U:
      assign
      fh = browse BR-term-dr:first-column
      .
      do while valid-handle(fh):
        if index(fh:name, buf_temp-drt-prop.upper-prop-code) > 0 then do:
          assign
          fh:label = buf_temp-drt-prop.property-value
          .
        end.
        fh = fh:next-column.
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
  v-term-value-type = v-value-type.
  run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
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
    IF p-main THEN DO:
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
      IF lookup("charkey_one":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.charkey_one
         WITH FRAME Dialog-Frame.
         ENABLE
         tt-dis-rule.charkey_one WHEN p-mode <> 'ПРОСМОТР':U
         WITH FRAME Dialog-Frame.
      END.
      else do:
        hide
        tt-dis-rule.charkey_one
        in FRAME Dialog-Frame.
      end.
    END.
    ELSE DO:
      IF lookup("time-rule-num", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        in FRAME Dialog-Frame.
        ENABLE
        tt-dis-rule.time-rule-num WHEN p-mode <> 'ПРОСМОТР':U
        b-dis-time-rule WHEN p-mode <> 'ПРОСМОТР':U
        B-time-rule-lookup
        WITH FRAME Dialog-Frame.
      END.
      else do:
        hide
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        B-time-rule-lookup
        in FRAME Dialog-Frame.
      end.
      IF lookup("charkey_one", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.charkey_one
        in FRAME Dialog-Frame.
        ENABLE
        tt-dis-rule.charkey_one WHEN p-mode <> 'ПРОСМОТР':U
        WITH FRAME Dialog-Frame.
      END.
      else do:
        hide
        tt-dis-rule.charkey_one
        in FRAME Dialog-Frame.
      end.
    END.
  END.
  WHEN 0 THEN DO:
    HIDE
    tt-dis-rule.charkey_one
    tt-dis-rule.time-rule-num
    b-time-rule-lookup
    b-dis-time-rule
    in FRAME Dialog-Frame.
  END.
END CASE.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-dis-rule SHARE-LOCK,       EACH locked_dis-rule WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY s-discnt-type f-pos-type s-subject-type charkey_one-name F-region
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-rule THEN
    DISPLAY tt-dis-rule.des tt-dis-rule.value-type tt-dis-rule.time-rule-num
          tt-dis-rule.CharKey_One tt-dis-rule.rule-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-dis-rule.des tt-dis-rule.value-type
         f-pos-type B-plt tt-dis-rule.time-rule-num B-dis-time-rule
         tt-dis-rule.CharKey_One B-exit-1 B-quit-1 B-add B-del b-plt-lookup
         B-time-rule-lookup BR-term-dr tt-dis-rule.rule-num F-region
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
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
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
  undo,  return error.
end.
assign
v-dis-kat-tree   = lookup("dis-kat":U, v-tree) > 0
v-doc-qnty-tree  = lookup("doc-qnty":U, v-tree) > 0
v-tot-sum-tree   = lookup("tot-sum":U,  v-tree) > 0
v-time-rule-num-tree = lookup("time-rule-num":U, v-tree) > 0
v-charkey_one-tree = lookup("charkey_one":U, v-tree) > 0
v-charkey_two-tree = lookup("charkey_two":U, v-tree) > 0
v-charkey_three-tree = lookup("charkey_three":U, v-tree) > 0
v-deckey_one-tree = lookup("deckey_one":U, v-tree) > 0
v-deckey_two-tree = lookup("deckey_two":U, v-tree) > 0
v-deckey_three-tree = lookup("deckey_three":U, v-tree) > 0
v-key#_one-tree = lookup("key#_one":U, v-tree) > 0
v-key#_two-tree = lookup("key#_two":U, v-tree) > 0
v-key#_three-tree = lookup("key_#three":U, v-tree) > 0
.
v-ii = 0.
if tt-dis-rule.is-term = no then do:
  FOR EACH buf_dis-rule NO-LOCK WHERE
          buf_dis-rule.upper-rule-num = (if v-is-copy then p-rule-num else tt-dis-rule.rule-num):
    v-ii = v-ii + 1.
    CREATE buf_tt0-term_dis-rule.
    BUFFER-COPY buf_dis-rule
    except rule-num upper-rule-num
    TO buf_tt0-term_dis-rule
    ASSIGN
    buf_tt0-term_dis-rule.rule-num = (if v-is-copy then v-ii else buf_dis-rule.rule-num)
    buf_tt0-term_dis-rule.upper-rule-num = (if v-is-copy then abs(tt-dis-rule.rule-num) else buf_dis-rule.upper-rule-num)
    buf_tt0-term_dis-rule.doc-qnty = (IF lookup("discnt-value":U, v-level-2) = 0
                                      THEN 0
                                      ELSE buf_dis-rule.discnt-value)
    buf_tt0-term_dis-rule.doc-qnty = (IF lookup("doc-qnty":U, v-level-2) = 0
                                      THEN 0
                                      ELSE buf_dis-rule.doc-qnty)
    buf_tt0-term_dis-rule.dis-kat = (IF lookup("dis-kat":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.dis-kat)
    buf_tt0-term_dis-rule.tot-sum = (IF lookup("tot-sum":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.tot-sum)
    buf_tt0-term_dis-rule.time-rule-num = (IF lookup("time-rule-num":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.time-rule-num)
    buf_tt0-term_dis-rule.charkey_one = (IF lookup("charkey_one":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_one)
    buf_tt0-term_dis-rule.charkey_two = (IF lookup("charkey_two":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_two)
    buf_tt0-term_dis-rule.charkey_three = (IF lookup("charkey_three":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_three)
    buf_tt0-term_dis-rule.deckey_one = (IF lookup("deckey_one":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_one)
    buf_tt0-term_dis-rule.deckey_two = (IF lookup("deckey_two":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_two)
    buf_tt0-term_dis-rule.deckey_three = (IF lookup("deckey_three":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_three)
    buf_tt0-term_dis-rule.key#_one = (IF lookup("key#_one":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_one)
    buf_tt0-term_dis-rule.key#_two = (IF lookup("key#_two":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_two)
    buf_tt0-term_dis-rule.key#_three = (IF lookup("key#_three":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_three)
    .
  END.
end.
else do:
  FOR EACH buf_dis-rule NO-LOCK WHERE
          buf_dis-rule.rule-num = (if v-is-copy then p-rule-num else tt-dis-rule.rule-num):
    leave.
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
define buffer buf_temp-drt-prop for temp-drt-prop.
v-h = br-term-dr:FIRST-COLUMN IN FRAME Dialog-Frame.
DO while valid-handle(v-h) :
  find first buf_temp-drt-prop no-lock where
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
        and buf_temp-drt-prop.upper-prop-code = v-h:name
        and buf_temp-drt-prop.prop-code = "column-label" no-error.
  if available buf_temp-drt-prop then do:
    assign
    v-h:label = buf_temp-drt-prop.property-value.
  end.
  if v-h:LABEL = "Тип" then do:
    v-h:RESIZABLE = YES.
    v-h:visible = (v-value-type = integer('9':U)).
  end.
  v-h = v-h:NEXT-COLUMN.
END.
v-list-items = "":U + chr(44) + "":U.
DO v-ii = 1 TO NUM-ENTRIES('IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U):
    ASSIGN
    v-list-items = v-list-items +  chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,MARIA,Накладная,Бэкофис':U) + chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U).
END.
assign
f-pos-type:list-item-pairs in frame Dialog-Frame = v-list-items.
ASSIGN
tt0-term_dis-rule.time-rule-num:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.charkey_one:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.time-rule-num:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.charkey_one:auto-resize IN BROWSE BR-term-dr = true
.
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
              "des,b-add,b-del," + v-lookup-dtr2 +
              "time-rule-num,b-dis-time-rule,"  +
              "charkey_one," +
              "b-exit-1,b-quit-1"
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
IF v-tree = "":U THEN DO:
  HIDE
  br-term-dr
  b-exit-1
  b-quit-1
  b-add
  b-del
  in FRAME Dialog-Frame.
END.
ELSE DO:
    DO ii = 1 TO NUM-ENTRIES(v-level-2):
      case ENTRY(ii, v-level-2):
        WHEN "time-rule-num":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.time-rule-num:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "charkey_one":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.charkey_one:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
      END CASE.
    END.
    ENABLE
    b-add WHEN p-mode <> 'ПРОСМОТР':U
    b-DEL WHEN p-mode <> 'ПРОСМОТР':U
    b-plt-lookup
    WITH FRAME Dialog-Frame.
END.
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
  B-dis-time-rule IN FRAME Dialog-Frame.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:column = 1
  .
END.
IF v-tree <> "":u THEN DO:
  ENABLE
  br-term-dr
  WITH FRAME Dialog-Frame.
  RUN openbr-term-dr in this-procedure .
  APPLY "VALUE-CHANGED" TO br-term-dr IN FRAME Dialog-Frame.
END.
IF p-mode = 'ПРОСМОТР':U THEN APPLY "ENTRY" TO b-exit.
ELSE do:
  IF v-tree <> "":U THEN
  APPLY "entry" to b-add.
END.
run disrules-override-labels(input p-templ-rl-root) no-error .
END PROCEDURE.
PROCEDURE OpenBr-term-dr :
define variable v-h as widget-handle no-undo .
v-h = br-term-dr:FIRST-COLUMN IN FRAME Dialog-Frame.
OPEN QUERY BR-term-dr
  FOR  EACH tt0-term_dis-rule WHERE
          tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num
BY tt0-term_dis-rule.time-rule-num
.
if available tt0-term_dis-rule
and v-start-br-term-dr-format
then do:
  v-start-br-term-dr-format = no.
  DO while valid-handle(v-h) :
    find first buf_temp-drt-prop no-lock where
              buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
          and buf_temp-drt-prop.upper-prop-code = v-h:name
          and buf_temp-drt-prop.prop-code = "format":U no-error.
    if available buf_temp-drt-prop then do:
      assign
      v-h:format = buf_temp-drt-prop.property-value.
    end.
    v-h = v-h:NEXT-COLUMN.
  END.
end.
END PROCEDURE.
PROCEDURE proc-b-add :
define variable choice as integer no-undo .
IF v-tree = "":U THEN RETURN ERROR.
IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME Dialog-Frame THEN
ASSIGN
tt-dis-rule.time-rule-num
.
IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME Dialog-Frame THEN
ASSIGN
tt-dis-rule.charkey_one
.
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, NO , 1 ).
IF v-time-rule-num-tree
AND tt-dis-rule.time-rule-num:sensitive  IN FRAME Dialog-Frame THEN DO:
   DISPLAY
   0 @ tt-dis-rule.time-rule-num
   WITH FRAME Dialog-Frame.
END.
IF v-charkey_one-tree
AND tt-dis-rule.charkey_one:sensitive  IN FRAME Dialog-Frame THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.charkey_one
   WITH FRAME Dialog-Frame.
END.
ENABLE
b-exit-1
b-quit-1
b-plt
WITH FRAME Dialog-Frame.
hide
b-add
b-del
b-plt-lookup
in frame Dialog-Frame.
disable
b-exit
with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
IF v-tree = "":U THEN RETURN ERROR.
IF NOT AVAILABLE tt0-term_dis-rule THEN RETURN.
FIND first buf_tt0-term_dis-rule WHERE RECID(buf_tt0-term_dis-rule) = RECID(tt0-term_dis-rule).
DELETE buf_tt0-term_dis-rule.
RUN rename-term_dis-rule in this-procedure .
RUN openbr-term-dr in this-procedure .
END PROCEDURE.
PROCEDURE proc-b-dis-time-rule :
define variable v-time-rule-num like ub.dis-rule.time-rule-num no-undo .
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO INIT -1.
DEFINE VARIABLE v-rid-list AS character NO-UNDO  .
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule .
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
              ,input ( if p-mode = 'ДОБАВЛЕНИЕ':U or not available buf_dis-time-rule then 'dis-rule':U else ("rule-num" + chr(44) + 'ИЗМЕНЕНИЕ':U))
              ,input (if p-mode = 'ДОБАВЛЕНИЕ':U or not available buf_dis-time-rule then tt-dis-rule.templ-rl-root else tt-dis-rule.rule-num)
              ,input ( if p-mode = 'ДОБАВЛЕНИЕ':U or not available buf_dis-time-rule then 0 else tt-dis-rule.time-templ-rl-root)
              ,input p-pos-type
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
PROCEDURE proc-b-exit-1 :
DEFINE VARIABLE v-doc-qnty LIKE ub.dis-rule.doc-qnty NO-UNDO.
DEFINE VARIABLE v-dis-kat LIKE ub.dis-rule.dis-kat NO-UNDO.
DEFINE VARIABLE v-tot-sum LIKE ub.dis-rule.tot-sum NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-rule.time-rule-num NO-UNDO.
define variable v-charkey_one like ub.dis-rule.charkey_one no-undo .
define variable v-charkey_two like ub.dis-rule.charkey_two no-undo .
define variable v-charkey_three like ub.dis-rule.charkey_three no-undo .
define variable v-deckey_one like ub.dis-rule.deckey_one no-undo .
define variable v-deckey_two like ub.dis-rule.deckey_two no-undo .
define variable v-deckey_three like ub.dis-rule.deckey_three no-undo .
define variable v-key#_one like ub.dis-rule.key#_one no-undo .
define variable v-key#_two like ub.dis-rule.key#_two no-undo .
define variable v-key#_three like ub.dis-rule.key#_three no-undo .
DEFINE VARIABLE v-discnt-value LIKE ub.dis-rule.discnt-value NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
DEFINE VARIABLE v-dub AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
IF v-tree = "":U  THEN RETURN ERROR.
ASSIGN
v-doc-qnty = tt-dis-rule.doc-qnty
v-dis-kat = tt-dis-rule.dis-kat
v-tot-sum = tt-dis-rule.tot-sum
v-time-rule-num = tt-dis-rule.time-rule-num
v-charkey_one = tt-dis-rule.charkey_one
v-charkey_two = tt-dis-rule.charkey_two
v-charkey_three = tt-dis-rule.charkey_three
v-deckey_one = tt-dis-rule.deckey_one
v-deckey_two = tt-dis-rule.deckey_two
v-deckey_three = tt-dis-rule.deckey_three
v-key#_one = tt-dis-rule.key#_one
v-key#_two = tt-dis-rule.key#_two
v-key#_three = tt-dis-rule.key#_three
.
IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  v-time-rule-num = INPUT FRAME Dialog-Frame tt-dis-rule.time-rule-num
  .
END.
IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  v-charkey_one = INPUT FRAME Dialog-Frame tt-dis-rule.charkey_one
  .
END.
define variable v-entry-entry as character no-undo .
define variable v-entry as character no-undo .
define variable v-entry-list as character no-undo .
define variable v-new-entry as character no-undo .
define variable nn as integer no-undo .
do nn = 1 to num-entries(v-tree):
  v-entry-entry = '':U.
  case entry(nn, v-tree):
    when "time-rule-num" then do:
      if v-time-rule-num <> -1
      then do:
        v-entry-entry = string(v-time-rule-num).
      end.
    end.
    when "charkey_one" then do:
      if v-charkey_one <> ?
      then do:
        v-entry-entry = string(v-charkey_one).
      end.
    end.
  end case.
  v-new-entry = v-new-entry +
            (if v-new-entry = '':U then "" else chr(4)) + v-entry-entry.
end.
_dub:
FOR EACH buf_tt0-term_dis-rule WHERE
        buf_tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num:
  ASSIGN
  v-rule-num = max(buf_tt0-term_dis-rule.rule-num, v-rule-num)
  .
  v-entry = '':U.
  do nn = 1 to num-entries(v-tree):
    assign
    v-entry-entry = string(buffer buf_tt0-term_dis-rule:buffer-field(entry(nn, v-tree)):buffer-value)
    .
    assign
    v-entry = v-entry +
              (if v-entry = '':U then "" else chr(4)) + v-entry-entry.
    v-entry-list = v-entry-list + (if v-entry-list = '':U then "" else chr(3)) + v-entry.
    if lookup(v-new-entry, v-entry-list, chr(3)) > 0 then do:
      assign
      v-dub = yes
      .
      MESSAGE
      substitute("Уже есть такое подправило с той же областью действия или параметрами")
      VIEW-AS ALERT-BOX.
      LEAVE _dub.
    end.
  end.
END.
IF v-dub THEN UNDO, RETURN ERROR.
CREATE buf_tt0-term_dis-rule.
BUFFER-COPY tt-dis-rule
EXCEPT rule-num
    upper-rule-num des
    lvl-num
    is-term
    root
TO buf_tt0-term_dis-rule
ASSIGN
buf_tt0-term_dis-rule.rule-num = v-rule-num + 1
buf_tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num
buf_tt0-term_dis-rule.doc-qnty = (IF v-doc-qnty = - 1 THEN 0 ELSE v-doc-qnty)
buf_tt0-term_dis-rule.dis-kat = (IF v-dis-kat = - 1 THEN 0 ELSE v-dis-kat)
buf_tt0-term_dis-rule.tot-sum = (IF v-tot-sum = -1 THEN 0 ELSE v-tot-sum)
buf_tt0-term_dis-rule.time-rule-num = (IF v-time-rule-num = 0 THEN 0 ELSE v-time-rule-num)
buf_tt0-term_dis-rule.key#_one = (IF v-key#_one = ? THEN 0 ELSE v-key#_one)
buf_tt0-term_dis-rule.key#_two = (IF v-key#_two = ? THEN 0 ELSE v-key#_two)
buf_tt0-term_dis-rule.key#_three = (IF v-key#_three = ? THEN 0 ELSE v-key#_three)
buf_tt0-term_dis-rule.charkey_one = (IF v-charkey_one = ? THEN "":U ELSE v-charkey_one)
buf_tt0-term_dis-rule.charkey_two = (IF v-charkey_two = ? THEN "":U ELSE v-charkey_two)
buf_tt0-term_dis-rule.charkey_three = (IF v-charkey_three = ? THEN "":U ELSE v-charkey_three)
buf_tt0-term_dis-rule.deckey_one = (IF v-deckey_one = ? THEN 0 ELSE v-deckey_one)
buf_tt0-term_dis-rule.deckey_two = (IF v-deckey_two = ? THEN 0 ELSE v-deckey_two)
buf_tt0-term_dis-rule.deckey_three = (IF v-deckey_three = ? THEN 0 ELSE v-deckey_three)
buf_tt0-term_dis-rule.discnt-value = v-discnt-value
buf_tt0-term_dis-rule.sts   = INTEGER('2':U)
buf_tt0-term_dis-rule.root   = no
buf_tt0-term_dis-rule.is-term   = yes
buf_tt0-term_dis-rule.lvl-num   = tt-dis-rule.lvl-num + 1
buf_tt0-term_dis-rule.value-type = v-term-value-type
.
RELEASE buf_tt0-term_dis-rule.
RUN display-hide-fields IN THIS-PROCEDURE(v-tree, NO, 0).
HIDE
b-exit-1
IN FRAME Dialog-Frame
b-quit-1
b-plt
charkey_one-name
IN FRAME Dialog-Frame.
display
b-add when p-mode <> 'ПРОСМОТР':U
b-del when p-mode <> 'ПРОСМОТР':U
b-plt-lookup
b-time-rule-lookup
with frame Dialog-Frame.
RUN rename-term_dis-rule in this-procedure .
RUN openbr-term-dr in this-procedure .
RUN display-hide-fields IN THIS-PROCEDURE(v-tree, yes, 1).
if p-mode <> 'ПРОСМОТР':U
then
enable
b-exit
with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-quit-1 :
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, NO , 0 ).
HIDE
b-exit-1
IN FRAME Dialog-Frame
b-quit-1
b-plt
charkey_one-name
IN FRAME Dialog-Frame.
display
b-add when p-mode <> 'ПРОСМОТР':U
b-del when p-mode <> 'ПРОСМОТР':U
b-plt-lookup
b-time-rule-lookup
with frame Dialog-Frame.
if p-mode <> 'ПРОСМОТР':U
then
enable
b-exit
with frame Dialog-Frame .
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
IF v-tree = "":U THEN DO:
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
  IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
  tt-dis-rule.charkey_one
    .
END.
ELSE DO:
  IF tt-dis-rule.time-rule-num:VISIBLE  IN FRAME Dialog-Frame THEN do:
    ASSIGN
    tt-dis-rule.time-rule-num
    .
  end.
  else do:
    if lookup("time-rule-num", v-level-1) = 0 then do:
      assign
      tt-dis-rule.time-rule-num = 0
      tt-dis-rule.time-templ-rl-root = 0
      .
    end.
  end.
  IF tt-dis-rule.charkey_one:VISIBLE  IN FRAME Dialog-Frame THEN
    ASSIGN
  tt-dis-rule.charkey_one
    .
  ASSIGN
  tt-dis-rule.discnt-value = 0
  .
END.
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE rename-term_dis-rule :
DEFINE VARIABLE v-doc-qnty LIKE ub.dis-rule.doc-qnty NO-UNDO.
DEFINE VARIABLE v-dis-kat LIKE ub.dis-rule.dis-kat NO-UNDO.
DEFINE VARIABLE v-tot-sum LIKE ub.dis-rule.tot-sum NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-rule.time-rule-num NO-UNDO.
define variable v-charkey_one like ub.dis-rule.charkey_one no-undo .
define variable v-charkey_two like ub.dis-rule.charkey_two no-undo .
define variable v-charkey_three like ub.dis-rule.charkey_three no-undo .
define variable v-deckey_one like ub.dis-rule.deckey_one no-undo .
define variable v-deckey_two like ub.dis-rule.deckey_two no-undo .
define variable v-deckey_three like ub.dis-rule.deckey_three no-undo .
define variable v-key#_one like ub.dis-rule.key#_one no-undo .
define variable v-key#_two like ub.dis-rule.key#_two no-undo .
define variable v-key#_three like ub.dis-rule.key#_three no-undo .
DEFINE VARIABLE v-discnt-value LIKE ub.dis-rule.discnt-value NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define variable v-label as character no-undo .
define variable v-label0 as character no-undo .
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer upper_temp-drt-prop for temp-drt-prop.
define buffer loc_Price-list-type for ub.price-list-type.
IF v-tree = "":U  THEN RETURN ERROR.
FOR EACH buf_tt0-term_dis-rule:
  buf_tt0-term_dis-rule.des = "".
END.
IF LOOKUP("time-rule-num", v-tree) > 0 THEN DO:
assign   ii = 0   v-label0 = "Расписание"   v-label = v-label0.   for each buf_temp-drt-prop no-lock where             buf_temp-drt-prop.templ-rl-root = p-templ-rl-root         and buf_temp-drt-prop.prop-code = "Label":U         and buf_temp-drt-prop.upper-prop-code = "time-rule-num":U,       first upper_temp-drt-prop no-lock where           upper_temp-drt-prop.templ-rl-root = p-templ-rl-root       and upper_temp-drt-prop.prop-code = buf_temp-drt-prop.upper-prop-code       and upper_temp-drt-prop.upper-prop-code = "Level2_UsingFields":U:     assign     v-label = buf_temp-drt-prop.property-value.     leave.   end.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num:
    find first loc_price-list-type no-lock where
              loc_price-list-type.plt-id = integer(entry(1, buf_tt0-term_dis-rule.charkey_one, "-"))
          and loc_price-list-type.plt-db-num = integer(entry(2, buf_tt0-term_dis-rule.charkey_one, "-")) no-error.
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 №&2 &3"
                                          , v-label
                                          , buf_tt0-term_dis-rule.time-rule-num
                                          , (if available loc_price-list-type then loc_price-list-type.name else '')
                                          )
    .
  END.
END.
END PROCEDURE.
