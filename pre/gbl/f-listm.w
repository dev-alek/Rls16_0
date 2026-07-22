define input  parameter parParentProc  as widget-handle no-undo .
define input  parameter spr      as character no-undo .
define input  parameter lab_user as character no-undo .
define input  parameter fld      as character no-undo .
define input  parameter lab      as character no-undo .
define input  parameter type     as character no-undo .
define output parameter str      as character no-undo .
define output parameter str_rus  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование фильтров - списков со справочниками".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5':u,spr,lab_user,fld,lab,type)
    .
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
define variable flt-rec as recid no-undo.
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc ( output g#report-num ).
DEFINE BUTTON  b-spr
     IMAGE-UP FILE "btn-down-arrow"
     IMAGE-DOWN FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     LABEL "":L
     SIZE 2.5 BY .9.
define variable grp     AS WIDGET NO-UNDO.
define variable flw      AS WIDGET NO-UNDO.
define variable fill_in AS WIDGET NO-UNDO.
define variable txt      AS WIDGET NO-UNDO.
define variable btn     AS WIDGET NO-UNDO.
define variable min-width      AS INT    NO-UNDO INIT 20.
define variable frm                AS CHAR NO-UNDO.
define variable frm-text         AS CHAR NO-UNDO.
define variable type_            AS CHAR NO-UNDO.
define variable lab_              AS CHAR NO-UNDO.
define variable fld_               AS CHAR NO-UNDO.
define variable data              AS CHAR NO-UNDO.
define variable join-tbl          AS CHAR NO-UNDO.
define variable join_rus        AS CHAR NO-UNDO.
define variable join_ext        AS CHAR NO-UNDO.
define variable join_rus_ext AS CHAR NO-UNDO.
define variable ii                    AS INT     NO-UNDO.
define variable ii1                   AS INT     NO-UNDO.
define variable j                    AS INT     NO-UNDO.
define variable s                   AS CHAR NO-UNDO.
define variable a                   AS CHAR NO-UNDO.
define variable next-fill-in     AS LOG   NO-UNDO INIT FALSE.
define variable znak             AS CHAR NO-UNDO.
define variable offset            AS CHAR NO-UNDO.
define variable scr-val          AS CHAR NO-UNDO.
define variable name            AS CHAR NO-UNDO.
define variable ref-list           AS CHAR NO-UNDO.
define variable out-an           AS INT     NO-UNDO.
define variable v_type          AS CHAR NO-UNDO.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Ввести в список внесенное с клавиатуры значение".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить ранее включенное в список значение".
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 2.5 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Отменить формирование критерия"
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сформированный критерий"
     BGCOLOR 8 .
DEFINE VARIABLE list AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 20 BY 5.5 NO-UNDO.
DEFINE VARIABLE togl AS LOGICAL INITIAL no
     LABEL "Включительно":L
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .83 NO-UNDO.
DEFINE FRAME DIALOG-1
     B-help AT ROW 1 COL 1 WIDGET-ID 2
     b-add AT ROW 3.25 COL 3
     b-del AT ROW 3.25 COL 13
     list AT ROW 4.75 COL 3 NO-LABEL
     togl AT ROW 10.25 COL 3
     Btn_OK AT ROW 11.25 COL 3
     Btn_Cancel AT ROW 11.25 COL 13.13
     SPACE(8.11) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "":L
         CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ON CHOOSE OF b-add IN FRAME DIALOG-1
DO:
  run proc-b-add in this-procedure No-ERROR.
  APPLY "ENTRY":U TO btn_cancel IN FRAME DIALOG-1.
END.
ON CHOOSE OF b-del IN FRAME DIALOG-1
DO:
  ASSIGN list.
  IF list:DELETE( list ) THEN.
END.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
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
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
Main-Block:
DO ON ERROR    UNDO Main-Block, RETURN ERROR
      ON STOP       UNDO Main-Block, RETURN ERROR
      ON END-KEY UNDO Main-Block, RETURN ERROR :
   ASSIGN
     offset    = "3"
     frm        = "":U
     frm-text = "":U.
   DO ii = 1 TO NUM-ENTRIES( lab, '*' ) :
        type_ = ENTRY(ii, type, '*' ).
        CASE type_ :
                WHEN 'character':U THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY(ii, offset ) ) + 20 + 2 )
                     frm        = frm        + ',' + "x(20)"
                     frm-text = frm-text + ',' + "x(20)".
                END.
                WHEN 'integer':U THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY(ii, offset ) ) +  10  + 2 )
                     frm        = frm        + ',' + ( ">>>>>>>>>9" )
                     frm-text = frm-text + ',' + ( "x(10)" ).
                END.
                WHEN 'int64':U THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT64( ENTRY(ii, offset ) ) +  10  + 2 )
                     frm        = frm        + ',' + ( ">>>>>>>>>>>>>>>>>>>9" )
                     frm-text = frm-text + ',' + ( "x(20)" ).
                END.
                WHEN 'decimal':U THEN DO:
                   ASSIGN
                     offset    = offset     + ',' + STRING( INT( ENTRY( ii, offset ) ) + 12 + 2 )
                     frm        = frm        + ',' + ">>>>>>>9.999"
                     frm-text = frm-text + ',' + "x(12)".
                END.
                WHEN 'date':U THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY( ii, offset ) ) + 10 + 2 )
                     frm        = frm        + ',' + "99/99/9999"
                     frm-text = frm-text + ',' + "x(10)".
                END.
                WHEN 'logical':U THEN DO:
                   ASSIGN
                     offset    = offset     + ',' + STRING( INT( ENTRY( ii, offset ) ) + 10 + 2 )
                     frm        = frm        + ',' + "yes/no"
                     frm-text = frm-text + ',' + "x(10)".
                END.
                WHEN 'recid':U THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY( ii, offset ) ) +  10  + 2 )
                     frm        = frm        + ',' +  ">>>>>>>>>9"
                     frm-text = frm-text + ',' +  "x(10)" .
                END.
        END CASE.
   END.
   SUBSTR( frm,        1, 1 ) = "".
   SUBSTR( frm-text, 1, 1 ) = "".
   IF INT( ENTRY( NUM-ENTRIES( offset ), offset ) ) > min-width THEN
      min-width = INT( ENTRY( NUM-ENTRIES( offset ), offset ) ).
   IF CAN-DO( "cli,gds", spr ) THEN min-width = min-width + 20 .
   ASSIGN FRAME DIALOG-1:WIDTH-CHAR = min-width + 3.
   IF spr <> "" THEN DO:
       FORM b-spr WITH FRAME DIALOG-1.
       ASSIGN
         b-spr:ROW          = 2
         b-spr:COLUMN    = min-width
         b-spr:VISIBLE      = TRUE
         b-spr:SENSITIVE = TRUE.
       ON CHOOSE OF b-spr IN FRAME DIALOG-1 DO:
         define variable grp-rec AS RECID NO-UNDO.
         define variable ref-rec  AS RECID NO-UNDO.
         CASE spr :
            WHEN 'cli' THEN DO:
              ref-list = "".
              run ref/cli-all.w (
                             parParentProc
                           , "b-sel,b-mark":U
                           , 'орг':U
                           , 'все':U
                           , 'текущие':U
                           , ?
                           , ",,,,,,NO"
                           , "":U
                           , OUTPUT ref-list ).
              IF ref-list <> "":U THEN DO:
                DO ii1 = 1 to num-entries(ref-list):
                  ASSIGN ref-rec = integer(entry(ii1, ref-list)).
                  FIND ub.clients WHERE RECID( ub.clients ) = ref-rec.
                  ASSIGN
                  name = ub.clients.obj-name
                  grp     = FRAME DIALOG-1:FIRST-CHILD.
                  DO WHILE ( grp <> ? ) :
                    flw = grp:FIRST-CHILD.
                    DO WHILE ( flw <> ? ) :
                      IF flw:type = 'fill-in' THEN DO:
                        CASE ENTRY( 2, ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ), '-' ) :
                          WHEN "code" THEN flw:SCREEN-VALUE = STRING( clients.obj-code ).
                          WHEN "type"  THEN flw:SCREEN-VALUE = clients.obj-type.
                        END CASE.
                      END.
                      flw = flw:NEXT-SIBLING.
                    END.
                    grp = grp:NEXT-SIBLING.
                  END.
                  APPLY "ENTRY":U   TO b-add IN FRAME DIALOG-1.
                  RUN proc-b-add in this-procedure.
                END.
              END.
              ELSE DO:
                APPLY "ENTRY":U TO b-spr IN FRAME DIALOG-1.
              end.
            END.
            WHEN 'gds' THEN DO:
              run ref/gds-ref.p ( input parparentproc
                              , input "b-sel,b-mark":U
                              , input ?
                              , input ?
                              , input ?
                              , input ?
                              , input ?
                              , input ?
                              , input ?
                              , input ?
                              , input ?
                              , input ?
                              , OUTPUT ref-list ).
              IF ref-list <> "":U THEN DO:
                DO II1 = 1 to num-entries(ref-list):
                  ASSIGN ref-rec = INT( ENTRY(ii1, ref-list )).
                  FIND ub.goods NO-LOCK WHERE RECID( ub.goods ) = ref-rec.
                  ASSIGN
                  name = ub.goods.gds-name
                  grp     = FRAME DIALOG-1:FIRST-CHILD.
                  DO WHILE ( grp <> ? ) :
                    ASSIGN flw = grp:FIRST-CHILD.
                    DO WHILE ( flw <> ? ) :
                      IF flw:type = 'fill-in' THEN DO:
                        CASE ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ) :
                          WHEN "prod-code" THEN flw:SCREEN-VALUE = STRING( prod-code ).
                          WHEN "prod-type"  THEN flw:SCREEN-VALUE = prod-type.
                          WHEN "artic"          THEN flw:SCREEN-VALUE = artic.
                        END CASE.
                      END.
                      ASSIGN flw = flw:NEXT-SIBLING.
                    END.
                    ASSIGN grp = grp:NEXT-SIBLING.
                  END.
                  APPLY "ENTRY":U   TO b-add IN FRAME DIALOG-1.
                  RUN proc-b-add in this-procedure.
                END.
              END.
              ELSE DO:
                APPLY "ENTRY":U TO b-spr IN FRAME DIALOG-1.
              END.
            END.
         END CASE.
       END.
   END.
   ASSIGN list:WIDTH-CHAR = INT( ENTRY( NUM-ENTRIES( offset ), offset ) ) - 3 + 1.
   IF CAN-DO( "cli,gds", spr) THEN list:WIDTH-CHAR = list:WIDTH-CHAR +  20 .
   IF lab_user = "":U OR lab_user = ? THEN lab_user = lab.
   DO ii = 1 TO NUM-ENTRIES( lab_user, '*' ) :
        lab_ = ENTRY( ii, lab_user, '*' ).
        CREATE TEXT txt
                   ASSIGN
                     FRAME               = FRAME DIALOG-1:HANDLE
                     DATA-TYPE        = "character"
                     FORMAT             = ENTRY( ii, frm-text )
                     SCREEN-VALUE = lab_
                     ROW                  = 1
                     COLUMN            = INT( ENTRY(ii, offset ) ).
   END.
   DO ii = 1 TO NUM-ENTRIES( type, '*' ) :
      ASSIGN
        type_ = ENTRY( ii, type, '*' )
        fld_    = ENTRY( ii, fld,    '*' )
        lab_   = ENTRY( ii, lab,   '*' ).
        CREATE FILL-IN fill_in
                   ASSIGN
                     FRAME            = FRAME DIALOG-1:HANDLE
                     DATA-TYPE     = type_
                     FORMAT          = ENTRY( ii, frm )
                     PRIVATE-DATA = fld_ + ',' + lab_
                     ROW                = 2
                     COLUMN          = INT( ENTRY( ii, offset ) )
                     SENSITIVE       = TRUE
                     VISIBLE            = TRUE.
   END.
   togl = TRUE.
   RUN enable_UI.
   WAIT-FOR GO OF FRAME DIALOG-1.
   ASSIGN list.
   IF list:NUM-ITEMS = 0 THEN RETURN ERROR.
   IF INPUT FRAME DIALOG-1 togl THEN DO:
     ASSIGN
      znak      = " = "
      join-tbl   = " AND "  join_rus        = " И "
      join_ext = " OR "    join_rus_ext = " ИЛИ ".
   END. ELSE DO:
     ASSIGN
      znak      = " <> "
      join-tbl   = " OR "    join_rus        = " ИЛИ "
      join_ext = " AND "  join_rus_ext = " И ".
   END.
   ASSIGN
     str        = '('
     str_rus = '('.
   DO ii = 1 TO list:NUM-ITEMS :
        ASSIGN
          s   = ENTRY( ii, list:LIST-ITEMS )
          str = str + '('.
        IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + '('.
        DO j = 1 TO NUM-ENTRIES( type, '*' ) :
             ASSIGN
               type_ = ENTRY( j, type, '*' )
               fld_    = ENTRY( j, fld,    '*' )
               lab_   = ENTRY( j, lab,   '*' )
               data   = TRIM( ENTRY( j, s, '|' ) ).
             IF type_ = "character" THEN data = '"' + data + '"'.
             IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + lab_ + znak + data.
             IF type_ = "date" THEN data = ENTRY( 2, data, chr(47) ) + ENTRY( 1, data, chr(47) ) + ENTRY( 3, data, chr(47) ).
             str = str + fld_ + znak + data.
             IF j <> NUM-ENTRIES( type, '*' ) THEN DO:
                  str = str + join-tbl.
                  IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + join_rus.
             END.
        END.
        IF CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + lab_user + znak + '"' + TRIM( ENTRY( j, s, '|' ) ) + '"'.
        str = str + ')'.
        IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + ')'.
        IF ii <> list:NUM-ITEMS THEN DO:
           ASSIGN
             str        = str + join_ext
             str_rus = str_rus + join_rus_ext.
        END.
   END.
   ASSIGN
     str        = str        + ')'
     str_rus = str_rus + ')'.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY list togl
      WITH FRAME DIALOG-1.
  ENABLE B-help b-add b-del list togl Btn_OK Btn_Cancel
      WITH FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE proc-b-add :
