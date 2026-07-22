DEFINE BUFFER locked_group-period-validity FOR ub.group-period-validity.
DEFINE BUFFER locked_var-deliv-gr-per-val FOR ub.var-deliv-gr-per-val.
DEFINE BUFFER locked_variant-delivery FOR ub.variant-delivery.
DEFINE TEMP-TABLE tt-group-period-validity NO-UNDO LIKE ub.group-period-validity.
DEFINE TEMP-TABLE tt-var-deliv-gr-per-val NO-UNDO LIKE ub.var-deliv-gr-per-val.
DEFINE TEMP-TABLE tt-variant-delivery NO-UNDO LIKE ub.variant-delivery.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_delivery-subject FOR ub.delivery-subject.
DEFINE BUFFER X_delivery-type FOR ub.delivery-type.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
DEFINE INPUT PARAMETER p-deliv-type-code LIKE ub.var-deliv-gr-per-val.deliv-type-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-subj-code LIKE ub.var-deliv-gr-per-val.deliv-subj-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-type  LIKE ub.var-deliv-gr-per-val.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-code  LIKE ub.var-deliv-gr-per-val.obj-code NO-UNDO.
define input parameter p-gr-per-val-code  LIKE ub.var-deliv-gr-per-val.gr-per-val-code no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования ВАРИАНТА ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ".
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
define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-gr-per-val
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-variant-delivery
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE VARIABLE f-deliv-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 42.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-deliv-subj-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название субъекта доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1 NO-UNDO.
DEFINE VARIABLE F-deliv-type-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название типа доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1.
DEFINE VARIABLE f-gr-per-from AS INTEGER FORMAT ">,>>9":U INITIAL 0
     LABEL "Срок хранения(дни) от"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-gr-per-to AS INTEGER FORMAT ">,>>9":U INITIAL 0
     LABEL "до"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-gr-per-val-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Назв. группы сроков хран."
     VIEW-AS FILL-IN
     SIZE 63 BY 1 NO-UNDO.
DEFINE VARIABLE F-term-delivery AS INTEGER FORMAT ">,>>9" INITIAL 0
     LABEL "Срок доставки(дни)"
     VIEW-AS FILL-IN
     SIZE 17 BY 1.
DEFINE QUERY Dialog-Frame FOR
      tt-var-deliv-gr-per-val,
      tt-variant-delivery SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-var-deliv-gr-per-val.deliv-type-code AT ROW 3 COL 27.5 COLON-ALIGNED
          LABEL "Внутр.код типа доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-var-deliv-gr-per-val.deliv-subj-code AT ROW 3 COL 66.5 COLON-ALIGNED
          LABEL "Вн.код субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-variant-delivery AT ROW 3 COL 80
     F-deliv-type-name AT ROW 4.27 COL 27.5 COLON-ALIGNED
     F-deliv-subj-name AT ROW 5.5 COL 27.5 COLON-ALIGNED
     tt-var-deliv-gr-per-val.obj-type AT ROW 6.77 COL 27.5 COLON-ALIGNED
          LABEL "Объект доставки"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-var-deliv-gr-per-val.obj-code AT ROW 6.77 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     f-deliv-obj-name AT ROW 6.77 COL 48 COLON-ALIGNED NO-LABEL
     F-term-delivery AT ROW 8 COL 27.5 COLON-ALIGNED
     tt-var-deliv-gr-per-val.gr-per-val-code AT ROW 9.27 COL 33.5 COLON-ALIGNED
          LABEL "Внутр.код группы сроков хранения"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-gr-per-val AT ROW 9.27 COL 47.5
     F-gr-per-val-name AT ROW 10.5 COL 28 COLON-ALIGNED
     f-gr-per-from AT ROW 11.77 COL 28 COLON-ALIGNED
     f-gr-per-to AT ROW 11.77 COL 42.5 COLON-ALIGNED
     tt-var-deliv-gr-per-val.des AT ROW 14.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.77
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 13 COL 1.5
     SPACE(81.74) SKIP(4.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип доставки от субъекта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       F-deliv-subj-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       F-deliv-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-gr-per-val IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if available locked_group-period-validity then v-rid-list = string(recid(locked_group-period-validity)).
run ref/gpervals.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , 'все':U
              , input-output v-sts
              , input-output v-rid-list ) no-error .
