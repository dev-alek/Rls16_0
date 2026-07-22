using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-sea-code   like ub.season.sea-code no-undo.
define input parameter p-db-num like ub.season.db-num no-undo.
define input parameter p-name   like ub.season.sea-name no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары с темпами    ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE chk-gdssea :
define input  parameter p-gds-code as integer no-undo.
define input  parameter p-seaobj as character no-undo.
define input  parameter p-i-date1 as integer no-undo.
define input  parameter p-i-date2 as integer no-undo.
define input  parameter p-rowid as rowid no-undo.
define output parameter p-sea-code as integer no-undo.
define output parameter p-db-num as integer no-undo.
define output parameter p-ok as logical no-undo init yes.
define buffer buf_season for ub.season.
define buffer buf1_season for ub.season.
define buffer buf1_gds-season for ub.gds-season.
define buffer buf_season-attr for ub.season-attr.
define buffer buf1_season-attr for ub.season-attr.
  for each buf1_season no-lock where ((buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1)
    or (buf1_season.sea-month-1 <= p-i-date2 and buf1_season.sea-month-2 >= p-i-date2)
    or (buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1))
    and (rowid (buf1_season) <> p-rowid or p-rowid = ?):
      if can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                            and buf1_season-attr.db-num = buf1_season.db-num
                                            and buf1_season-attr.attr-code = 'sea-obj':U
                                            and buf1_season-attr.attr-value = p-seaobj
                                            )
        or
        (not can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                              and buf1_season-attr.db-num = buf1_season.db-num
                                              and buf1_season-attr.attr-code = 'sea-obj':U
                                              )
        and p-seaobj = "")
      then do:
        if can-find (first buf1_gds-season where  buf1_gds-season.sea-code = buf1_season.sea-code
                                              and buf1_gds-season.db-num = buf1_gds-season.db-num
                                              and buf1_gds-season.gds-code = p-gds-code)
        then do:
        assign
          p-ok = false
          p-sea-code = buf1_season.sea-code
          p-db-num = buf1_season.db-num.
          leave.
        end.
      end.
  end.
END PROCEDURE.
define buffer buf_season      for ub.season.
define buffer buf_season-attr for ub.season-attr.
define variable rid-list   as character no-undo .
define variable log-res    as log       no-undo.
define variable rr         as recid     no-undo.
define variable v-log      as logical   no-undo .
define variable v-cur-time as character no-undo.
define variable line-mode  as character no-undo .
define variable doc-rec    as recid     no-undo .
define variable gds-rec    as recid     no-undo .
define variable lns-cnt    as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable v-value    as character no-undo .
define variable v-type     as character no-undo .
define variable is-erpRn   as logical no-undo .
define temp-table tt-gds-list no-undo like ub.goods
    field nn as integer
    index by-nn       nn
    index by_gds-code gds-code
    .
define temp-table tt-gds-sea no-undo
    field artic       like ub.goods.artic
    field gds-name    like ub.goods.gds-name
    field unit-base   like ub.goods.unit-base
    field min-stock   like ub.gds-season.min-stock
    field season-coef as decimal label "Коэф. спр."
    field gds-code    like ub.goods.gds-code
    field is-inter    as logical
    index pi gds-code
    .
define variable varschartic like ub.price-list.artic initial " " no-undo.
define variable ref-list    as character no-undo.
define variable sch-field   as character no-undo.
define buffer buf_gds-season      for ub.gds-season.
define buffer buf_goods           for ub.goods.
define buffer buf_gds-season-attr for ub.gds-season-attr.
define variable sort-column-name as character no-undo .
define variable list-option      as character no-undo.
define stream sout.
DEFINE MENU POPUP-MENU-b-list
    MENU-ITEM m_item1        LABEL "Сохранить"
    MENU-ITEM m_item2        LABEL "Загрузить"     .
DEFINE BUTTON b-add
    LABEL "&Добавить":L
    SIZE 10 BY 1.
DEFINE BUTTON b-del
    LABEL "&Удалить":L
    SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход ":L
    SIZE 10 BY 1.
DEFINE BUTTON b-help
    LABEL "Помо&щь":L
    SIZE 10 BY 1.
DEFINE BUTTON b-list
    LABEL "Список":L
    SIZE 10 BY 1.
DEFINE BUTTON B-mark
    LABEL "&*"
    SIZE 3 BY 1.
DEFINE BUTTON b-print
    LABEL "Пе&чать":L
    SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
    LABEL "Вы&бор ":L
    SIZE 10 BY 1.
DEFINE BUTTON b-upd
    LABEL "&Изменить":L
    SIZE 10 BY 1.
DEFINE VARIABLE FILL-IN-2  AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по"
    VIEW-AS TEXT
    SIZE 8.88 BY .67
    FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE mark-num   AS CHARACTER FORMAT "X(256)":U
    VIEW-AS TEXT
    SIZE 9 BY .67
    FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE s-artic    AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 30 BY 1
    FGCOLOR 1 NO-UNDO.
DEFINE VARIABLE s-name     AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 30 BY 1
    FGCOLOR 1 NO-UNDO.
DEFINE VARIABLE s-name-cnt AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 30 BY 1
    FGCOLOR 1 NO-UNDO.
DEFINE VARIABLE R-sort     AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "Артик", 1,
    "Нач.назв", 2,
    "Нач.слова", 3
    SIZE 34.63 BY .96 TOOLTIP "Поиск по" NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
    tt-gds-sea SCROLLING.
