define input parameter parparentproc as widget-handle no-undo .
define input parameter v-parts-recid as recid         no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "редактирование складского места партии":U .
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
define shared variable list-mode as character no-undo .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1.
DEFINE BUTTON b-spr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .88.
DEFINE VARIABLE pl_code AS INTEGER FORMAT "99999999999":U INITIAL 0
     LABEL "&Бар-код"
     VIEW-AS FILL-IN
     SIZE 17.5 BY 1 NO-UNDO.
DEFINE FRAME d-pl-form
     b-quit AT ROW 1.25 COL 2.5
     b-help AT ROW 1.25 COL 12.5
     pl_code AT ROW 2.83 COL 11.5 COLON-ALIGNED
     b-spr AT ROW 2.83 COL 32.25
     ub.place.pl-name AT ROW 4.08 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE
          SIZE 41 BY 1
     ub.place.loc1 AT ROW 5.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE
          SIZE 11.63 BY 1
     ub.place.loc2 AT ROW 6.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE
          SIZE 11.63 BY 1
     ub.place.loc3 AT ROW 7.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE
          SIZE 11.63 BY 1
     ub.place.loc4 AT ROW 8.33 COL 11.5 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE
          SIZE 11.63 BY 1
     ub.place.PS AT ROW 9.58 COL 5.5 NO-LABEL
          VIEW-AS EDITOR
          SIZE 49.25 BY 2.58
     SPACE(0.24) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Складское место".
ASSIGN
       FRAME d-pl-form:SCROLLABLE       = FALSE.
ON CHOOSE OF b-spr IN FRAME d-pl-form
DO:
  define variable rid-list as character no-undo .
  run ref/pl-list.w
    ( input        parparentproc
    , input        "b-sel"
    , input        '':U
    , input        0
    , input        'все':U
    , input-output rid-list
    ) .
  if rid-list = "cancel"
  then do :
    return no-apply .
  end .
  if rid-list <> "":U
  then do:
    find first ub.place no-lock where
        recid( ub.place ) = integer( entry( 1, rid-list ) ) no-error .
    if available ub.place
    then do:
      assign
        pl_code = ub.place.pl-code
      .
      run enable_UI in this-procedure .
    end.
  end.
  apply "ENTRY":U to pl_code in frame d-pl-form.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-pl-form:PARENT eq ?
THEN FRAME d-pl-form:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-pl-form
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
on choose of b-help in frame d-pl-form
do:
  apply "help":u to frame d-pl-form .
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
                v-frame-width = frame d-pl-form:width - 0.3
                fh            = frame d-pl-form:first-child
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
ON WINDOW-CLOSE OF FRAME d-pl-form APPLY "END-ERROR":U TO SELF.
ON GO OF FRAME d-pl-form
DO:
  define variable v-ok as logical no-undo .
  define buffer buf_place for ub.place .
  if input frame d-pl-form pl_code <> 0
  then do:
    find first ub.place no-lock where
               ub.place.obj-type = ub.parts.obj-type                 and
               ub.place.obj-code = ub.parts.obj-code                 and
               ub.place.pl-code  = input frame d-pl-form pl_code no-error .
    if not available ub.place
    then do:
      message "На объекте" parts.obj-type parts.obj-code skip( 0 )
              "не существует складского места с кодом" input frame d-pl-form pl_code skip( 0 )
              "Продолжить?" skip( 0 )
      view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> yes
      then do:
        return no-apply .
      end.
    end.
  end.
  assign
    ub.parts.pl-code = input frame d-pl-form pl_code
  .
END.
ON RETURN OF pl_code IN FRAME d-pl-form
DO:
  apply "CHOOSE":U to b-spr in frame d-pl-form .
  return no-apply.
END.
ON END-ERROR, STOP OF FRAME d-pl-form
DO:
  apply "CHOOSE":U to b-quit in frame d-pl-form .
  return no-apply .
END.
MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  assign
    ub.place.PS :read-only = yes
  .
  find first ub.parts where
      recid( ub.parts ) = v-parts-recid no-error .
  if not available ub.parts
  then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка задания входных параметров" skip( 0 )
            "Не найдена партия" skip( 0 )
            "Код партии" v-parts-recid skip ( 0 )
    view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    pl_code = ub.parts.pl-code
  .
  find first ub.place no-lock where
             ub.place.obj-type = parts.obj-type and
             ub.place.obj-code = parts.obj-code and
             ub.place.pl-code  = parts.pl-code  no-error .
  RUN enable_UI in this-procedure .
  find first ub.gds-obj no-lock where
             ub.gds-obj.obj-type  = ub.parts.obj-type  and
             ub.gds-obj.obj-code  = ub.parts.obj-code  and
             ub.gds-obj.artic     = ub.parts.artic     and
             ub.gds-obj.prod-type = ub.parts.prod-type and
             ub.gds-obj.prod-code = ub.parts.prod-code no-error .
  if available ub.gds-obj and
     ub.gds-obj.place-rsrv = yes
  then do:
    assign
      pl_code :sensitive in frame d-pl-form = no
      b-spr   :sensitive in frame d-pl-form = no
    .
  end.
  frame d-pl-form :title = substitute( 'Складское место на объекте : &1 &2 '
                                         , ub.parts.obj-type
                                         , ub.parts.obj-code
                                         ) .
  wait-for go of frame d-pl-form focus pl_code.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME d-pl-form.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY pl_code
      WITH FRAME d-pl-form.
  IF AVAILABLE ub.place THEN
    DISPLAY ub.place.pl-name ub.place.loc1 ub.place.loc2 ub.place.loc3
          ub.place.loc4 ub.place.PS
      WITH FRAME d-pl-form.
  ENABLE b-quit b-help pl_code b-spr
      WITH FRAME d-pl-form.
END PROCEDURE.
