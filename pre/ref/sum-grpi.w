DEFINE BUFFER buf_sum-grp FOR ub.sum-grp.
DEFINE BUFFER locked_sum-grp FOR ub.sum-grp.
DEFINE TEMP-TABLE tt-sum-grp NO-UNDO LIKE ub.sum-grp.
define input parameter parparentproc as widget-handle no-undo .
define input        parameter p-mode as character  no-undo.
define input-output parameter p-ri       as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование групп суммовых чеков".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.
PROCEDURE imagelist_loaddef:
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "\":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash\":U
        .
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
            run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
        mPhotomgd = IF v-val-integer = 2 then yes else no.
END PROCEDURE.
PROCEDURE imagelist_decode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "\":U)
                vCh = REPLACE (vCh, "~\":U, "\":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":\":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "\":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, ",":U) = vCh.
        END.
    END.
END PROCEDURE.
PROCEDURE imagelist_encode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN
            ENTRY (vInt, oImageList, ",":U) =
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable tcode      like sum-grp.grp-code no-undo.
define variable rr         as recid    no-undo.
DEFINE VARIABLE mImageList AS LONGCHAR NO-UNDO.
DEFINE VARIABLE mLogical   AS LOGICAL  NO-UNDO.
DEFINE buffer buf_sum-grp-attr for ub.sum-grp-attr .
DEFINE TEMP-TABLE ttImgBar NO-UNDO
    FIELD fID    AS CHARACTER
    FIELD fFrame AS HANDLE
    FIELD fImage AS HANDLE
    FIELD fXPix  AS INTEGER
    FIELD fTrgs  AS HANDLE
    FIELD fFile  AS CHARACTER
    FIELD fNum   AS INTEGER
    INDEX i1 fXPix
    INDEX i2 fID
    INDEX i3 fNum
    .
DEFINE BUTTON b-add
    LABEL "&Добавить"
    SIZE 15 BY 1.13.
DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Ввод "
    SIZE 10 BY 1.
DEFINE BUTTON b-help
    LABEL "Помо&щь"
    SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
    LABEL "&Отмена"
    SIZE 10 BY 1.
DEFINE IMAGE v-IMAGE
    STRETCH-TO-FIT RETAIN-SHAPE
    SIZE 25 BY 4.25.
DEFINE RECTANGLE RECT-1
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 61.88 BY 9.5.
DEFINE VARIABLE n-choose-goods AS LOGICAL INITIAL no
    LABEL "Группа для выбора товаров на кассе"
    VIEW-AS TOGGLE-BOX
    SIZE 39.13 BY .83 NO-UNDO.
DEFINE FRAME d-sumgrp
    b-exit AT ROW 1 COL 1
    b-quit AT ROW 1 COL 11
    b-help AT ROW 1 COL 58 WIDGET-ID 2
    tt-sum-grp.grp-code AT ROW 3 COL 38 COLON-ALIGNED
    LABEL "Код группы" FORMAT "999"
    VIEW-AS FILL-IN
    SIZE 4.5 BY 1
    tt-sum-grp.grp-name AT ROW 4.5 COL 16 COLON-ALIGNED
    LABEL "Название"
    VIEW-AS FILL-IN
    SIZE 41 BY 1
    b-add AT ROW 6 COL 49 WIDGET-ID 8
    n-choose-goods AT ROW 6.25 COL 5.5 WIDGET-ID 4
    RECT-1 AT ROW 2.5 COL 3.5
    v-IMAGE AT ROW 7.25 COL 39.5 WIDGET-ID 10
    SPACE(4.87) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Параметры группы".
ASSIGN
       FRAME d-sumgrp:SCROLLABLE       = FALSE.
ON GO OF FRAME d-sumgrp
    DO:
        assign
            tt-sum-grp.grp-code
            tt-sum-grp.grp-name
            .
        RUN proc-save IN THIS-PROCEDURE NO-ERROR.
        IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    END.
ON CHOOSE OF b-add IN FRAME d-sumgrp
    DO:
        DEFINE VARIABLE vFile AS CHARACTER NO-UNDO.
        DEFINE VARIABLE vLog  AS LOGICAL   NO-UNDO.
        SYSTEM-DIALOG GET-FILE vFile
        FILTERS         "Картинки" "*.jpg,*.png,*.bmp,*.gif":U,         "Картинки *.jpg" "*.jpg":U,         "Картинки *.png" "*.png":U,         "Картинки *.bmp" "*.bmp":U,         "Картинки *.gif" "*.gif":U,         "Все файлы" "*.*":U
        MUST-EXIST
      TITLE "Выбор файла"
      UPDATE vLog
        .
        IF NOT vLog THEN RETURN NO-APPLY.
        RUN ImageAdd IN THIS-PROCEDURE (vFile).
    END.
ON VALUE-CHANGED OF n-choose-goods IN FRAME d-sumgrp
    DO:
        assign n-choose-goods .
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-sumgrp:PARENT eq ?
THEN FRAME d-sumgrp:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-sumgrp
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
on choose of b-help in frame d-sumgrp
do:
  apply "help":u to frame d-sumgrp .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-sumgrp:width - 0.3
                fh            = frame d-sumgrp:first-child
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
ON WINDOW-CLOSE OF FRAME d-sumgrp APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON STOP       UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if not (p-mode = 'ДОБАВЛЕНИЕ':U
        or p-mode = 'ИЗМЕНЕНИЕ':U
        or p-mode = 'ПРОСМОТР':U) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра p-mode" p-mode
  view-as alert-box error .
  undo, return error .
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  p-ri = ?.
  FIND LAST buf_sum-grp NO-LOCK NO-ERROR .
  if available buf_sum-grp then
      tcode = buf_sum-grp.grp-code + 1.
  else
      tcode = 1.
  if tcode >= 1000 then do:
     tcode = ?.
  end.
  CREATE tt-sum-grp.
  tt-sum-grp.grp-code = tcode.
end.
else do:
  if  p-mode = 'ИЗМЕНЕНИЕ':U then do:
    FIND locked_sum-grp EXCLUSIVE-LOCK WHERE recid( locked_sum-grp ) = p-ri .
  end.
  else do:
    FIND locked_sum-grp no-LOCK WHERE recid( locked_sum-grp ) = p-ri .
  end.
  CREATE tt-sum-grp.
  buffer-copy locked_sum-grp to tt-sum-grp.
end.
session:data-entry-return = yes .
RUN Myenable IN THIS-PROCEDURE.
if p-mode = 'ДОБАВЛЕНИЕ':U then
    WAIT-FOR GO OF FRAME d-sumgrp FOCUS tt-sum-grp.grp-code .
else
    WAIT-FOR GO OF FRAME d-sumgrp FOCUS tt-sum-grp.grp-name .
END.
RUN disable_UI.
session:data-entry-return = no .
PROCEDURE disable_UI :
  HIDE FRAME d-sumgrp.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY n-choose-goods
        WITH FRAME d-sumgrp.
    IF AVAILABLE tt-sum-grp THEN
        DISPLAY tt-sum-grp.grp-code tt-sum-grp.grp-name
            WITH FRAME d-sumgrp.
    ENABLE b-exit b-quit b-help RECT-1 v-IMAGE tt-sum-grp.grp-code
        tt-sum-grp.grp-name b-add n-choose-goods
        WITH FRAME d-sumgrp.
END PROCEDURE.
PROCEDURE MyEnable :
    DEFINE VARIABLE vPar-val  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vPar-type AS CHARACTER NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    define VARIABLE vFile as character no-undo .
    IF AVAILABLE tt-sum-grp THEN
    do:
        DISPLAY tt-sum-grp.grp-code tt-sum-grp.grp-name
            WITH FRAME d-sumgrp.
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
        if mImagePh then
        do:
            if p-mode <> 'ПРОСМОТР':U then
            do:
                ENABLE
                    b-add
                    n-choose-goods
                    with frame d-sumgrp.
            end.
            else
            do:
                display
                    b-add
                    n-choose-goods
                    with frame d-sumgrp.
            end.
            for each buf_sum-grp-attr where buf_sum-grp-attr.grp-code = tt-sum-grp.grp-code:
                if buf_sum-grp-attr.attr-code = "image-list" then
                do:
                    if LOOKUP("grp", mImageDir, "\") = 0 then
                    do:
                        vFile = mImageDir + "grp\":U + buf_sum-grp-attr.attr-value .
                    end.
                    else vFile = mImageDir + buf_sum-grp-attr.attr-value .
                    v-IMAGE:LOAD-IMAGE (vFile) in frame d-sumgrp NO-ERROR.
                end.
                if buf_sum-grp-attr.attr-code = "grp-image" then
                do:
                    n-choose-goods = LOGICAL (buf_sum-grp-attr.attr-value) .
                    DISPLAY n-choose-goods with frame d-sumgrp.
                end.
            end.
        end.
    end.
    ENABLE
        b-exit
        when P-mode <> 'ПРОСМОТР':U
        RECT-1
        b-quit
        tt-sum-grp.grp-code
        WHEN p-mode = 'ДОБАВЛЕНИЕ':U
        tt-sum-grp.grp-name
        when P-mode <> 'ПРОСМОТР':U
        n-choose-goods
        WITH FRAME d-sumgrp.
    if p-mode = 'ПРОСМОТР':U then
    do:
        hide
            b-exit in frame d-sumgrp .
        assign
            b-quit:label  = "&Выход"
            b-quit:column = 1
            .
    end.
END PROCEDURE.
PROCEDURE proc-save :
    if p-mode = 'ПРОСМОТР':U then return.
    run ref/sumgrp01.p (
        input-output p-ri
        ,input p-mode
        ,INPUT NO
        ,INPUT tt-sum-grp.grp-code
        ,INPUT tt-sum-grp.grp-name) NO-ERROR.
    if error-status:error then
    do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame d-sumgrp:first-child
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
    else
    do:
        find first buf_sum-grp-attr where buf_sum-grp-attr.grp-code = tt-sum-grp.grp-code and buf_sum-grp-attr.attr-code = "grp-image" no-error .
        if AVAILABLE buf_sum-grp-attr then
        do:
            buf_sum-grp-attr.attr-value = string(n-choose-goods) .
        end.
        else
        do:
            create buf_sum-grp-attr.
            ASSIGN
                buf_sum-grp-attr.attr-code  = "grp-image"
                buf_sum-grp-attr.attr-value = string(n-choose-goods)
                buf_sum-grp-attr.grp-code   = tt-sum-grp.grp-code
                .
        end.
        find first buf_sum-grp-attr where buf_sum-grp-attr.grp-code = tt-sum-grp.grp-code and buf_sum-grp-attr.attr-code = "image-list" no-error .
        if AVAILABLE buf_sum-grp-attr then
        do:
            if buf_sum-grp-attr.attr-value = "" or mImageList <> "" then
            do:
                buf_sum-grp-attr.attr-value = mImageList .
            end.
        end.
        else
        do:
            create buf_sum-grp-attr.
            ASSIGN
                buf_sum-grp-attr.attr-code  = "image-list"
                buf_sum-grp-attr.attr-value = mImageList
                buf_sum-grp-attr.grp-code   = tt-sum-grp.grp-code
                .
        end.
    end.
END PROCEDURE.
PROCEDURE ImageAdd :
    DEFINE INPUT PARAMETER iFile AS CHARACTER NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    DEFINE VARIABLE vNum  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vFile AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vTmp  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vCh2  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vExt  AS CHARACTER NO-UNDO.
    if LOOKUP("grp", mImageDir, "\") = 0 then
    do:
        mImageDir = mImageDir + "grp\":U .
    end.
    RUN verify-file (mImagePreDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImagePreDir).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                OS-ERROR, mImageDir)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    RUN verify-file (mImageDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImageDir).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                OS-ERROR, mImageDir)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    IF iFile BEGINS mImageDir THEN vFile = iFile.
    ELSE
    DO:
        ASSIGN
            vTmp       = SUBSTRING (iFile, 1 +
                MAXIMUM (R-INDEX (iFile, "~\":U), R-INDEX (iFile, "~/":U)))
            vInt       = R-INDEX (vTmp, ".":U)
            vExt       = SUBSTRING (vTmp, vInt)
            vTmp       = SUBSTRING (vTmp, 1, vInt - 1)
            vFile      = mImageDir + vTmp + vExt
            mImageList = vTmp + vExt .
        .
        IF SEARCH (vFile) <> ? THEN
        bl0:
        DO:
            MESSAGE
                "Файл с таким именем уже существует" SKIP
                vFile SKIP (1)
                "Сгенерировать новое имя файла и продолжить?"
                VIEW-AS ALERT-BOX WARNING BUTTONS OK-CANCEL
                TITLE "Предупреждение" UPDATE mLogical.
            IF mLogical = NO THEN RETURN NO-APPLY.
            DO WHILE YES:
                bl1:
                DO:
                    vInt = R-INDEX (vTmp, "#":U).
                    IF vInt > 0 THEN
                    DO:
                        vCh2 = SUBSTRING (vTmp, vInt + 1).
                        IF LENGTH (TRIM (vCh2, "0123456789":U)) = 0 THEN
                        DO:
                            ASSIGN
                                vTmp  = SUBSTRING (vTmp, 1, vInt) +
                                    STRING (INTEGER (vCh2) + 1)
                                vFile = mImageDir + vTmp + vExt
                                .
                            LEAVE bl1.
                        END.
                    END.
                    ASSIGN
                        vTmp  = vTmp + "#1":U
                        vFile = mImageDir + vTmp + vExt
                        .
                END.
                IF SEARCH (vFile) = ? THEN LEAVE bl0.
            END.
        END.
        OS-COPY VALUE (iFile) VALUE (vFile).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 копирования файла~n&2~n&3",
                OS-ERROR, iFile, vFile)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
        v-IMAGE:LOAD-IMAGE (vFile) in frame d-sumgrp NO-ERROR.
    END.
END PROCEDURE.