DEFINE BROWSE BROWSE-2
    QUERY BROWSE-2 NO-LOCK DISPLAY
    tt-gds-sea.artic FORMAT "X(16)":U
    tt-gds-sea.gds-name FORMAT "X(48)":U
    tt-gds-sea.unit-base FORMAT "X(3)":U
    tt-gds-sea.min-stock FORMAT ">>,>>9.999":U LABEL-FGCOLOR 1
    tt-gds-sea.season-coef FORMAT ">>,>>9.999":U LABEL-FGCOLOR 1
    tt-gds-sea.gds-code FORMAT "999999999":U
  ENABLE
      tt-gds-sea.min-stock
      tt-gds-sea.season-coef
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18.33
         BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
    b-exit AT ROW 1 COL 1
    b-sel AT ROW 1 COL 11
    B-mark AT ROW 1 COL 21
    b-add AT ROW 1 COL 24
    b-upd AT ROW 1 COL 34
    b-del AT ROW 1 COL 44
    b-print AT ROW 1 COL 54
    b-list AT ROW 1 COL 64.13
    b-help AT ROW 1 COL 78
    R-sort AT ROW 2.04 COL 10.75 NO-LABEL
    s-name AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
    s-name-cnt AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
    s-artic AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
    BROWSE-2 AT ROW 3.71 COL 1
    FILL-IN-2 AT ROW 2.21 COL 1 NO-LABEL
    mark-num AT ROW 2.96 COL 1 NO-LABEL
    SPACE(85.00) SKIP(18.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Товары по сезону".
ASSIGN
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
    b-list:POPUP-MENU IN FRAME Dialog-Frame = MENU POPUP-MENU-b-list:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
    DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_collection_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
        if not v-log then return no-apply .
        assign
            line-mode = 'ДОБАВЛЕНИЕ':U
            .
        run str/chsgdsls.w
            (   input parParentProc ,
            input "season" ,
            input "Сезон " + p-name  ,
            input ? ,
            input ? ,
            input v-cntxt-host-code-obj,
            input-output varschartic,
            output ref-list,
            output table tt-gds-list,
            false )
            .
        if ref-list <> "" then
        do:
            run cycle-add in this-procedure no-error.
            if error-status:error then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процедуры создания товара" skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                return no-apply.
            end.
            OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .
        end.
        for each tt-gds-sea no-lock:
            find first buf_gds-season exclusive-lock where buf_gds-season.sea-code = p-sea-code
                and buf_gds-season.db-num = p-db-num
                and buf_gds-season.gds-code = tt-gds-sea.gds-code no-error.
            find first buf_gds-season-attr exclusive-lock where buf_gds-season-attr.sea-code = p-sea-code
                and buf_gds-season-attr.db-num = p-db-num
                and buf_gds-season-attr.gds-code = tt-gds-sea.gds-code
                and buf_gds-season-attr.attr-code = 'gdssea-season-coef':U no-error.
            if not available buf_gds-season then
            do:
                create buf_gds-season.
                assign
                    buf_gds-season.sea-code = p-sea-code
                    buf_gds-season.db-num   = p-db-num
                    buf_gds-season.gds-code = tt-gds-sea.gds-code
                    .
            end.
            assign
                buf_gds-season.min-stock = tt-gds-sea.min-stock
                .
            if tt-gds-sea.season-coef <> 0 and tt-gds-sea.season-coef <> ? and tt-gds-sea.season-coef <> 1 then
            do:
                if not available buf_gds-season-attr then
                    create buf_gds-season-attr.
                assign
                    buf_gds-season-attr.sea-code   = p-sea-code
                    buf_gds-season-attr.db-num     = p-db-num
                    buf_gds-season-attr.gds-code   = tt-gds-sea.gds-code
                    buf_gds-season-attr.attr-code  = 'gdssea-season-coef':U
                    buf_gds-season-attr.attr-value = string (tt-gds-sea.season-coef)
                    .
            end.
            else
            do:
                if available buf_gds-season-attr then delete buf_gds-season-attr.
            end.
        end.
    END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
    DO:
        for each tt-gds-sea no-lock:
            find first buf_gds-season exclusive-lock where buf_gds-season.sea-code = p-sea-code
                and buf_gds-season.db-num = p-db-num
                and buf_gds-season.gds-code = tt-gds-sea.gds-code no-error.
            find first buf_gds-season-attr exclusive-lock where buf_gds-season-attr.sea-code = p-sea-code
                and buf_gds-season-attr.db-num = p-db-num
                and buf_gds-season-attr.gds-code = tt-gds-sea.gds-code
                and buf_gds-season-attr.attr-code = 'gdssea-season-coef':U no-error.
            if not available buf_gds-season then
            do:
                create buf_gds-season.
                assign
                    buf_gds-season.sea-code = p-sea-code
                    buf_gds-season.db-num   = p-db-num
                    buf_gds-season.gds-code = tt-gds-sea.gds-code
                    .
            end.
            assign
                buf_gds-season.min-stock = tt-gds-sea.min-stock
                .
            if tt-gds-sea.season-coef <> 0 and tt-gds-sea.season-coef <> ? and tt-gds-sea.season-coef <> 1 then
            do:
                if not available buf_gds-season-attr then
                    create buf_gds-season-attr.
                assign
                    buf_gds-season-attr.sea-code   = p-sea-code
                    buf_gds-season-attr.db-num     = p-db-num
                    buf_gds-season-attr.gds-code   = tt-gds-sea.gds-code
                    buf_gds-season-attr.attr-code  = 'gdssea-season-coef':U
                    buf_gds-season-attr.attr-value = string (tt-gds-sea.season-coef)
                    .
            end.
            else
            do:
                if available buf_gds-season-attr then delete buf_gds-season-attr.
            end.
        end.
    END.
    .
ON CHOOSE OF b-del IN FRAME Dialog-Frame
    DO:
        define variable g-log as logical no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_collection_deletion':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
        if not v-log then return no-apply .
        if not available tt-gds-sea then  return no-apply.
        message "Удалить запись ? "
            view-as alert-box question
            buttons yes-no
            update g-log.
        if g-log = false then return no-apply.
        define variable v-recid as integer no-undo .
        define variable ii      as integer no-undo .
        find first buf_gds-season exclusive-lock where buf_gds-season.sea-code = p-sea-code
            and buf_gds-season.db-num = p-db-num
            and buf_gds-season.gds-code = tt-gds-sea.gds-code no-error .
        if available buf_gds-season then delete buf_gds-season.
        find current tt-gds-sea.
        delete tt-gds-sea.
        BROWSE-2:delete-current-row().
    END.
ON CHOOSE OF b-list IN FRAME Dialog-Frame
    DO:
        if list-option = "" then
        do:
            run gbl/pop-up.p (self:handle, no) no-error.
            if error-status:error then return no-apply.
        end.
    END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
    DO:
        v-cur-time = "Проба".
        define variable v-file-name as character no-undo.
        run create-rep(output v-file-name).
        if v-file-name = ? then
            MESSAGE "Не удалось создать html-файл"
                VIEW-AS ALERT-BOX.
        else
            run open-ie(v-file-name).
    END.
ON LEAVE OF tt-gds-sea.season-coef IN BROWSE BROWSE-2
    DO:
        define variable v-rowid as rowid no-undo.
        if tt-gds-sea.season-coef:input-value in browse browse-2 = 0 or tt-gds-sea.season-coef = ? then
        do:
            assign
                tt-gds-sea.season-coef = 1.
            message "Коэффициент увеличения спроса не может равняться нулю" view-as alert-box.
            v-rowid = rowid (tt-gds-sea).
            OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .
    reposition BROWSE-2 to rowid v-rowid.
        end.
    END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
    DO:
        if ( available season ) AND ( rid-list = "" ) then
            rid-list = string( recid( season ) ) .
    END.
ON CHOOSE OF b-upd IN FRAME Dialog-Frame
    DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_collection_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
        if not v-log then return no-apply .
        if not available season THEN return no-apply.
    END.
ON CHOOSE OF MENU-ITEM m_item1
    DO:
        list-option = "save":U.
        run proc-b-list in this-procedure (input list-option) no-error.
        if error-status:error then return no-apply.
    END.
ON CHOOSE OF MENU-ITEM m_item2
    DO:
        list-option = "load":U.
        run proc-b-list in this-procedure (input list-option) no-error.
        if error-status:error then return no-apply.
    END.
ON VALUE-CHANGED OF R-sort IN FRAME Dialog-Frame
    DO:
        Assign frame Dialog-Frame r-sort.
        case r-sort :
            when 1 then
                do:
                    if sch-field = "s-name-cnt" then
                    do:
                        assign
                            frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.
                        OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .
                    end.
                    enable s-artic with frame Dialog-Frame.
                    Hide s-name  s-name-cnt in frame Dialog-Frame.
                    display s-artic with frame Dialog-Frame.
                end.
            when 2 then
                do:
                    if sch-field = "s-name-cnt" then
                    do:
                        assign
                            frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.
                        OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .
                    end.
                    enable s-name with frame Dialog-Frame.
                    hide s-artic  s-name-cnt in frame Dialog-Frame.
                    display s-name with frame Dialog-Frame.
                end.
            when 3 then
                do:
                    enable s-name-cnt with frame Dialog-Frame.
                    hide s-artic  s-name in frame Dialog-Frame.
                    display s-name-cnt with frame Dialog-Frame.
                end.
        end case.
    END.
ON MOUSE-SELECT-DBLCLICK OF s-artic IN FRAME Dialog-Frame
    OR  RETURN OF s-artic IN FRAME Dialog-Frame
    DO:
        if s-artic <> input frame Dialog-Frame s-artic or sch-field <> "s-artic" then
        do:
            sch-field = "s-artic".
            assign
                s-artic = input frame Dialog-Frame s-artic.
            doc-rec = ?.
            for each tt-gds-sea no-lock,
                first buf_goods no-lock where
                buf_goods.gds-code = tt-gds-sea.gds-code and
                buf_goods.artic begins s-artic :
                doc-rec = recid ( tt-gds-sea ) .
                leave.
            end.
            if doc-rec = ? then message "Товар не найден !"  .
            else
                reposition BROWSE-2 to recid doc-rec no-error.
            return no-apply.
        end.
    END.
ON MOUSE-SELECT-DBLCLICK OF s-name IN FRAME Dialog-Frame
    OR  RETURN OF s-name IN FRAME Dialog-Frame
    DO:
        if s-name <> input frame Dialog-Frame s-name or sch-field <> "s-name" then
        do:
            sch-field = "s-name".
            assign
                s-name = input frame Dialog-Frame s-name.
            doc-rec = ?.
            for each tt-gds-sea no-lock,
                first buf_goods no-lock where
                buf_goods.gds-code = tt-gds-sea.gds-code and
                buf_goods.gds-name begins s-name
                :
                doc-rec = recid(tt-gds-sea) .
                leave.
            end.
            if doc-rec = ? then message "Товар не найден !"  .
            else
                reposition BROWSE-2 to recid doc-rec no-error.
            return no-apply.
        end.
    END.
ON MOUSE-SELECT-DBLCLICK OF s-name-cnt IN FRAME Dialog-Frame
    OR  RETURN OF s-name-cnt IN FRAME Dialog-Frame
    DO:
        if s-name-cnt <> input frame Dialog-Frame s-name-cnt or sch-field <> "s-name-cnt" then
        do:
            sch-field = "s-name-cnt".
            assign
                s-name-cnt = input frame Dialog-Frame s-name-cnt.
            doc-rec = ?.
            for each tt-gds-sea no-lock,
                first buf_goods no-lock where
                buf_goods.gds-code = tt-gds-sea.gds-code  and
            INDEX (buf_goods.gds-name,s-name-cnt) > 0
                :
                doc-rec = recid(tt-gds-sea) .
                leave.
            end.
            if doc-rec = ? then message "Товар не найден !"  .
            else
            do:
                assign
                    frame Dialog-Frame:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .
                OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0       NO-LOCK .
            end.
            return no-apply.
        end.
    END.
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
    DO:
        if available tt-gds-sea then
        do:
            if tt-gds-sea.is-inter
                then tt-gds-sea.artic:bgcolor in browse BROWSE-2  = 12.
            else tt-gds-sea.artic:bgcolor in browse BROWSE-2  = ?.
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
        v-diasize-browse-handle     = browse BROWSE-2 :handle
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
assign
    frame Dialog-Frame:title = "Товары >>-  " + p-name.
def var sort-labelBROWSE-2   as character no-undo .
def var sort-clmnBROWSE-2    as handle    no-undo .
def var cur-clmnBROWSE-2     as handle    no-undo .
def var cur-clmn-locBROWSE-2 as integer   no-undo .
def var re-queryBROWSE-2     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-2 in frame Dialog-Frame do:
   run sort-brBROWSE-2
     (input (if available tt-gds-sea
             then recid(tt-gds-sea)
             else ?
            )
     ).
end.
PROCEDURE sort-brBROWSE-2 :
  define input parameter p-recid as recid no-undo .
  if re-queryBROWSE-2 = no then do:
    assign
       cur-clmnBROWSE-2 = BROWSE-2:current-column in frame Dialog-Frame
    .
    if sort-clmnBROWSE-2 <> ? then sort-clmnBROWSE-2:column-fgcolor = 0.
    if cur-clmnBROWSE-2 = sort-clmnBROWSE-2 then do:
      assign
         sort-labelBROWSE-2 = ""
         sort-clmnBROWSE-2 = ?
      .
     end.
     else do:
       assign
         sort-labelBROWSE-2 = cur-clmnBROWSE-2:label
         sort-clmnBROWSE-2  = cur-clmnBROWSE-2
         sort-clmnBROWSE-2:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBROWSE-2 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BROWSE-2:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBROWSE-2 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBROWSE-2 = cur-clmn-locBROWSE-2 + 1
    .
  end.
  case sort-labelBROWSE-2:
        when tt-gds-sea.artic:label in browse BROWSE-2 then DO:   assign     sort-column-name = "tt-gds-sea.artic"   .   run OpenBr.   . END.
        when tt-gds-sea.gds-name:label in browse BROWSE-2 then DO:   assign     sort-column-name = "tt-gds-sea.gds-name"   .   run OpenBr.   . END.
        when tt-gds-sea.unit-base:label in browse BROWSE-2 then DO:   assign     sort-column-name = "tt-gds-sea.unit-base"   .   run OpenBr.   . END.
        when tt-gds-sea.min-stock:label in browse BROWSE-2 then DO:   assign     sort-column-name = "tt-gds-sea.min-stock"   .   run OpenBr.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr.
      if sort-labelBROWSE-2 <> "" then do:
        assign
          cur-clmnBROWSE-2:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBROWSE-2 = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition BROWSE-2 to recid p-recid no-error.
    apply "value-changed" to BROWSE-2 in frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-2 in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBROWSE-2:
if cur-clmnBROWSE-2 = ? then do:
   run OpenBr.
end.
else do:
   assign re-queryBROWSE-2 = yes.
   run sort-brBROWSE-2
     (input (if available tt-gds-sea
             then recid(tt-gds-sea)
             else ?
            )
     ).
   assign re-queryBROWSE-2 = no.
end.
end.
ASSIGN
    b-list:POPUP-MENU IN FRAME Dialog-Frame = MENU POPUP-MENU-b-list:HANDLE.
ASSIGN
    b-list:MENU-MOUSE = 1.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to BROWSE-2 in frame Dialog-Frame.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    define variable v-seaobj   as character no-undo.
    define variable v-sea-code as integer   no-undo.
    define variable v-db-num   as integer   no-undo.
    define variable v-longchar as longchar  no-undo .
    define variable v-ok       as logical   no-undo init yes.
    define buffer buf1_season for ub.season.
    find first  buf_season no-lock where
        buf_season.sea-code = p-sea-code and
        buf_season.db-num   = p-db-num
        no-error .
    if not available buf_season  then return error .
    find first buf_season-attr no-lock where buf_season-attr.sea-code = p-sea-code
        and buf_season-attr.db-num = p-db-num
        and buf_season-attr.attr-code = 'sea-obj':U
        no-error.
    if available buf_season-attr then
        assign
            v-seaobj = buf_season-attr.attr-value
            .
    for each buf_gds-season no-lock where buf_gds-season.sea-code = p-sea-code and buf_gds-season.db-num = p-db-num,
        each buf_goods where buf_goods.gds-code = buf_gds-season.gds-code:
        find first buf_gds-season-attr no-lock where buf_gds-season-attr.db-num = buf_gds-season.db-num
            and buf_gds-season-attr.sea-code = buf_gds-season.sea-code
            and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
            and buf_gds-season-attr.attr-code = 'gdssea-season-coef':U no-error.
        create tt-gds-sea.
        assign
            tt-gds-sea.artic       = buf_goods.artic
            tt-gds-sea.gds-code    = buf_goods.gds-code
            tt-gds-sea.gds-name    = buf_goods.gds-name
            tt-gds-sea.season-coef = if available buf_gds-season-attr then decimal (buf_gds-season-attr.attr-value) else 1
            tt-gds-sea.min-stock   = buf_gds-season.min-stock
            tt-gds-sea.unit-base   = buf_goods.unit-base
            .
        run chk-gdssea in this-procedure
            ( input tt-gds-sea.gds-code,
            input v-seaobj,
            input buf_season.sea-month-1,
            input buf_season.sea-month-2,
            input rowid (buf_season),
            output v-sea-code,
            output v-db-num,
            output v-ok) no-error.
        if not v-ok then
        do:
            find first buf1_season no-lock where buf1_season.sea-code = v-sea-code
                and buf1_season.db-num = v-db-num
                no-error.
            assign
                v-longchar          = v-longchar +
          substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf1_season.sea-name, chr(10))
                v-ok                = true
                tt-gds-sea.is-inter = true
                .
        end.
    end.
    if v-longchar <> "" then
    do:
        run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
            + 'title=Проверка товарного наполнения сезона: есть пересечения\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
            ,input-output v-longchar
            ,output v-ok ) no-error .
        if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "4"
                view-as alert-box error
                .
        assign
            v-longchar = "".
    end.
    run enable_UI in this-procedure .
    if can-find (first tt-gds-sea) then BROWSE-2:refresh().
    IF BUF_SEASON.SEA-MONTH-1 = 0 THEN hide tt-gds-sea.min-stock tt-gds-sea.season-coef in browse  BROWSE-2  .
    enable  s-artic with frame Dialog-Frame.
    Hide      s-name  s-name-cnt in frame Dialog-Frame.
    display s-artic with frame Dialog-Frame.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