define variable type_  AS CHAR NO-UNDO.
define variable code_ AS INT     NO-UNDO.
define variable art_     AS CHAR NO-UNDO.
define variable jnum_ AS INT     NO-UNDO.
define variable jsub_  AS INT     NO-UNDO.
define variable jhost-code_ as int no-undo.
define variable v-found as integer no-undo extent 4.
  ASSIGN
   s    = ""
   grp = FRAME DIALOG-1:FIRST-CHILD.
  DO WHILE ( grp <> ? ) :
        flw = grp:FIRST-CHILD.
        DO WHILE ( flw <> ? ) :
             IF flw:type = 'fill-in' THEN DO:
                IF spr = 'cli' THEN DO:
                  CASE ENTRY( 2, ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ), '-' ) :
                      WHEN "code" THEN code_ = INT( flw:SCREEN-VALUE ).
                      WHEN "type"  THEN type_  = flw:SCREEN-VALUE.
                  END CASE.
                END.
                IF spr = 'gds' THEN DO:
                  CASE ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ) :
                       WHEN "prod-code" THEN code_ = INT( flw:SCREEN-VALUE ).
                       WHEN "prod-type"  THEN type_ = flw:SCREEN-VALUE.
                       WHEN "artic"          THEN art_    = flw:SCREEN-VALUE.
                  END CASE.
                END.
                CASE flw:DATA-TYPE :
                   WHEN 'character':U THEN scr-val = STRING(          flw:SCREEN-VALUE,   flw:FORMAT ).
                   WHEN 'decimal':U   THEN scr-val = STRING( DEC( flw:SCREEN-VALUE ), flw:FORMAT ).
                   WHEN 'integer':U     THEN scr-val = STRING( INT( flw:SCREEN-VALUE ),  flw:FORMAT ).
                   WHEN 'int64':U     THEN scr-val = STRING( INT( flw:SCREEN-VALUE ),  flw:FORMAT ).
                   WHEN 'date':U         THEN scr-val = STRING(         flw:SCREEN-VALUE,    'x(10)'          ).
                   WHEN 'logical':U     THEN scr-val = STRING(         flw:SCREEN-VALUE,    'x(10)'          ).
                   WHEN 'recid':U        THEN scr-val = STRING( INT( flw:SCREEN-VALUE ), '>>>>>>>>>9' ).
                END CASE.
                s = s + scr-val + ' |'.
             END.
             flw = flw:NEXT-SIBLING.
        END.
        grp = grp:NEXT-SIBLING.
   END.
   CASE spr :
      WHEN 'cli' THEN DO:
        if lookup(type_, ("":U + chr(44) +
                          'орг':U + chr(44) +
                          'чел':U + chr(44) +
                          'маг':U + chr(44) +
                          'скл':U) ) = 0 then do:
          message "Неверный тип клиента".
          return no-apply.
        end.
        if type_ = "":U then do:
            FIND ub.clients WHERE
                ub.clients.obj-type  = 'орг':U
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[1] = 1.
            FIND ub.clients WHERE
                ub.clients.obj-type  = 'чел':U
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[2] = 1.
            FIND ub.clients WHERE
                ub.clients.obj-type  = 'маг':U
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[3] = 1.
            FIND ub.clients WHERE
                ub.clients.obj-type  = 'скл':U
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[4] = 1.
            if v-found[1] + v-found[2] + v-found[3] + v-found[4] > 1 then do:
              message "Есть два клиента или более с кодом" code_ skip
              "Уточните тип клиента"
              view-as alert-box .
              return no-apply.
            end.
            else do:
              if v-found[1]  = 1 then
              assign
              type_ =   'орг':U
              .
              if v-found[2]  = 1 then
              assign
              type_ =   'чел':U
              .
              if v-found[3]  = 1 then
              assign
              type_ =   'маг':U
              .
              if v-found[4]  = 1 then
              assign
              type_ =   'скл':U
              .
            end.
         end.
         FIND ub.clients WHERE
             ub.clients.obj-type  = type_
         AND ub.clients.obj-code = code_ NO-ERROR.
         IF NOT AVAIL ub.clients THEN DO:
            MESSAGE "Клиент отсутствует".
            RETURN NO-APPLY.
         END.
         ELSE ASSIGN name = ub.clients.obj-name.
      END.
      WHEN 'gds' THEN DO:
        FIND ub.goods WHERE ub.goods.prod-type  = type_
                                        AND ub.goods.prod-code = code_
                                        AND ub.goods.artic          = art_     NO-ERROR.
        IF NOT AVAIL ub.goods THEN DO:
            MESSAGE "Товар отсутствует".
            RETURN NO-APPLY.
        END.
        ELSE do:
          ASSIGN name = ub.goods.gds-name.
        end.
      END.
   END CASE.
  IF CAN-DO( "cli,gds", spr ) THEN s = s + name.
  ii = LOOKUP( s, list:LIST-ITEMS ).
  IF ii = 0 OR ii = ? THEN IF list:ADD-LAST( s ) THEN.
END PROCEDURE.
