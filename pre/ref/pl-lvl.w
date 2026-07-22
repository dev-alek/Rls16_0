define input parameter parparentproc   as widget-handle  no-undo .
define input parameter p-obj-type      as character      no-undo.
define input parameter p-obj-code      as integer        no-undo.
define input parameter p-pl-code       as integer        no-undo.
define input-output parameter  p-pl-level as decimal          no-undo.
define output parameter p-ok      as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: 10804996d925, 3000, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pl-lvl.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/pl-lvl.w $":U .
define variable vss-description as character no-undo init "Редактирование записи в градуировочной таблице".
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
define variable v-pl-level-next    as integer      no-undo.
define variable v-pl-level-prev    as integer      no-undo.
define variable v-pl-qnty-next     as decimal      no-undo.
define variable v-pl-qnty-prev     as decimal      no-undo.
define variable v-new           as logical      no-undo.
define buffer buf_pl-level    for pl-level .
define buffer buf_pl-level-attr    for pl-level-attr .
define buffer buf_place    for place .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-pl-deltaV AS DECIMAL FORMAT "9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.6 BY 1 NO-UNDO.
DEFINE VARIABLE v-pl-level AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Уровень, см"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-pl-level-next-str AS CHARACTER FORMAT "X(3)":U INITIAL "-"
     LABEL "Следующий уровнь"
      VIEW-AS TEXT
     SIZE 6.6 BY .67 NO-UNDO.
DEFINE VARIABLE v-pl-level-prev-str AS CHARACTER FORMAT "X(3)":U INITIAL "-"
     LABEL "Предыдущий уровень"
      VIEW-AS TEXT
     SIZE 5 BY .67 NO-UNDO.
DEFINE VARIABLE v-pl-qnty AS DECIMAL FORMAT "->,>>>,>>9.999":U INITIAL 0
     LABEL "Объем, литры"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-pl-qnty-next-str AS CHARACTER FORMAT "X(10)":U INITIAL "-"
     LABEL "Следующий объем"
      VIEW-AS TEXT
     SIZE 12.6 BY .67 NO-UNDO.
DEFINE VARIABLE v-pl-qnty-prev-str AS CHARACTER FORMAT "X(10)":U INITIAL "-"
     LABEL "Предыдущий объем"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.