PROCEDURE cycle-add :
    define variable dct-type as character no-undo .
    define variable stp-cycl as logical   no-undo .
    define variable v-num    as integer   no-undo .
    define variable v-flag   as logical   no-undo init false .
    define buffer bb_gds-season for gds-season.
    define buffer old_season    for season.
    stp-cycl = false .
    if buf_season.sea-month-1 = 0 then dct-type = "coll".
    else dct-type = "season" .
    if dct-type = "coll" then
    do:
        run gbl/d-askw.w
            (input "Вопрос"
            ,input "Если товар уже прикреплен к коллекции, пропускаем его?"
            ,input "|^"
            ,input "Не добавлять|Добавлять|Остановка"
            ,input "Не добавляем товар в новую коллекцию, товар остается в старой коллекции|"
            + "Добавляем товар в новую коллекцию и удаляем в старой коллекции|"
            + "Остановить добавление товаров, если встречаются товары прикрепленные к другим коллекциям."
            ,input 1
            ,input 2
            ,output v-num
            ).
        case v-num :
            when 1 then
                do:
                    for each tt-gds-list no-lock  by tt-gds-list.nn :
                        lns-cnt  =  lns-cnt + 1 .
                        if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
                        v-flag = false .
                        for each   bb_gds-season no-lock where
                            bb_gds-season.gds-code = tt-gds-list.gds-code  ,
                            each old_season no-lock where
                            old_season.sea-code = bb_gds-season.sea-code and
                            old_season.db-num   = bb_gds-season.db-num   and
                            old_season.sea-month-1 = 0
                            :
                            v-flag = true .
                            leave.
                        end.
                        if  v-flag = false then
                        do :
                            find first tt-gds-sea no-lock
                                where tt-gds-sea.gds-code = tt-gds-list.gds-code
                                and tt-gds-sea.min-stock = 0 no-error.
                            if not available tt-gds-sea then
                            do :
                                create tt-gds-sea.
                                assign
                                    tt-gds-sea.gds-code  = tt-gds-list.gds-code
                                    tt-gds-sea.artic     = tt-gds-list.artic
                                    tt-gds-sea.gds-name  = tt-gds-list.gds-name
                                    tt-gds-sea.unit-base = tt-gds-list.unit-base
                                    tt-gds-sea.min-stock = 0
                                    .
                            end.
                        end.
                        if  stp-cycl = true then leave.
                    end.
                end.
            when 2 then
                do:
                    for each tt-gds-list no-lock  by tt-gds-list.nn :
                        lns-cnt  =  lns-cnt + 1 .
                        if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
                        v-flag = false .
                        for each  bb_gds-season exclusive-lock  where
                            bb_gds-season.gds-code = tt-gds-list.gds-code ,
                            each old_season no-lock where
                            old_season.sea-code = bb_gds-season.sea-code and
                            old_season.db-num   = bb_gds-season.db-num   and
                            old_season.sea-month-1 = 0
                            :
                            delete bb_gds-season .
                        end.
                        find first tt-gds-sea no-lock
                            where tt-gds-sea.gds-code = tt-gds-list.gds-code
                            and tt-gds-sea.min-stock = 0 no-error.
                        if not available tt-gds-sea then
                        do :
                            create tt-gds-sea.
                            assign
                                tt-gds-sea.gds-code  = tt-gds-list.gds-code
                                tt-gds-sea.artic     = tt-gds-list.artic
                                tt-gds-sea.gds-name  = tt-gds-list.gds-name
                                tt-gds-sea.unit-base = tt-gds-list.unit-base
                                tt-gds-sea.min-stock = 0
                                .
                        end.
                        if  stp-cycl = true then leave.
                    end.
                end.
            when 3 then
                do:
                    for each tt-gds-list no-lock  by tt-gds-list.nn :
                        lns-cnt  =  lns-cnt + 1 .
                        if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
                        v-flag = false .
                        for each   bb_gds-season no-lock where
                            bb_gds-season.gds-code = tt-gds-list.gds-code  ,
                            each old_season no-lock where
                            old_season.sea-code = bb_gds-season.sea-code and
                            old_season.db-num   = bb_gds-season.db-num   and
                            old_season.sea-month-1 = 0 :
                            v-flag = true .
                            leave.
                        end.
                        if  v-flag = true  then
                        do:
                            leave .
                        end.
                        if  stp-cycl = true then leave.
                    end.
                    if v-flag <> true then
                    do :
                        for each tt-gds-list no-lock  by tt-gds-list.nn :
                            find first tt-gds-sea no-lock
                                where tt-gds-sea.gds-code = tt-gds-list.gds-code
                                and tt-gds-sea.min-stock = 0 no-error.
                            if not available tt-gds-sea then
                            do :
                                create tt-gds-sea.
                                assign
                                    tt-gds-sea.gds-code  = tt-gds-list.gds-code
                                    tt-gds-sea.artic     = tt-gds-list.artic
                                    tt-gds-sea.gds-name  = tt-gds-list.gds-name
                                    tt-gds-sea.unit-base = tt-gds-list.unit-base
                                    tt-gds-sea.min-stock = 0
                                    .
                            end.
                        end.
                    end.
                end.
        end case.
    end.
    else
    do:
        define variable v-ok       as logical   no-undo.
        define variable v-seaobj   as character no-undo.
        define variable v-sea-code as integer   no-undo.
        define variable v-db-num   as integer   no-undo.
        define variable v-longchar as longchar  no-undo .
        define buffer buf1_season for ub.season.
        if not available buf_season then
            return no-apply.
        find first buf_season-attr no-lock where buf_season-attr.sea-code = p-sea-code
            and buf_season-attr.db-num = p-db-num
            and buf_season-attr.attr-code = 'sea-obj':U
            no-error.
        if available buf_season-attr then
            assign
                v-seaobj = buf_season-attr.attr-value
                .
        for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
            if not can-find (first tt-gds-sea where
                tt-gds-sea.gds-code = tt-gds-list.gds-code no-lock
                ) then
            do:
                run chk-gdssea in this-procedure
                    ( input tt-gds-list.gds-code,
                    input v-seaobj,
                    input buf_season.sea-month-1,
                    input buf_season.sea-month-2,
                    input rowid(buf_season),
                    output v-sea-code,
                    output v-db-num,
                    output v-ok) no-error.
                if not v-ok then
                do:
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-list.gds-code no-error.
                    find first buf1_season no-lock where buf1_season.sea-code = v-sea-code
                        and buf1_season.db-num = v-db-num
                        no-error.
                    assign
                        v-longchar = v-longchar +
            substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf1_season.sea-name, chr(10))
                        v-ok       = true
                        .
                    next.
                end.
                create tt-gds-sea.
                assign
                    tt-gds-sea.gds-code    = tt-gds-list.gds-code
                    tt-gds-sea.artic       = tt-gds-list.artic
                    tt-gds-sea.gds-name    = tt-gds-list.gds-name
                    tt-gds-sea.unit-base   = tt-gds-list.unit-base
                    tt-gds-sea.min-stock   = 0
                    tt-gds-sea.season-coef = 1
                    .
            end.
            if  stp-cycl = true then leave.
        end.
        if v-longchar <> "" then
        do:
            run gbl/d-longchar.w (
                ?,
                'Editor_row=2\':u
                + 'title=Проверка товарного наполнения сезона: невозможно добавить товары\':u
                + 'Editor_col=1\':u
                + 'Editor_width=96\':u
                + 'Editor_height=21\':u
                + 'readonly=yes\':u
                ,input-output v-longchar
                ,output v-ok ) no-error .
            if error-status :error then message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    return-value skip
                    "4"
                    view-as alert-box error
                    .
            assign
                v-longchar = "".
        end.
    end.
    ASSIGN
        lns-cnt = lns-cnt + 1 .