if v-rid-list <> "":U then do:
FIND FIRST LOCKED_group-period-validity WHERE
    recid( LOCKED_group-period-validity ) = integer(entry(1, v-rid-list)) NO-LOCK .
if available LOCKED_group-period-validity then do:
    assign
    tt-var-deliv-gr-per-val.gr-per-val-code = locked_group-period-validity.gr-per-val-code
    f-gr-per-val-name = locked_group-period-validity.gr-per-val-name
    f-gr-per-from     = locked_group-period-validity.gr-per-from
    f-gr-per-to     = locked_group-period-validity.gr-per-to
    .
  end.
  else do:
  assign
  tt-var-deliv-gr-per-val.gr-per-val-code = ?
  f-gr-per-val-name = "":U
  f-gr-per-from = ?
  f-gr-per-to = ?
  .
  end.
  display
  tt-var-deliv-gr-per-val.gr-per-val-code
  f-gr-per-val-name
  f-gr-per-from
  f-gr-per-to
  with frame Dialog-Frame .
end.
END.
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
    run ref/varcdlvs.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U
                ,input "one":U
                ,input locked_var-deliv-gr-per-val.deliv-type-code
                ,input locked_var-deliv-gr-per-val.deliv-subj-code
                ,input locked_var-deliv-gr-per-val.obj-type
                ,input locked_var-deliv-gr-per-val.obj-code
                ,input-output v-rid-list
                              )
 .
END.
ON CHOOSE OF B-variant-delivery IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo . .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if available locked_variant-delivery then
assign
v-rid-list = string(recid(locked_variant-delivery))
v-sts = locked_variant-delivery.sts
.
run ref/vardelvs.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , 'все':U
              , p-deliv-type-code
              , p-deliv-subj-code
              , p-deliv-obj-type
              , p-deliv-obj-code
              , input-output v-sts
              , input-output v-rid-list ) no-error .
if v-rid-list <> "":U then do:
    FIND FIRST LOCKED_variant-delivery  WHERE
        recid( LOCKED_variant-delivery  ) = integer(entry(1, v-rid-list)) NO-LOCK .
    if available LOCKED_variant-delivery  then do:
      find first X_delivery-type no-lock where
                X_delivery-type.deliv-type-code = locked_variant-delivery .deliv-type-code no-error .
      find first X_delivery-subject no-lock where
                X_delivery-subject.deliv-subj-code = locked_variant-delivery .deliv-subj-code no-error .
      find first X_clients no-lock where
                X_clients.obj-type = locked_variant-delivery.obj-type
           AND  X_clients.obj-code = locked_variant-delivery.obj-code   no-error .
      if available X_delivery-type
      and available X_delivery-subject
      and available X_clients
      then do:
        assign
        tt-var-deliv-gr-per-val.deliv-type-code = locked_variant-delivery.deliv-type-code
        tt-var-deliv-gr-per-val.deliv-subj-code = locked_variant-delivery.deliv-subj-code
        tt-var-deliv-gr-per-val.obj-type        = locked_variant-delivery.obj-type
        tt-var-deliv-gr-per-val.obj-code        = locked_variant-delivery.obj-code
        f-deliv-type-name = X_delivery-type.deliv-type-name
        f-deliv-subj-name = X_delivery-subject.deliv-subj-name
        f-deliv-obj-name = X_clients.obj-name
        .
     end.
     else do:
      assign
      tt-var-deliv-gr-per-val.deliv-type-code = ?
      tt-var-deliv-gr-per-val.deliv-subj-code = ?
      tt-var-deliv-gr-per-val.obj-type        = "":U
      tt-var-deliv-gr-per-val.obj-code        = ?
      f-deliv-type-name = "":U
      f-deliv-subj-name = "":U
      f-deliv-obj-name = "":U
      .
     end.
   end.
   else do:
    assign
    tt-var-deliv-gr-per-val.deliv-type-code = ?
    tt-var-deliv-gr-per-val.deliv-subj-code = ?
    tt-var-deliv-gr-per-val.obj-type        = "":U
    tt-var-deliv-gr-per-val.obj-code        = ?
    f-deliv-type-name = "":U
    f-deliv-subj-name = "":U
    f-deliv-obj-name = "":U
    .
   end.
  display
  tt-var-deliv-gr-per-val.deliv-type-code
  tt-var-deliv-gr-per-val.deliv-subj-code
  tt-var-deliv-gr-per-val.obj-type
  tt-var-deliv-gr-per-val.obj-code
  f-deliv-type-name
  f-deliv-subj-name
  f-deliv-obj-name
  with frame Dialog-Frame .