DEFINE VARIABLE v-pl-tarir-delta AS DECIMAL FORMAT "9.999":U INITIAL 0
     LABEL "Погрешность составления, %"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     v-pl-level AT ROW 3.52 COL 13.8 COLON-ALIGNED WIDGET-ID 2
     v-pl-qnty AT ROW 3.52 COL 42.8 COLON-ALIGNED WIDGET-ID 4
     v-pl-tarir-delta AT ROW 3.52 COL 85.8 COLON-ALIGNED WIDGET-ID 14
     v-pl-deltaV AT ROW 3.52 COL 116.8 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     v-pl-level-prev-str AT ROW 2.52 COL 22.2 COLON-ALIGNED WIDGET-ID 6
     v-pl-qnty-prev-str AT ROW 2.52 COL 53.6 COLON-ALIGNED WIDGET-ID 10
     v-pl-level-next-str AT ROW 4.81 COL 20.6 COLON-ALIGNED WIDGET-ID 8
     v-pl-qnty-next-str AT ROW 4.81 COL 38.6 WIDGET-ID 12
     "Вместимости, м3/мм:" VIEW-AS TEXT
          SIZE 20 BY .62 AT ROW 4.05 COL 98.8 WIDGET-ID 18
     "Коэффициент" VIEW-AS TEXT
          SIZE 12 BY .71 AT ROW 3.38 COL 98.8 WIDGET-ID 16
     SPACE(19.79) SKIP(2.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
   assign
      v-pl-level
      v-pl-qnty
      v-pl-tarir-delta
      v-pl-deltaV
   .
   IF v-pl-level < 0
   OR v-pl-level = ?
   THEN DO:
      message
         "Уровень должен быть не меньше ноля"
         skip
      view-as alert-box information.
      RETURN NO-APPLY.
   END.
   IF v-pl-qnty < 0
   OR v-pl-qnty = ?
   THEN DO:
      message
         "Объем должен быть не меньше ноля"
         skip
      view-as alert-box information.
      RETURN NO-APPLY.
   END.
   if v-pl-deltaV <= 0
   then do :
     message
         "Коэффициент вместимости должен быть больше ноля"
         skip
     view-as alert-box information.
     RETURN NO-APPLY.
   end .
   run check-pl-level in this-procedure NO-ERROR.
   IF ERROR-STATUS:ERROR then do:
      message
         error-status:get-message(1) skip
         return-value
      view-as alert-box error .
      return no-apply .
   end.
   run prev-next-show in this-procedure.
   run save-pl-level  in this-procedure no-error.
   IF ERROR-STATUS:ERROR then do:
      message
         error-status:get-message(1) skip
         return-value
      view-as alert-box error .
      return no-apply .
   end.
   assign
      p-ok = true
   .
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
   find  first buf_place
         where buf_place.obj-type = p-obj-type
            and buf_place.obj-code = p-obj-code
            and buf_place.pl-code  = p-pl-code
         no-lock
         no-error
         .
   IF p-pl-level <> ? THEN DO:
      find first buf_pl-level
           where buf_pl-level.obj-type = p-obj-type
             and buf_pl-level.obj-code = p-obj-code
             and buf_pl-level.pl-code  = p-pl-code
             and buf_pl-level.pl-level = p-pl-level
           share-lock
           no-wait
           no-error
           .
      IF NOT AVAILABLE buf_pl-level THEN DO:
         IF locked buf_pl-level THEN dO:
            return error "Эта запись градуировочной таблицы в данный момент редактируется".
         END.
         else do:
            return error "Не найдена запись в градуировочной таблице".
         end.
      END.
      find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                    and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                    and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                    and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                    and buf_pl-level-attr.attr-code = "tarir-delta"
                                                    no-error .
      if not available buf_pl-level-attr
      then do :
        return error "Не найдена запись атрибута с погрешностью составления в градуировочной таблице".
      end .
      assign
         v-pl-level = buf_pl-level.pl-level
         v-pl-qnty  = buf_pl-level.pl-qnty
         v-pl-tarir-delta = decimal(buf_pl-level-attr.attr-value)
         v-pl-deltaV = ?
         FRAME Dialog-Frame:TITLE = SUBSTITUTE  ( "Изменение строки градуировочной таблицы для резервуара &1 (&2) &3 &4"
                                                , p-pl-code
                                                , buf_place.loc1
                                                , p-obj-code
                                                , p-obj-type
                                                )
      .
      find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                    and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                    and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                    and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                    and buf_pl-level-attr.attr-code = "deltaV"
                                                    no-error .
      if available buf_pl-level-attr
      then do :
        assign v-pl-deltaV = decimal(buf_pl-level-attr.attr-value) no-error .
      end .
   end.
   ELSE DO:
      assign
         v-new = TRUE
         v-pl-level = ?
         v-pl-qnty  = 0
         v-pl-deltaV = ?
         FRAME Dialog-Frame:TITLE = SUBSTITUTE  ( "Создание строки градуировочной таблицы для резервуара &1 (&2) &3 &4"
                                                , p-pl-code
                                                , buf_place.loc1
                                                , p-obj-code
                                                , p-obj-type
                                                )
      .
      find first ub.place-attr no-lock where ub.place-attr.obj-type = buf_place.obj-type
                                         and ub.place-attr.obj-code = buf_place.obj-code
                                         and ub.place-attr.pl-code = buf_place.pl-code
                                         and ub.place-attr.attr-code = "place-type"
                                         no-error .
      if not available ub.place-attr
      or (available ub.place-attr and ub.place-attr.attr-value = "2")
      then do :
        v-pl-tarir-delta = 0.25 .
      end .
      else do :
        v-pl-tarir-delta = 0.2 .
      end .
   END.
   run check-pl-level in this-procedure NO-ERROR.
      IF ERROR-STATUS:ERROR then do:
         message
            error-status:get-message(1) skip
            return-value
         view-as alert-box error .
      end.
   run prev-next-show in this-procedure.
   RUN enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-pl-level :
define buffer bf_pl-level    for pl-level .
do
on error undo, return error
:
   IF p-pl-level <> v-pl-level
   THEN DO:
      find first bf_pl-level
           where bf_pl-level.obj-type = p-obj-type
             and bf_pl-level.obj-code = p-obj-code
             and bf_pl-level.pl-code  = p-pl-code
             and bf_pl-level.pl-level = v-pl-level
         no-lock
         no-error
         .
       IF AVAILABLE bf_pl-level THEN DO:
          RETURN ERROR SUBSTITUTE("Уже есть запись в градуировочной таблице с уровнем &1", v-pl-level) .
       END.
   END.
   IF v-pl-level <> ?
   THEN DO:
      find first bf_pl-level
         where bf_pl-level.obj-type = p-obj-type
            and bf_pl-level.obj-code = p-obj-code
            and bf_pl-level.pl-code  = p-pl-code
            and bf_pl-level.pl-level > v-pl-level
         no-lock
         no-error
         .
      IF AVAILABLE bf_pl-level then do:
         IF bf_pl-level.pl-qnty < v-pl-qnty THEN DO:
            RETURN ERROR SUBSTITUTE ( "Объем (&1) для текущего уровня (&2) больше, чем объем (&3) для следующего уровня (&4)"
                                    , v-pl-qnty
                                    , v-pl-level
                                    , bf_pl-level.pl-qnty
                                    , bf_pl-level.pl-level
                                    ) .
         END.
         assign
            v-pl-level-next = bf_pl-level.pl-level
            v-pl-qnty-next  = bf_pl-level.pl-qnty
         .
      end.
      find last  bf_pl-level
         where bf_pl-level.obj-type = p-obj-type
            and bf_pl-level.obj-code = p-obj-code
            and bf_pl-level.pl-code  = p-pl-code
            and bf_pl-level.pl-level < v-pl-level
         no-lock
         no-error
         .
      IF AVAILABLE bf_pl-level then do:
         IF bf_pl-level.pl-qnty > v-pl-qnty THEN DO:
            RETURN ERROR SUBSTITUTE ( "Объем (&1) для текущего уровня (&2) меньше, чем объем (&3) для предыдущего уровня (&4)"
                                    , v-pl-qnty
                                    , v-pl-level
                                    , bf_pl-level.pl-qnty
                                    , bf_pl-level.pl-level
                                    ) .
         END.
         assign
            v-pl-level-prev = bf_pl-level.pl-level
            v-pl-qnty-prev  = bf_pl-level.pl-qnty
         .
      end.
   end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-pl-level v-pl-qnty v-pl-tarir-delta v-pl-deltaV v-pl-level-prev-str
          v-pl-qnty-prev-str v-pl-level-next-str v-pl-qnty-next-str
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help v-pl-level v-pl-qnty v-pl-tarir-delta v-pl-deltaV
         v-pl-level-prev-str v-pl-qnty-prev-str v-pl-level-next-str
         v-pl-qnty-next-str
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE prev-next-show :
do
on error undo, return error
:
   assign
      v-pl-level-next-str  = IF v-pl-level-next <> 0 THEN STRING(v-pl-level-next) ELSE "-"
      v-pl-level-prev-str  = IF v-pl-level-prev <> 0 THEN STRING(v-pl-level-prev) ELSE "-"
      v-pl-qnty-next-str   = IF v-pl-qnty-next  <> 0 THEN STRING(v-pl-qnty-next ) ELSE "-"
      v-pl-qnty-prev-str   = IF v-pl-qnty-prev  <> 0 THEN STRING(v-pl-qnty-prev ) ELSE "-"
   .
   display
      v-pl-level-next-str
      v-pl-level-prev-str
      v-pl-qnty-next-str
      v-pl-qnty-prev-str
   WITH FRAME Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE save-pl-level :
do
transaction
on error undo, return error
:
   IF v-new THEN DO:
      create buf_pl-level .
      assign
         buf_pl-level.obj-type = p-obj-type
         buf_pl-level.obj-code = p-obj-code
         buf_pl-level.pl-code  = p-pl-code
      .
   END.
   assign
      buf_pl-level.pl-level = v-pl-level
      buf_pl-level.pl-qnty  = v-pl-qnty
   .
   find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                 and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                 and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                 and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                 and buf_pl-level-attr.attr-code = "tarir-delta"
                                                 no-error .
   if not available buf_pl-level-attr
   then do :
     create buf_pl-level-attr .
     assign
       buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
       buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
       buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
       buf_pl-level-attr.attr-code = "tarir-delta"
       buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
     .
   end .
   assign buf_pl-level-attr.attr-value = string(v-pl-tarir-delta) .
   if v-pl-deltaV > 0
   then do :
     find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                   and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                   and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                   and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                   and buf_pl-level-attr.attr-code = "deltaV"
                                                   no-error .
     if not available buf_pl-level-attr
     then do :
       create buf_pl-level-attr .
       assign
         buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
         buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
         buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
         buf_pl-level-attr.attr-code = "deltaV"
         buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
       .
     end .
     assign buf_pl-level-attr.attr-value = string(v-pl-deltaV) .
   end .
end.
END PROCEDURE.