end procedure.
PROCEDURE disable_UI :
    HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY R-sort s-name s-name-cnt s-artic FILL-IN-2 mark-num
        WITH FRAME Dialog-Frame.
    ENABLE b-exit b-add b-del b-list b-help R-sort s-artic BROWSE-2 FILL-IN-2
        mark-num b-print
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .
END PROCEDURE.
PROCEDURE OpenBr :
    define variable t-ret as logical no-undo .
    t-ret =  session:SET-WAIT-STATE("GENERAL") .
    case sort-column-name :
        when "" then
            do:
                    if r-sort = 3 and sch-field = "s-name-cnt" then do:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0       NO-LOCK .     end.    else DO:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .    end.
            end.
        when "tt-gds-sea.artic" then
            do:
                    if r-sort = 3 and sch-field = "s-name-cnt" then do:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0       NO-LOCK by tt-gds-sea.artic.     end.    else DO:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     by tt-gds-sea.artic.    end.
            end.
        when "tt-gds-sea.gds-name" then
            do:
                    if r-sort = 3 and sch-field = "s-name-cnt" then do:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0       NO-LOCK by tt-gds-sea.gds-name.     end.    else DO:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     by tt-gds-sea.gds-name.    end.
            end.
        when "tt-gds-sea.unit-base" then
            do:
                    if r-sort = 3 and sch-field = "s-name-cnt" then do:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0       NO-LOCK by tt-gds-sea.unit-base.     end.    else DO:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     by tt-gds-sea.unit-base.    end.
            end.
        when "tt-gds-sea.min-stock" then
            do:
                    if r-sort = 3 and sch-field = "s-name-cnt" then do:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0       NO-LOCK by tt-gds-sea.min-stock.     end.    else DO:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     by tt-gds-sea.min-stock.    end.
            end.
        otherwise
        do:
                if r-sort = 3 and sch-field = "s-name-cnt" then do:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0       NO-LOCK .     end.    else DO:     assign frame Dialog-Frame:title = "Товары >> Сезон - " + p-name.    OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .    end.
        end.
    end case.
    t-ret =  session:SET-WAIT-STATE("") .
    apply "HOME" to BROWSE-2 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-list :
    define input parameter loc-list-option as character no-undo.
    define buffer loc-gds-season for ub.gds-season.
    define variable v-sea-code        like ub.gds-season.sea-code no-undo.
    define variable jj                as integer   no-undo.
    define variable varrid-gds-season as recid     no-undo.
    define variable f-name            as character init "default.cli" no-undo.
    define variable imp-type          like ub.goods.prod-type no-undo.
    define variable imp-code          like ub.goods.prod-code no-undo.
    define variable loc-gds-code      like ub.gds-season.gds-code no-undo.
    define variable loc-min-stock     like ub.gds-season.min-stock no-undo.
    define variable loc-sea-code      like ub.gds-season.sea-code no-undo.
    define variable loc-db-num        like ub.gds-season.db-num no-undo.
    v-sea-code =  p-sea-code .
    case loc-list-option:
        when "save":U then
            do:
                g#log = yes.
                message "Сохранить все товары в файле списка"
                    view-as alert-box question buttons OK-Cancel update g#log.
                if not g#log then
                do:
                    list-option = "":U.
                    return.
                end.
                assign
                    f-name = "default.sea"
                    g#log  = yes
                    .
                system-dialog get-file f-name
                    filters "Списки товаров  *.sea" "*.sea"
                    ask-overwrite
                    save-as
                    use-filename
                    update g#log
                    default-extension "sea".
                if not g#log then
                do:
                    list-option = "":U.
                    return.
                end.
                g#log =  session:SET-WAIT-STATE("GENERAL") .
                output stream sout to value (f-name).
                for each loc-gds-season No-LOCK WHERE
                    loc-gds-season.sea-code = v-sea-code and
                    loc-gds-season.db-num   = p-db-num
                    :
                    export stream sout
                        loc-gds-season.gds-code
                        loc-gds-season.min-stock
                        loc-gds-season.sea-code
                        loc-gds-season.db-num
                        .
                END.
                output stream sout close.
                g#log =  session:SET-WAIT-STATE("") .
            end.
        when "load":U then
            do:
                system-dialog get-file f-name
                    filters "Списки клиентов *.sea" "*.sea"
                    title "Выберите файл списка"
                    INITIAL-DIR "."
                    return-to-start-dir
                    must-exist
                    update g#log
                    default-extension "sea".
                if not g#log then
                do:
                    list-option = "":U.
                    return.
                end.
                g#log =  session:SET-WAIT-STATE("GENERAL") .
                input stream sout from value (f-name).
                _repeat:
                repeat:
                    import stream sout
                        loc-gds-code
                        loc-min-stock
                        loc-sea-code
                        loc-db-num
                        no-error.
                    find first loc-gds-season exclusive-LOCK WHERE
                        loc-gds-season.gds-code = loc-gds-code  and
                        loc-gds-season.sea-code = v-sea-code and
                        loc-gds-season.db-num   = p-db-num
                        no-error.
                    if not available loc-gds-season then create loc-gds-season.
                    assign
                        loc-gds-season.gds-code  = loc-gds-code
                        loc-gds-season.min-stock = loc-min-stock
                        loc-gds-season.sea-code  = v-sea-code
                        loc-gds-season.db-num    = p-db-num
                        .
                end.
                run loadbrowse (input loc-gds-season.sea-code, input loc-gds-season.db-num, input '').
                input stream sout close.
                g#log =  session:SET-WAIT-STATE("") .
                OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea       NO-LOCK     .
            end.
    END CASE.
    loc-list-option = "":U.