end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
   find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
IF v-db-num <> 0
AND (p-mode = 'ДОБАВЛЕНИЕ':U
     OR p-mode = 'ИЗМЕНЕНИЕ':U ) THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись ВАРИАНТ ДОСТАВКИ в УБД"
    view-as alert-box ERROR.
    return error .
END.
for each tt-variant-delivery:
  delete tt-variant-delivery.
end.
for each tt-var-deliv-gr-per-val:
  delete tt-var-deliv-gr-per-val.
end.
if p-deliv-obj-type <> "":U
or p-deliv-obj-code <> 0 then do:
   find first X_clients no-lock where
            X_clients.obj-type = p-deliv-obj-type
       AND X_clients.obj-code = p-deliv-obj-code no-error.
  if not available X_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-deliv-obj-type p-deliv-obj-code"
    p-deliv-obj-type p-deliv-obj-code
    view-as alert-box ERROR.
    return error .
  end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U
or p-deliv-type-code  <> 0 then do:
  find first X_delivery-type no-lock where
              X_delivery-type.deliv-type-code = p-deliv-type-code no-error .
    if not avail X_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-deliv-type-code" p-deliv-type-code skip
      view-as alert-box ERROR.
      return error .
    end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U
or p-deliv-subj-code  <> 0 then do:
    find first X_delivery-subject no-lock where
              X_delivery-subject.deliv-subj-code = p-deliv-subj-code no-error .
    if not avail X_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-deliv-subj-code" p-deliv-subj-code skip
      view-as alert-box ERROR.
      return error .
    end.
end.
IF (
    (p-deliv-type-code <> 0
      OR
    p-deliv-subj-code <> 0)
AND (p-deliv-obj-type <> "":U
     or p-deliv-obj-code <> 0)
   )
OR p-mode <> 'ДОБАВЛЕНИЕ':U
THEN DO:
    IF p-mode = 'ДОБАВЛЕНИЕ':U OR p-mode = 'ИЗМЕНЕНИЕ':U  THEN DO:
      FIND FIRST LOCKED_variant-delivery EXCLUSIVE-LOCK WHERE
                LOCKED_variant-delivery.deliv-type-code = p-deliv-type-code
            AND LOCKED_variant-delivery.deliv-subj-code = p-deliv-subj-code
            AND LOCKED_variant-delivery.obj-type = p-deliv-obj-type
            AND LOCKED_variant-delivery.obj-code = p-deliv-obj-code
          NO-ERROR.
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_variant-delivery no-lock WHERE
                LOCKED_variant-delivery.deliv-type-code = p-deliv-type-code
            AND LOCKED_variant-delivery.deliv-subj-code = p-deliv-subj-code
            AND LOCKED_variant-delivery.obj-type = p-deliv-obj-type
            AND LOCKED_variant-delivery.obj-code = p-deliv-obj-code
          NO-ERROR.
   END.
   IF (p-mode = 'ДОБАВЛЕНИЕ':U
    OR p-mode = 'ИЗМЕНЕНИЕ':U )
    AND NOT AVAILABLE LOCKED_variant-delivery  THEN DO:
        IF LOCKED(LOCKED_variant-delivery) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ВАРИАНТ ДОСТАВКИ занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
    ELSE DO:
      IF NOT AVAILABLE LOCKED_variant-delivery THEN DO:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова p-deliv-type-code"  skip
          "и/или p-deliv-subj-code" skip
          "и/или p-deliv-obj-type p-deliv-obj-code"
          p-deliv-type-code p-deliv-subj-code p-deliv-obj-type p-deliv-obj-code skip
          view-as alert-box ERROR.
          return error .
     END.
    END.
    CREATE tt-variant-delivery.
    BUFFER-COPY LOCKED_variant-delivery TO tt-variant-delivery.
