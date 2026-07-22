DEFINE BUFFER locked_units FOR ub.units.
DEFINE TEMP-TABLE tt-units NO-UNDO LIKE ub.units.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-mode as character no-undo.
define input parameter p-unit-name like ub.units.unit-name no-undo.
define input-output parameter p-rid as recid init ? no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "карточка единицы измерения".
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
define variable v-db-num like ub.db.db-num no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE UnitType AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 1
     DROP-DOWN-LIST
     SIZE 25.75 BY 1 NO-UNDO.
DEFINE VARIABLE UnitType-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип2"
     VIEW-AS COMBO-BOX INNER-LINES 1
     DROP-DOWN-LIST
     SIZE 25.75 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-units SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     B-Help AT ROW 1 COL 54.88
     tt-units.long-name AT ROW 2.42 COL 20 COLON-ALIGNED
          LABEL "Полное наименование"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
     tt-units.unit-name AT ROW 3.75 COL 20 COLON-ALIGNED
          LABEL "Аббревиатура"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     UnitType AT ROW 3.75 COL 35.25 COLON-ALIGNED
     tt-units.OKEI AT ROW 5.33 COL 20 COLON-ALIGNED
          LABEL "ОКЕИ" format "9999"
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     UnitType-2 AT ROW 5.33 COL 35.25 COLON-ALIGNED
     SPACE(6.12) SKIP(1.17)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Единица измерения"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-undo.
      run ref/c-units.w (
                     INPUT parparentproc
                    ,INPUT '':U
                    ,INPUT 'one':U
                    ,INPUT tt-units.unit-name
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON VALUE-CHANGED OF UnitType IN FRAME Dialog-Frame
DO:
    RUn RereadUnittype2(UnitType:screen-value).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
 if p-mode <> 'ПРОСМОТР':U then do:
    if v-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи ЕД.ИЗМ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-units:
        delete tt-units.
    end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_units EXclusive-lock where
                   recid(locked_units) = p-rid no-wait no-error.
      if locked locked_units then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ЕД.ИЗМ. занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_units no-lock where
                       recid(locked_units) = p-rid no-error .
      if not avail locked_units then do:
        find first locked_units where
                  locKed_units.unit-name = p-unit-name no-error .
      end.
    end.
    if not available locked_units then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ЕД.ИЗМ."
      view-as alert-box error .
      undo, return error.
    end.
    create tt-units.
    buffer-copy locked_units to tt-units.
  end.
  else do:
    create tt-units.
  end.
  RUN MYenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
session:data-entry-return = no .
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-units SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY UnitType UnitType-2
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-units THEN
    DISPLAY tt-units.long-name tt-units.unit-name tt-units.OKEI
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-units.long-name tt-units.unit-name
         UnitType tt-units.OKEI UnitType-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
session:data-entry-return = yes .
UnitType:list-items in frame Dialog-Frame
                                         = 'штучный':U + chr(44) +
                      'дробный':U + chr(44) +
                      'весовой':U + chr(44) +
                      'серийный':U + chr(44) +
                      'топливо':U + chr(44) +
                      'стеклопосуда':U
                      .
UnitType:INNER-LINES = num-entries (Unittype:list-items) .
UnitType:screen-value = entry (1, 'штучный,дробный,серийный,весовой,топливо,2едизма,прпарт,дополнительный,стеклопосуда':U) .
UnitType-2:INNER-LINES = num-entries ('штучный,дробный':U + chr(44) + '2ед':U + chr(44) + 'доп':U) .
UnitType-2:list-items = 'штучный,дробный':U + chr(44) + '2едизма':U + chr(44) + 'дополнительный':U.
 DISPLAY
 UnitType
 UnitType-2
 WITH FRAME Dialog-Frame.
IF AVAILABLE tt-units THEN
    DISPLAY tt-units.long-name tt-units.unit-name tt-units.OKEI
      WITH FRAME Dialog-Frame.
  if p-mode = 'ПРОСМОТР':U then do:
    assign
    b-exit:label = "&Выход".
  end.
  ENABLE
  B-exit when p-mode <> 'ПРОСМОТР':U
  b-quit
  B-Help
  b-hist WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
  tt-units.long-name when p-mode <> 'ПРОСМОТР':U
  tt-units.unit-name when p-mode = 'ДОБАВЛЕНИЕ':U
  UnitType when p-mode <> 'ПРОСМОТР':U
  UnitType-2 when p-mode = 'ИЗМЕНЕНИЕ':U and num-entries(tt-units.type) > 1
  tt-units.OKEI
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  IF p-mode = 'ИЗМЕНЕНИЕ':U then do:
      RUn RereadUnittype2(entry (lookup (ENTRY(1,tt-units.type), 'шту,дро,сер,вес,топ,2ед,прп,доп,сте':U), 'штучный,дробный,серийный,весовой,топливо,2едизма,прпарт,дополнительный,стеклопосуда':U)).
      FRAME Dialog-Frame:title = "Изменение единицы измерения".
      DISPLAY
      tt-units.long-name
      tt-units.OKEI
      tt-units.unit-name
      WITH frame Dialog-Frame.
      UnitType:screen-value = entry (lookup (ENTRY(1,tt-units.type), 'шту,дро,сер,вес,топ,2ед,прп,доп,сте':U), 'штучный,дробный,серийный,весовой,топливо,2едизма,прпарт,дополнительный,стеклопосуда':U) .
      if num-entries(tt-units.type) > 1 then
      UnitType-2:screen-value = entry (lookup (ENTRY(2, tt-units.type), 'шту,дро,сер,вес,топ,2ед,прп,доп,сте':U), 'штучный,дробный,серийный,весовой,топливо,2едизма,прпарт,дополнительный,стеклопосуда':U).
  end.
  else RUn RereadUnittype2(entry (1, 'штучный,дробный,серийный,весовой,топливо,2едизма,прпарт,дополнительный,стеклопосуда':U)).
  if p-mode = 'ПРОСМОТР':U then do:
    hide
    b-exit in frame Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE proc-save :
assign
frame Dialog-Frame
tt-units.long-name
tt-units.unit-name
UNITTYPE
UNITTYPE-2
tt-units.type = substring (UnitType, 1, 3) +
                    (IF UnitType-2:sensitive AND trim(Unittype-2) <> ""
                    then (chr(44) + substring (UnitType-2, 1, 3))
                    else "")
tt-units.OKEI
.
run ref/units01.p (
 input-output p-rid
,input p-mode
,input tt-units.OKEI
,input tt-units.long-name
,input tt-units.type
,input tt-units.unit-name
) no-error.
if error-status:error then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE RereadUnittype2 :
DEFINE INPUT PARAMETER unittype1 as char no-undo.
    CASE unittype1:
      WHEN 'топливо':U then do:
          unittype-2:list-items in frame Dialog-Frame = 'штучный,дробный':U.
          enable
          UnitType-2
          WITH FRAME Dialog-Frame .
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN 'дробный':U then do:
          unittype-2:list-items = chr(44) + '2едизма':U.
          enable
          UnitType-2
          WITH FRAME Dialog-Frame.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN '2едизма':U then do:
          unittype-2:list-items = 'дробный':U.
          enable
          UnitType-2
          WITH FRAME Dialog-Frame.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN 'штучный':U then do:
          unittype-2:list-items = chr(44) + 'дополнительный':U.
          enable
          UnitType-2
          WITH FRAME Dialog-Frame.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      WHEN 'стеклопосуда':U then do:
          unittype-2:list-items = 'штучный':U.
          enable
          UnitType-2
          WITH FRAME Dialog-Frame.
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
      end.
      otherwise do:
          UnitType-2:screen-value = ENTRY(1, unittype-2:list-items).
          disable
          UnitType-2
          WITH FRAME Dialog-Frame.
      end.
    END CASE.
END PROCEDURE.