END PROCEDURE.
procedure create-rep:
    define output parameter p-filename as character no-undo.
    define variable v-rls-file  as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file  as character no-undo.
    define variable v-tmp-file  as character no-undo.
    define variable hw          as handle    no-undo.
    define variable rep-out     as class     Rep-Out no-undo.
    assign
        v-xsl-file  = search("exe/goods-seas.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file  = session:temp-directory + string(time) + ".html"
        .
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    run write-data(hw) .
    rep-out = new rep-out().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).
    os-delete value(v-rls-file).
    delete object rep-out.
    p-filename = v-tmp-file.
end.
procedure write-data:
    define input parameter hw as handle no-undo.
    hw:start-document ().
    hw:start-element ("rep").
    hw:start-element ("card").
    hw:insert-attribute ("sea-code", if p-sea-code = ? then "" else  string(p-sea-code) ).
    hw:insert-attribute ("db-num", if p-db-num = ? then "" else  string(p-db-num) ).
    hw:insert-attribute ("name", if p-name = ? then "" else  string(p-name) ).
    for each tt-gds-sea no-lock:
        hw:start-element ("line").
        hw:insert-attribute ("gds-artic",if tt-gds-sea.artic = ? then "" else string(tt-gds-sea.artic)).
        hw:insert-attribute ("gds-name",if tt-gds-sea.gds-name = ? then "" else  string(tt-gds-sea.gds-name) ).
        hw:insert-attribute ("unit-base",if tt-gds-sea.unit-base = ? then "" else string(tt-gds-sea.unit-base)).
        hw:insert-attribute ("min-stock",if tt-gds-sea.min-stock = ? then "" else string(tt-gds-sea.min-stock,"->>>,>>9.999")).
        hw:insert-attribute ("season-coef",if tt-gds-sea.season-coef = ? then "" else string(tt-gds-sea.season-coef,"->>>,>>9.999")).
        hw:insert-attribute ("gds-code",if tt-gds-sea.gds-code = ? then "" else string(tt-gds-sea.gds-code)).
        hw:end-element ("line").
    end.
    hw:end-element ("card").
    hw:end-element ("rep").
    hw:end-document ().