END.
if p-gr-per-val-code <> 0
or p-mode <> 'ДОБАВЛЕНИЕ':U then do:
     IF p-mode = 'ДОБАВЛЕНИЕ':U OR p-mode = 'ИЗМЕНЕНИЕ':U  THEN DO:
        find first locked_group-period-validity exclusive-lock where
                  locked_group-period-validity.gr-per-val-code = p-gr-per-val-code  no-error .
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        find first locked_group-period-validity no-lock where
                  locked_group-period-validity.gr-per-val-code = p-gr-per-val-code  no-error .
    END.
    IF (p-mode = 'ДОБАВЛЕНИЕ':U
    OR p-mode = 'ИЗМЕНЕНИЕ':U )
    AND NOT AVAILABLE LOCKED_group-period-validity  THEN DO:
        IF LOCKED(LOCKED_group-period-validity) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ГРУППЫ СРОКОВ ХРАНЕНИЯ занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
   ELSE DO:
     if not avail locked_group-period-validity then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-gr-per-val-code" p-gr-per-val-code skip
      view-as alert-box ERROR.
      return error .
    end.
  END.
  CREATE tt-group-period-validity.
  BUFFER-COPY LOCKED_group-period-validity TO tt-group-period-validity.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_var-deliv-gr-per-val EXclusive-lock where
                   recid(locked_var-deliv-gr-per-val) = p-doc-rec no-wait no-error.
      if locked locked_var-deliv-gr-per-val then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_var-deliv-gr-per-val no-lock where
                       recid(locked_var-deliv-gr-per-val) = p-doc-rec no-error .
      if not avail locked_var-deliv-gr-per-val then do:
        find first locked_var-deliv-gr-per-val no-lock where
                   locked_var-deliv-gr-per-val.deliv-type-code = p-deliv-type-code no-error .
      end.
    end.
    if not available locked_var-deliv-gr-per-val then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-var-deliv-gr-per-val.
    buffer-copy locked_var-deliv-gr-per-val to tt-var-deliv-gr-per-val.
   end.
   else do:
     create tt-var-deliv-gr-per-val.
     assign
     tt-var-deliv-gr-per-val.deliv-type-code = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-type-code <> 0
                                                 THEN p-deliv-type-code
                                                 ELSE tt-var-deliv-gr-per-val.deliv-type-code)
     tt-var-deliv-gr-per-val.deliv-subj-code = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-subj-code <> 0
                                                 THEN p-deliv-subj-code
                                                 ELSE tt-var-deliv-gr-per-val.deliv-type-code)
     tt-var-deliv-gr-per-val.obj-type        = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-obj-type <> "":U
                                                 THEN p-deliv-obj-type
                                                 ELSE tt-var-deliv-gr-per-val.obj-type)
     tt-var-deliv-gr-per-val.obj-code        = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-obj-code <> 0
                                                 THEN p-deliv-obj-code
                                                 ELSE tt-var-deliv-gr-per-val.obj-code)
     tt-var-deliv-gr-per-val.gr-per-val-code  = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-gr-per-val-code <> 0
                                                 THEN p-gr-per-val-code
                                                 ELSE tt-var-deliv-gr-per-val.gr-per-val-code)
    .
   end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-var-deliv-gr-per-val SHARE-LOCK,       EACH tt-variant-delivery WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY F-deliv-type-name F-deliv-subj-name f-deliv-obj-name F-term-delivery
          F-gr-per-val-name f-gr-per-from f-gr-per-to
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-var-deliv-gr-per-val THEN
    DISPLAY tt-var-deliv-gr-per-val.deliv-type-code
          tt-var-deliv-gr-per-val.deliv-subj-code
          tt-var-deliv-gr-per-val.obj-type tt-var-deliv-gr-per-val.obj-code
          tt-var-deliv-gr-per-val.gr-per-val-code tt-var-deliv-gr-per-val.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help B-variant-delivery f-deliv-obj-name
         tt-var-deliv-gr-per-val.gr-per-val-code B-gr-per-val
         tt-var-deliv-gr-per-val.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyENable :
case p-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    display
    (IF tt-var-deliv-gr-per-val.deliv-type-code <> 0
     THEN tt-var-deliv-gr-per-val.deliv-type-code
     ELSE ?) @ tt-var-deliv-gr-per-val.deliv-type-code
    (IF tt-var-deliv-gr-per-val.deliv-subj-code <> 0
     THEN tt-var-deliv-gr-per-val.deliv-subj-code
     ELSE ?) @ tt-var-deliv-gr-per-val.deliv-subj-code
    (IF tt-var-deliv-gr-per-val.obj-type <> "":U
     THEN tt-var-deliv-gr-per-val.obj-type
     ELSE ?) @ tt-var-deliv-gr-per-val.obj-type
    (IF tt-var-deliv-gr-per-val.obj-code <> 0
     THEN tt-var-deliv-gr-per-val.obj-code
     ELSE ?) @ tt-var-deliv-gr-per-val.obj-code
     (if available locked_variant-delivery
     then locked_variant-delivery.term-delivery
     else ?) @ F-term-delivery
    (if available X_clients
    then X_clients.obj-name
    else "":U) @ f-deliv-obj-name
    (IF AVAILABLE X_delivery-type
     THEN X_delivery-type.deliv-type-name
     ELSE "":U) @ F-deliv-type-name
     (IF AVAILABLE X_delivery-subject
     THEN X_delivery-subject.deliv-subj-name
     ELSE "":U) @ F-deliv-subj-name
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-var-deliv-gr-per-val THEN
    DISPLAY
    tt-var-deliv-gr-per-val.deliv-type-code
    tt-var-deliv-gr-per-val.deliv-subj-code
    tt-var-deliv-gr-per-val.obj-type
    tt-var-deliv-gr-per-val.obj-code
    tt-variant-delivery.term-delivery
    (if available  X_delivery-type then X_delivery-type.deliv-type-name else "":U) @ f-deliv-type-name
    (if available X_delivery-subject then X_delivery-subject.deliv-subj-name else "":U) @ f-deliv-subj-name
    locked_group-period-validity.gr-per-val-name @ f-gr-per-val-name
    locked_group-period-validity.gr-per-from @ f-gr-per-from
    locked_group-period-validity.gr-per-to @ f-gr-per-to
    tt-var-deliv-gr-per-val.des
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = 'ПРОСМОТР':U then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame Dialog-Frame.
end.
ENABLE
B-exit when p-mode <> 'ПРОСМОТР':U
b-quit
B-Hist when p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
tt-var-deliv-gr-per-val.des when p-mode <> 'ПРОСМОТР':U
b-variant-delivery when (p-mode = 'ДОБАВЛЕНИЕ':U
                         and
                         (p-deliv-type-code = 0 and p-deliv-subj-code = 0 and p-deliv-obj-code = 0))
b-gr-per-val WHEN (p-mode = 'ДОБАВЛЕНИЕ':U AND p-gr-per-val-code = 0)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Proc-save :
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-var-deliv-gr-per-val then do:
    create tt-var-deliv-gr-per-val.
end.
assign
frame Dialog-Frame
tt-var-deliv-gr-per-val.deliv-type-code
tt-var-deliv-gr-per-val.deliv-subj-code
tt-var-deliv-gr-per-val.des = tt-var-deliv-gr-per-val.des:SCREEN-VALUE
.
 run ref/vrdlgrp1.p (
input-output p-doc-rec
,input p-mode
,input tt-var-deliv-gr-per-val.deliv-type-code
,input tt-var-deliv-gr-per-val.deliv-subj-code
,input tt-var-deliv-gr-per-val.obj-type
,input tt-var-deliv-gr-per-val.obj-code
,input tt-var-deliv-gr-per-val.gr-per-val-code
,input tt-var-deliv-gr-per-val.des
)
no-error.
if error-status:error then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
