DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-obj-type  like ub.pl-level-mm.obj-type no-undo.
define input parameter p-obj-code  like ub.pl-level-mm.obj-code no-undo.
define input parameter p-pl-code   like ub.pl-level-mm.pl-code  no-undo.
define input parameter p-locl      like ub.place.loc1           no-undo.
define input parameter p-mode as character no-undo.
define input-output parameter p-rid as recid init ? no-undo.
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Карточка поясной вместимости".
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
define buffer buf_pl-level-mm for ub.pl-level-mm.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-capacity AS DECIMAL FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Поясная вместимость, л"
     VIEW-AS FILL-IN
     SIZE 53 BY 1 NO-UNDO.
DEFINE VARIABLE f-level AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Уровень, мм"
     VIEW-AS FILL-IN
     SIZE 53 BY 1 NO-UNDO.
DEFINE VARIABLE f-max-level AS DECIMAL FORMAT ">>>>>9":U INITIAL 0
     LABEL "Верхний уровень пояса, см"
     VIEW-AS FILL-IN
     SIZE 53 BY 1 NO-UNDO.
DEFINE VARIABLE f-min-level AS DECIMAL FORMAT ">>>>>9":U INITIAL 0
     LABEL "Нижний уровень пояса, см"
     VIEW-AS FILL-IN
     SIZE 53 BY 1 NO-UNDO.
DEFINE VARIABLE f-zone AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Номер пояса"
     VIEW-AS FILL-IN
     SIZE 53 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-save AT ROW 1.14 COL 1.4
     b-quit AT ROW 1.14 COL 11.4
     B-Help AT ROW 1.14 COL 36.4
     f-zone AT ROW 2.43 COL 27 COLON-ALIGNED WIDGET-ID 4
     f-min-level AT ROW 3.62 COL 27 COLON-ALIGNED WIDGET-ID 10
     f-max-level AT ROW 4.81 COL 27 COLON-ALIGNED WIDGET-ID 26
     f-level AT ROW 6 COL 27 COLON-ALIGNED WIDGET-ID 28
     f-capacity AT ROW 7.19 COL 27 COLON-ALIGNED WIDGET-ID 30
     SPACE(3.19) SKIP(0.56)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
DO:
  define buffer bf_pl-level-mm for ub.pl-level-mm.
  assign frame Dialog-Frame
    f-zone
    f-min-level
    f-max-level
    f-level
    f-capacity
  .
  find first bf_pl-level-mm where
             bf_pl-level-mm.obj-type  = p-obj-type
         and bf_pl-level-mm.obj-code  = p-obj-code
         and bf_pl-level-mm.pl-code   = p-pl-code
         and (if p-rid <> ? then recid(bf_pl-level-mm) <> p-rid else true)
         and ((bf_pl-level-mm.min-level = f-min-level and
               bf_pl-level-mm.max-level = f-max-level and
               bf_pl-level-mm.level     = f-level) or
              (bf_pl-level-mm.min-level <= f-min-level and
               bf_pl-level-mm.max-level >= f-min-level and
               bf_pl-level-mm.zone <> f-zone) or
              (bf_pl-level-mm.min-level <= f-max-level and
               bf_pl-level-mm.max-level >= f-max-level and
               bf_pl-level-mm.zone <> f-zone) or
              (bf_pl-level-mm.zone = f-zone and
               bf_pl-level-mm.level = f-level))
       no-lock no-error.
  if avail bf_pl-level-mm then
  do:
    message substitute("Найдено пересечение поясов № &1 и № &2 по уровню пояса &3.~nСохранение невозможно!",
                       bf_pl-level-mm.min-level, bf_pl-level-mm.max-level, bf_pl-level-mm.level)
            view-as alert-box message
            buttons ok
            title "Ошибка при сохранении".
    return no-apply.
  end.
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
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
   if p-mode <> 'ДОБАВЛЕНИЕ':U and
      p-mode <> 'ИЗМЕНЕНИЕ':U and
      p-mode <> 'ПРОСМОТР':U
   then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box ERROR.
      undo, return error.
   end.
   frame Dialog-Frame:title = substitute(
     "&1 строки поясной вместимости для резервуара &2 (&3) &4 &5",
     p-mode, p-pl-code, p-locl, p-obj-type, p-obj-code
   ).
   if p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ПРОСМОТР':U then do:
      if p-mode = 'ПРОСМОТР':U then do:
        find first buf_pl-level-mm where
                   recid(buf_pl-level-mm) = p-rid no-lock no-error.
      end.
      else do:
        find first buf_pl-level-mm where
                   recid(buf_pl-level-mm) = p-rid exclusive-lock no-wait no-error.
        if locked buf_pl-level-mm then do:
           message
              vss-workfile vss-revision vss-description skip
              "Запись <Пояса> занята"
           view-as alert-box error .
           undo, return error.
        end.
      end.
      if not available buf_pl-level-mm then do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись <Пояса>"
         view-as alert-box error .
         undo, return error.
      end.
      assign
        f-zone      = buf_pl-level-mm.zone
        f-min-level = buf_pl-level-mm.min-level
        f-max-level = buf_pl-level-mm.max-level
        f-level     = buf_pl-level-mm.level
        f-capacity  = buf_pl-level-mm.capacity
      no-error.
   end.
   run enable_UI in this-procedure.
   if p-mode = 'ПРОСМОТР':U then do:
     disable
       f-zone
       f-min-level
       f-max-level
       f-level
       f-capacity
       b-save
     with frame Dialog-Frame.
   end.
   else do:
     apply "entry" to f-zone in FRAME Dialog-Frame.
   end.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
session:data-entry-return = no .
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-zone f-min-level f-max-level f-level f-capacity
      WITH FRAME Dialog-Frame.
  ENABLE B-save b-quit B-Help f-zone f-min-level f-max-level f-level f-capacity
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
   if f-zone = 0 or
      f-max-level = 0 or
      f-level     = 0 or
      f-capacity  = 0 then
   do:
     message "Ошибка при сохранении.~n"
             "Необходимо заполнить все поля формы." view-as alert-box.
     apply "ENTRY" to f-zone in frame Dialog-Frame.
     return error.
   end.
   do on error undo, return error
   on stop undo, return error:
      if p-mode = 'ДОБАВЛЕНИЕ':U then do:
         create buf_pl-level-mm.
         assign
           buf_pl-level-mm.obj-type = p-obj-type
           buf_pl-level-mm.obj-code = p-obj-code
           buf_pl-level-mm.pl-code  = p-pl-code
           p-rid = recid(buf_pl-level-mm).
         .
      end.
      assign
        buf_pl-level-mm.zone      = f-zone
        buf_pl-level-mm.min-level = f-min-level
        buf_pl-level-mm.max-level = f-max-level
        buf_pl-level-mm.level     = f-level
        buf_pl-level-mm.capacity  = f-capacity
      .
   end.
END PROCEDURE.