end.
procedure loadbrowse :
    define input parameter p2-sea-code   like ub.season.sea-code no-undo.
    define input parameter p2-db-num like ub.season.db-num no-undo.
    define input parameter p2-name   like ub.season.sea-name no-undo.
    define buffer tt-gds-sea2 for tt-gds-sea.
    define variable v2-sea-code as integer.
    define variable v2-db-num   as integer.
    define variable v2-ok       as logical.
    define variable v2-longchar as char.
    define buffer buf2_season for season.
   for each tt-gds-sea:
       delete tt-gds-sea.
       end.
    find first  buf2_season no-lock where
        buf2_season.sea-code = p2-sea-code and
        buf2_season.db-num   = p2-db-num
        no-error .
    if not available buf2_season  then return error .
    find first buf_season-attr no-lock where buf_season-attr.sea-code = p2-sea-code
        and buf_season-attr.db-num = p2-db-num
        and buf_season-attr.attr-code = 'sea-obj':U
        no-error.
    if available buf_season-attr then
        assign
            v-seaobj = buf_season-attr.attr-value
            .
    for each buf_gds-season no-lock where buf_gds-season.sea-code = p2-sea-code and buf_gds-season.db-num = p2-db-num,
        each buf_goods where buf_goods.gds-code = buf_gds-season.gds-code:
        find first buf_gds-season-attr no-lock where buf_gds-season-attr.db-num = buf_gds-season.db-num
            and buf_gds-season-attr.sea-code = buf_gds-season.sea-code
            and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
            and buf_gds-season-attr.attr-code = 'gdssea-season-coef':U no-error.
        if not available buf_gds-season-attr then
        do:
            create tt-gds-sea2.
            assign
                tt-gds-sea2.artic       = buf_goods.artic
                tt-gds-sea2.gds-code    = buf_goods.gds-code
                tt-gds-sea2.gds-name    = buf_goods.gds-name
                tt-gds-sea2.season-coef = if available buf_gds-season-attr then decimal (buf_gds-season-attr.attr-value) else 1
                tt-gds-sea2.min-stock   = buf_gds-season.min-stock
                tt-gds-sea2.unit-base   = buf_goods.unit-base
                .
        end.
        run chk-gdssea in this-procedure
            ( input tt-gds-sea2.gds-code,
            input v-seaobj,
            input buf2_season.sea-month-1,
            input buf2_season.sea-month-2,
            input rowid (buf2_season),
            output v2-sea-code,
            output v2-db-num,
            output v2-ok) no-error.
        if not v2-ok then
        do:
            find first buf2_season no-lock where buf2_season.sea-code = v2-sea-code
                and buf2_season.db-num = v2-db-num
                no-error.
            assign
                v2-longchar         = v2-longchar +
          substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v2-sea-code, buf2_season.sea-name, chr(10))
                v2-ok               = true
                tt-gds-sea2.is-inter = true
                .
        end.
    end.
end procedure.
procedure open-ie:
    define input parameter p-filename as character no-undo.
    define variable o-IE as com-handle no-undo.
    create "InternetExplorer.Application" o-IE.
    o-IE:addressbar = false.
    o-IE:Navigate(p-filename).
    o-IE:visible = true.
    release object o-IE.
end.
