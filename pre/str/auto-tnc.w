define input parameter parparentproc as widget-handle no-undo.
define input parameter parmode as character no-undo.
define input-output parameter parrecid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Данные по автотранспорту".
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
define variable ref-list         as character no-undo.
define variable v-af-obj-code    like ub.clients.obj-code no-undo.
define variable v-af-obj-type    like ub.clients.obj-type no-undo.
define variable v-i              AS INTEGER   NO-UNDO.
define variable varauto-tank-sec as CHARACTER no-undo.
define variable v-auto-num       as character no-undo.
DEFINE BUFFER buf_auto-tank        FOR ub.auto-tank.
DEFINE BUFFER type_auto-tank-attr  FOR ub.auto-tank-attr.
DEFINE BUFFER neck_auto-tank-attr  FOR ub.auto-tank-attr.
DEFINE BUFFER sep_auto-tank-attr   FOR ub.auto-tank-attr.
DEFINE BUFFER valve_auto-tank-attr  FOR ub.auto-tank-attr.
DEFINE BUFFER con-sleeve_auto-tank-attr   FOR ub.auto-tank-attr.
DEFINE BUFFER error_auto-tank-attr FOR ub.auto-tank-attr.
DEFINE BUFFER temp_auto-tank-attr  FOR ub.auto-tank-attr.
define buffer buf_auto-section     for ub.auto-section.
DEFINE TEMP-TABLE tt_auto-tank-sec NO-UNDO
   FIELD sec-num     AS integer
   FIELD brutto-qnty AS DECIMAL
   field add-volume  as decimal
   .
DEFINE BUTTON b-add-sec
   LABEL "Добавить"
   SIZE 10 BY 1.
DEFINE BUTTON b-cancel AUTO-END-KEY
   LABEL "&Отмена"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON b-chg-sec
   LABEL "Изменить"
   SIZE 10 BY 1.
DEFINE BUTTON b-choose-auto-firm
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "b-choose-auto-firm"
   SIZE 3 BY 1.
DEFINE BUTTON b-del-sec
   LABEL "Удалить"
   SIZE 10 BY 1.
DEFINE BUTTON b-help
   LABEL "&Помощь"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
   LABEL "&Ввод"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON b-view-sec
   LABEL "Просмотр"
   SIZE 10 BY 1.
DEFINE VARIABLE c-AC-type    AS INTEGER   FORMAT "->,>>>,>>9":U INITIAL 0
   LABEL "Тип АЦ"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "",0,
   "Бензовоз",1,
   "Газовоз",2
   DROP-DOWN-LIST
   SIZE 21.5 BY 1 NO-UNDO.
DEFINE VARIABLE C-neck       AS INTEGER   FORMAT "->,>>>,>>9":U INITIAL 0
   LABEL "Горловина"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "",4,
   "Эллиптическая",2,
   "Прямоугольная или квадратная",1,
   "Цилиндрическая",3,
   "Без горловины/нарушена геометрия",0
   DROP-DOWN-LIST
   SIZE 36.5 BY 1 NO-UNDO.
DEFINE VARIABLE varPS        AS CHARACTER
   VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
   SIZE 58 BY 2.88 DROP-TARGET NO-UNDO.
DEFINE VARIABLE f-error      AS DECIMAL   FORMAT ">>,>>9.999":U INITIAL .4
   LABEL "Относительная погрешность определения объема  АЦ, %"
   VIEW-AS FILL-IN
   SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-temp       AS DECIMAL   FORMAT ">>,>>9.9999999999":U INITIAL .0000125
   LABEL "Темпер.коэф. линейного расширения материала стенки АЦ,°С"
   VIEW-AS FILL-IN
   SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varauto-firm AS CHARACTER FORMAT "X(256)"
   LABEL "Автопредприятие"
   VIEW-AS FILL-IN
   SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varauto-num  AS CHARACTER FORMAT "X(20)"
   LABEL "Гос. номер"
   VIEW-AS FILL-IN
   SIZE 21.5 BY 1 TOOLTIP "Государственный регистрационный номер автомобиля" NO-UNDO.
DEFINE VARIABLE varname      AS CHARACTER FORMAT "X(40)"
   LABEL "Название (марка)"
   VIEW-AS FILL-IN
   SIZE 20.5 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
   SIZE 77.5 BY 11.38.
DEFINE RECTANGLE RECT-2
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
   SIZE 75.5 BY 3.5.
DEFINE VARIABLE SEP AS LOGICAL INITIAL no
   LABEL "Наличие СЭП"
   VIEW-AS TOGGLE-BOX
   SIZE 15 BY .83 NO-UNDO.
DEFINE VARIABLE valve AS LOGICAL INITIAL no
   LABEL "Контрольный вентиль"
   VIEW-AS TOGGLE-BOX
   SIZE 25 BY .83 NO-UNDO.
DEFINE VARIABLE con-sleeve   AS decimal FORMAT ">>>>9.9<"
   LABEL "Длина соединительного рукава, м"
   VIEW-AS FILL-IN
   SIZE 10 BY 1 NO-UNDO.
DEFINE QUERY brw-auto-num-sec FOR
   tt_auto-tank-sec SCROLLING.
DEFINE BROWSE brw-auto-num-sec
   QUERY brw-auto-num-sec DISPLAY
   tt_auto-tank-sec.sec-num FORMAT ">>>>9":U COLUMN-LABEL "№ секции"
   tt_auto-tank-sec.brutto-qnty FORMAT "->>,>>>,>>9.<<<":U COLUMN-LABEL "Вместимость!секции (л)"
   tt_auto-tank-sec.add-volume  FORMAT "->>,>>>,>>9.<<<":U COLUMN-LABEL "Дополнительный объем трубопровода нижнего!налива(л)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 76 BY 9.13.
DEFINE FRAME Dialog-Frame
   b-save AT ROW 1 COL 1
   b-cancel AT ROW 1 COL 11
   b-help AT ROW 1 COL 21
   SEP AT ROW 1.25 COL 56 WIDGET-ID 50
   varname AT ROW 2.5 COL 17.5 COLON-ALIGNED
   varauto-num AT ROW 2.5 COL 54 COLON-ALIGNED
   varauto-firm AT ROW 3.75 COL 17.5 COLON-ALIGNED WIDGET-ID 2
   c-AC-type AT ROW 3.75 COL 54 COLON-ALIGNED WIDGET-ID 36
   b-choose-auto-firm AT ROW 3.79 COL 36.88 WIDGET-ID 4
   C-neck AT ROW 5 COL 17.5 COLON-ALIGNED WIDGET-ID 38
   valve at row 5 col 3 WIDGET-ID 88
   con-sleeve at row 5 col 30 WIDGET-ID 98
   f-error AT ROW 7.25 COL 59.75 COLON-ALIGNED WIDGET-ID 46
   f-temp AT ROW 8.54 COL 3.75 WIDGET-ID 48
   varPS AT ROW 10.25 COL 19.5 NO-LABEL
   b-add-sec AT ROW 14.38 COL 2 WIDGET-ID 22
   b-chg-sec AT ROW 14.38 COL 12 WIDGET-ID 18
   b-del-sec AT ROW 14.38 COL 22 WIDGET-ID 32
   b-view-sec AT ROW 14.38 COL 32 WIDGET-ID 20
   brw-auto-num-sec AT ROW 15.63 COL 1.75 WIDGET-ID 100
   "Информация по секциям автотранспорта" VIEW-AS TEXT
   SIZE 36 BY .67 AT ROW 13.29 COL 21.75 WIDGET-ID 26
   FGCOLOR 4
   "Метрологические характеристики" VIEW-AS TEXT
   SIZE 30.75 BY .67 AT ROW 6.17 COL 23.13 WIDGET-ID 44
   FGCOLOR 4
   "Примечание:" VIEW-AS TEXT
   SIZE 11.88 BY .88 AT ROW 11.29 COL 3.25
   RECT-1 AT ROW 13.63 COL 1 WIDGET-ID 28
   RECT-2 AT ROW 6.5 COL 2 WIDGET-ID 40
   SPACE(1.37) SKIP(15.37)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
   TITLE "Данные по автотранспорту"
   DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
   varauto-firm:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
   varPS:RETURN-INSERTED IN FRAME Dialog-Frame = TRUE
   varPS:READ-ONLY IN FRAME Dialog-Frame       = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.
ON CHOOSE OF b-add-sec IN FRAME Dialog-Frame
   DO:
      define variable unopen as logical no-undo init yes.
      if varauto-num:screen-value = ? or trim(varauto-num:screen-value) = "" then
      do :
         message "Введите номер автотранспорта!" view-as alert-box.
         return no-apply.
      end .
      if c-AC-type = 0 then
      do :
         message "Введите тип АЦ!" view-as alert-box.
         return no-apply.
      end .
      if c-AC-type = 1 and C-neck = 4 then
      do:
      end.
      if c-AC-type = 2 then
      do:
         FIND FIRST tt_auto-tank-sec NO-LOCK NO-ERROR.
         if available (tt_auto-tank-sec) then
         do:
            message "Для данного газовоза уже настроены параметры вместимости." skip
               "Вы уверены, что хотите добавить секцию газовозу?"
               view-as alert-box question buttons yes-no update unopen.
         end.
      end.
      ASSIGN
         varauto-num      = varauto-num:screen-value
         varauto-tank-sec = ?
         .
      if unopen then
      do:
         run str/auto-tncs.w
            ( input        'ДОБАВЛЕНИЕ':U
            ,input        varauto-num
            ,input        c-AC-type
            ,input        C-neck
            ,input-output varauto-tank-sec
            ) no-error.
         RUN init-proc.
         OPEN QUERY brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK.
         FIND FIRST tt_auto-tank-sec WHERE tt_auto-tank-sec.sec-num = integer(varauto-tank-sec) NO-LOCK NO-ERROR.
         IF AVAILABLE tt_auto-tank-sec THEN
         DO:
            REPOSITION brw-auto-num-sec TO RECID recid(tt_auto-tank-sec) NO-ERROR.
         END.
         for each tt_auto-tank-sec no-lock :
            disable varauto-num with frame Dialog-Frame.
         end.
         apply "value-changed" to brw-auto-num-sec in frame dialog-frame.
      end.
   END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
   DO:
      if not available ub.auto-tank then
         for each buf_auto-section exclusive-lock where buf_auto-section.auto-num = varauto-num :
            delete buf_auto-section .
         end.
   END.
ON CHOOSE OF b-chg-sec IN FRAME Dialog-Frame
   DO:
      if available tt_auto-tank-sec then
      do:
         ASSIGN
            varauto-tank-sec = string(tt_auto-tank-sec.sec-num)
            .
         run str/auto-tncs.w
            ( input        'ИЗМЕНЕНИЕ':U
            ,input        varauto-num
            ,input        c-AC-type
            ,input        C-neck
            ,input-output varauto-tank-sec
            ) no-error.
         RUN init-proc.
         OPEN QUERY brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK.
         FIND FIRST tt_auto-tank-sec WHERE tt_auto-tank-sec.sec-num = integer(varauto-tank-sec) NO-LOCK NO-ERROR.
         IF AVAILABLE tt_auto-tank-sec THEN
         DO:
            REPOSITION brw-auto-num-sec TO RECID recid(tt_auto-tank-sec) NO-ERROR.
         END.
         apply "value-changed" to brw-auto-num-sec in frame dialog-frame.
      end.
      else
      do:
         message "Не выбрана секция." view-as alert-box error.
      end.
   END.
ON CHOOSE OF b-choose-auto-firm IN FRAME Dialog-Frame
   DO:
      run ref/cli-all.w
         ( parparentproc
         , input  "b-sel"
         , ?
         , ?
         , ?
         , ?
         , ?
         , ?
         ,output ref-list
         ).
      If ref-list <> "" then
      do :
         find first ub.clients no-lock
            where recid(ub.clients) = integer(ref-list) no-error.
         if available ub.clients then
         do :
            varauto-firm = ub.clients.obj-type + " " + string(ub.clients.obj-code) .
         end.
      end.
      else
      do :
         varauto-firm = "".
      end.
      display varauto-firm WITH FRAME Dialog-Frame.
   END.
ON CHOOSE OF b-del-sec IN FRAME Dialog-Frame
   DO:
      define variable varlog as log NO-UNDO.
      if available tt_auto-tank-sec then
      do:
         ASSIGN
            v-auto-num = varauto-num
            .
         MESSAGE "Удалить секцию?" view-as alert-box question
            buttons yes-no
            update varlog.
         if varlog = false then return no-apply.
         FIND FIRST buf_auto-section WHERE buf_auto-section.auto-num = v-auto-num
            and buf_auto-section.section-num = tt_auto-tank-sec.sec-num EXCLUSIVE-LOCK NO-ERROR.
         IF AVAILABLE buf_auto-section THEN
            DELETE buf_auto-tank.
         DELETE tt_auto-tank-sec.
         OPEN QUERY brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK.
      end.
      else
      do:
         message "Не выбрана секция." view-as alert-box error.
      end.
      for each tt_auto-tank-sec no-lock :
         disable varauto-num with frame Dialog-Frame.
      end.
      find first tt_auto-tank-sec no-lock no-error.
      if not available tt_auto-tank-sec then enable varauto-num with frame Dialog-Frame.
      apply "value-changed" to brw-auto-num-sec in frame dialog-frame.
   END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
   DO:
      if varauto-num:screen-value = ? or trim(varauto-num:screen-value) = ""
         or varname:screen-value = ? or trim(varname:screen-value) = ""
         then
      do :
         message "Заполните поля 'марка' и 'гос. номер'" view-as alert-box.
         return no-apply .
      end.
      if c-AC-type = 0 and not SEP then
      do:
         message "Выберите тип АЦ" view-as alert-box.
         return no-apply .
      end.
      if c-AC-type = 1 and C-neck = 4 then
      do:
         message "Выберите тип горловины" view-as alert-box.
         return no-apply .
      end.
      if varauto-firm = "" then
      do:
         message "Выберите автопредприятие" view-as alert-box.
         return no-apply .
      end.
      if parmode = 'ДОБАВЛЕНИЕ':U then
      do:
         if can-find (first ub.auto-tank where ub.auto-tank.auto-num = input frame Dialog-Frame varauto-num)
            then
         do:
            message "Уже существует автотранспорт с гос. номером: " input frame Dialog-Frame varauto-num view-as alert-box.
            return no-apply.
         end.
         create ub.auto-tank.
         assign
            parrecid             = recid(ub.auto-tank)
            ub.auto-tank.status_ = 'тек':U
            .
      end.
      assign
        valve
        con-sleeve
      .
      if parmode = 'ДОБАВЛЕНИЕ':U or
         parmode = 'ИЗМЕНЕНИЕ':U then
      do:
         assign
            ub.auto-tank.auto-num  = input frame Dialog-Frame varauto-num
            ub.auto-tank.name      = input frame Dialog-Frame varname
            ub.auto-tank.ps        = input frame Dialog-Frame varps
            ub.auto-tank.type-AC   = input frame Dialog-Frame c-AC-type
            ub.auto-tank.type-neck = input frame Dialog-Frame C-neck
            .
         if varauto-firm <> "" then
         do:
            assign
               ub.auto-tank.firm-code = integer(entry(2,varauto-firm," "))
               ub.auto-tank.firm-type = string(entry(1,varauto-firm," "))
               .
         end.
      end.
      if parmode = 'ДОБАВЛЕНИЕ':U then
      do :
         if varauto-firm <> "" then
         do :
            create ub.auto-tank-attr.
            assign
               ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
               ub.auto-tank-attr.attr-code  = "auto-firm"
               ub.auto-tank-attr.attr-value = input frame Dialog-Frame varauto-firm
               .
         end.
         create ub.auto-tank-attr.
         assign
            ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
            ub.auto-tank-attr.attr-code  = "auto-sep"
            ub.auto-tank-attr.attr-value = string(SEP)
            .
         create ub.auto-tank-attr.
         assign
            ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
            ub.auto-tank-attr.attr-code  = "autotype-AC"
            ub.auto-tank-attr.attr-value = string(c-AC-type)
            .
         if c-AC-type = 1 then
         do :
            create ub.auto-tank-attr.
            assign
               ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
               ub.auto-tank-attr.attr-code  = "autotype-neck"
               ub.auto-tank-attr.attr-value = string(C-neck)
               .
            if f-error <> 0 or f-error <> ? then
            do:
               create ub.auto-tank-attr.
               assign
                  ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  ub.auto-tank-attr.attr-code  = "auto-error"
                  ub.auto-tank-attr.attr-value = string(f-error)
                  .
            end.
            if f-temp <> 0 or f-temp <> ? then
            do:
               create ub.auto-tank-attr.
               assign
                  ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  ub.auto-tank-attr.attr-code  = "auto-temp"
                  ub.auto-tank-attr.attr-value = string(f-temp)
                  .
            end.
         end.
         if c-AC-type = 2 then
         do :
            create ub.auto-tank-attr.
            assign
               ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
               ub.auto-tank-attr.attr-code  = "valve"
               ub.auto-tank-attr.attr-value = string(valve)
               .
            if con-sleeve > 0 then
            do:
               create ub.auto-tank-attr.
               assign
                  ub.auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  ub.auto-tank-attr.attr-code  = "con-sleeve"
                  ub.auto-tank-attr.attr-value = string(con-sleeve)
                  .
            end.
         end.
      end.
      if parmode = 'ИЗМЕНЕНИЕ':U then
      do:
         if varauto-firm <> "" then
         do :
            ub.auto-tank.firm-code   = integer(entry(2,varauto-firm," ")) .
            ub.auto-tank.firm-type   = string(entry(1,varauto-firm," ")) .
         end.
         else
         do :
            ub.auto-tank.firm-code   = 0 .
            ub.auto-tank.firm-type   = "" .
         end.
         if available sep_auto-tank-attr then sep_auto-tank-attr.attr-value = string(SEP) .
         else
         do :
            create sep_auto-tank-attr.
            assign
                sep_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                sep_auto-tank-attr.attr-code  = "auto-sep"
                sep_auto-tank-attr.attr-value = string(SEP)
                .
         end.
         if c-AC-type = 2 then
         do :
            if available valve_auto-tank-attr then valve_auto-tank-attr.attr-value = string(valve) .
            else
            do :
                create valve_auto-tank-attr.
                assign
                    valve_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                    valve_auto-tank-attr.attr-code  = "valve"
                    valve_auto-tank-attr.attr-value = string(valve)
                .
            end .
            if con-sleeve > 0 then
            do:
               if available con-sleeve_auto-tank-attr then con-sleeve_auto-tank-attr.attr-value = string(con-sleeve) .
               else
               do :
                    create con-sleeve_auto-tank-attr.
                    assign
                        con-sleeve_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                        con-sleeve_auto-tank-attr.attr-code  = "con-sleeve"
                        con-sleeve_auto-tank-attr.attr-value = string(con-sleeve)
                    .
               end .
            end.
         end.
         if f-error <> 0 and f-error <> ? then
         do :
            if available error_auto-tank-attr then error_auto-tank-attr.attr-value = input frame Dialog-Frame f-error .
            else
            do :
               create error_auto-tank-attr.
               assign
                  error_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  error_auto-tank-attr.attr-code  = "auto-error"
                  error_auto-tank-attr.attr-value = input frame Dialog-Frame f-error
                  .
            end.
         end.
         else
         do :
            if available error_auto-tank-attr then delete error_auto-tank-attr.
         end.
         if f-temp <> 0 and f-temp <> ? then
         do :
            if available temp_auto-tank-attr then temp_auto-tank-attr.attr-value = input frame Dialog-Frame f-temp .
            else
            do :
               create temp_auto-tank-attr.
               assign
                  temp_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  temp_auto-tank-attr.attr-code  = "auto-temp"
                  temp_auto-tank-attr.attr-value = input frame Dialog-Frame f-temp
                  .
            end.
         end.
         else
         do :
            if available temp_auto-tank-attr then delete temp_auto-tank-attr.
         end.
         if c-AC-type <> 0 and c-AC-type <> ? then
         do :
            if available type_auto-tank-attr then type_auto-tank-attr.attr-value = input frame Dialog-Frame c-AC-type .
            else
            do :
               create type_auto-tank-attr.
               assign
                  type_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  type_auto-tank-attr.attr-code  = "autotype-AC"
                  type_auto-tank-attr.attr-value = input frame Dialog-Frame c-AC-type
                  .
            end.
         end.
         else
         do :
            if available type_auto-tank-attr then delete type_auto-tank-attr.
         end.
         if C-neck <> 4 and C-neck <> ? and c-AC-type <> 2 then
         do :
            if available neck_auto-tank-attr then neck_auto-tank-attr.attr-value = input frame Dialog-Frame C-neck .
            else
            do :
               create neck_auto-tank-attr.
               assign
                  neck_auto-tank-attr.auto-num   = ub.auto-tank.auto-num
                  neck_auto-tank-attr.attr-code  = "autotype-neck"
                  neck_auto-tank-attr.attr-value = input frame Dialog-Frame C-neck
                  .
            end.
         end.
         else
         do :
            if available neck_auto-tank-attr then delete neck_auto-tank-attr.
         end.
      end.
      ub.auto-tank.brutto-qnty = 0 .
      for each ub.auto-section no-lock where ub.auto-section.auto-num = varauto-num:
        ub.auto-tank.brutto-qnty = ub.auto-tank.brutto-qnty + ub.auto-section.brutto-qnty.
      end.
   END.
ON CHOOSE OF b-view-sec IN FRAME Dialog-Frame
   DO:
      if available tt_auto-tank-sec then
      do:
         ASSIGN
            varauto-num      = if available ub.auto-tank then ub.auto-tank.auto-num else varauto-num:screen-value
            varauto-tank-sec = string(tt_auto-tank-sec.sec-num)
            .
         run str/auto-tncs.w
            ( input        'ПРОСМОТР':U
            ,input        varauto-num
            ,input        c-AC-type
            ,input        C-neck
            ,input-output varauto-tank-sec
            ) no-error.
      end.
      else
      do:
         message "Не выбрана секция." view-as alert-box error.
      end.
   END.
ON choose OF brw-auto-num-sec IN FRAME Dialog-Frame
   DO:
      find first tt_auto-tank-sec no-error .
   END.
ON VALUE-CHANGED OF c-AC-type IN FRAME Dialog-Frame
   DO:
      assign c-AC-type .
      if c-AC-type = 1 then
      do:
         enable
            C-neck
            f-error
            f-temp
            with frame Dialog-Frame .
         display
            f-error
            f-temp
            with frame Dialog-Frame .
         hide
            valve
            con-sleeve
            in frame Dialog-Frame .
      end.
      else
      if c-AC-type = 2 then
      do:
         hide
            C-neck
            f-error
            f-temp
            in frame Dialog-Frame .
         display
            valve
            con-sleeve
            with frame Dialog-Frame .
         enable
            valve
            con-sleeve
            with frame Dialog-Frame .
      end.
   END.
ON VALUE-CHANGED OF C-neck IN FRAME Dialog-Frame
   DO:
      assign C-neck .
   END.
ON VALUE-CHANGED OF f-error IN FRAME Dialog-Frame
   DO:
      assign f-error .
   END.
ON VALUE-CHANGED OF f-temp IN FRAME Dialog-Frame
   DO:
      assign f-temp .
   END.
ON VALUE-CHANGED OF SEP IN FRAME Dialog-Frame
   DO:
      assign SEP .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse brw-auto-num-sec :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if parmode = 'ПРОСМОТР':U then
   do:
      find first ub.auto-tank where recid(ub.auto-tank) = parrecid no-lock.
      find first error_auto-tank-attr no-lock
         where error_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and error_auto-tank-attr.attr-code = "auto-error" no-error.
      find first temp_auto-tank-attr no-lock
         where temp_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and temp_auto-tank-attr.attr-code = "auto-temp" no-error.
      find first type_auto-tank-attr no-lock
         where type_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and type_auto-tank-attr.attr-code = "autotype-AC" no-error.
      find first neck_auto-tank-attr no-lock
         where neck_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and neck_auto-tank-attr.attr-code = "autotype-neck" no-error.
      find first sep_auto-tank-attr no-lock
         where sep_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and sep_auto-tank-attr.attr-code = "auto-sep" no-error.
      find first valve_auto-tank-attr no-lock
         where valve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and valve_auto-tank-attr.attr-code = "valve" no-error.
      find first con-sleeve_auto-tank-attr no-lock
         where con-sleeve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
         and con-sleeve_auto-tank-attr.attr-code = "con-sleeve" no-error.
   end.
   if parmode = 'ИЗМЕНЕНИЕ':U then
   do:
      do transaction:
         find first ub.auto-tank where recid(ub.auto-tank) = parrecid exclusive-lock.
         find first error_auto-tank-attr exclusive-lock
            where error_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and error_auto-tank-attr.attr-code = "auto-error" no-error.
         find first temp_auto-tank-attr exclusive-lock
            where temp_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and temp_auto-tank-attr.attr-code = "auto-temp" no-error.
         find first type_auto-tank-attr exclusive-lock
            where type_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and type_auto-tank-attr.attr-code = "autotype-AC" no-error.
         find first neck_auto-tank-attr exclusive-lock
            where neck_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and neck_auto-tank-attr.attr-code = "autotype-neck" no-error.
         find first sep_auto-tank-attr exclusive-lock
            where sep_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and sep_auto-tank-attr.attr-code = "auto-sep" no-error.
         find first valve_auto-tank-attr exclusive-lock
            where valve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and valve_auto-tank-attr.attr-code = "valve" no-error.
         find first con-sleeve_auto-tank-attr exclusive-lock
            where con-sleeve_auto-tank-attr.auto-num = ub.auto-tank.auto-num
            and con-sleeve_auto-tank-attr.attr-code = "con-sleeve" no-error.
      end.
   end.
   if parmode = 'ПРОСМОТР':U or
      parmode = 'ИЗМЕНЕНИЕ':U then
   do:
      assign
         varauto-num  = ub.auto-tank.auto-num
         varname      = ub.auto-tank.NAME
         varps        = ub.auto-tank.ps
         varauto-firm = string (ub.auto-tank.firm-type) + " " + string (ub.auto-tank.firm-code)
         c-AC-type    = ub.auto-tank.type-AC
         C-neck       = ub.auto-tank.type-neck.
      if available error_auto-tank-attr then f-error = decimal(error_auto-tank-attr.attr-value).
      if available temp_auto-tank-attr then f-temp = decimal(temp_auto-tank-attr.attr-value) .
      if available sep_auto-tank-attr then sep = logical (sep_auto-tank-attr.attr-value) .
      if available valve_auto-tank-attr then valve = logical (valve_auto-tank-attr.attr-value) .
      if available con-sleeve_auto-tank-attr then con-sleeve = decimal(con-sleeve_auto-tank-attr.attr-value) .
      if varauto-firm = "" or varauto-firm = ? then
      do:
         FOR first auto-tank-attr no-lock where auto-tank-attr.attr-code = "auto-firm"
            and auto-tank-attr.auto-num = ub.auto-tank.auto-num:
            varauto-firm = auto-tank-attr.attr-value .
         end.
      end.
   end.
   run init-proc in this-procedure .
   RUN local-enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
   HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
   DISPLAY SEP varname varauto-num varauto-firm c-AC-type C-neck f-error f-temp
      varPS
      WITH FRAME Dialog-Frame.
   ENABLE b-cancel b-help RECT-1 RECT-2 SEP c-AC-type b-choose-auto-firm C-neck
      f-error f-temp varPS b-view-sec brw-auto-num-sec
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
   OPEN QUERY brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK.
END PROCEDURE.
PROCEDURE init-proc :
   define variable v-diam   as character no-undo .
   define variable v-name   as decimal   no-undo .
   define variable v-lenght as character no-undo .
   define variable v-width  as character no-undo .
   FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK:
      DELETE tt_auto-tank-sec.
   END.
   v-auto-num = if available ub.auto-tank then ub.auto-tank.auto-num else varauto-num:screen-value in frame Dialog-Frame .
   FOR EACH buf_auto-section WHERE buf_auto-section.auto-num = v-auto-num NO-LOCK:
      CREATE tt_auto-tank-sec.
      ASSIGN
         tt_auto-tank-sec.sec-num     = buf_auto-section.section-num
         tt_auto-tank-sec.brutto-qnty = buf_auto-section.brutto-qnty
         tt_auto-tank-sec.add-volume  = buf_auto-section.add-volume
      NO-ERROR.
   END.
   FIND FIRST tt_auto-tank-sec WHERE tt_auto-tank-sec.sec-num = 1 NO-LOCK NO-ERROR.
   IF AVAILABLE tt_auto-tank-sec THEN
   DO:
      REPOSITION brw-auto-num-sec TO RECID recid(tt_auto-tank-sec) NO-ERROR.
   END.
   apply "value-changed" to brw-auto-num-sec in frame dialog-frame.
END PROCEDURE.
PROCEDURE local-enable_UI :
   RUN enable_ui IN THIS-PROCEDURE.
   if parmode = 'ДОБАВЛЕНИЕ':U or parmode = 'ИЗМЕНЕНИЕ':U then
   do:
      enable b-choose-auto-firm c-AC-type varPS varauto-num varname varauto-firm b-save b-add-sec b-chg-sec b-del-sec with frame Dialog-Frame.
      assign
         varps:read-only = no.
      if c-AC-type = 1 then
      do:
         enable
            C-neck
            f-error
            f-temp
            sep
            with frame Dialog-Frame .
         display
            f-error
            f-temp
            with frame Dialog-Frame .
      end.
      if sep then
      do:
         disable
            C-neck
            f-error
            f-temp
            with frame Dialog-Frame .
      end.
   end.
   hide
    valve
    con-sleeve
    in frame Dialog-Frame .
   apply "value-changed" to c-ac-type in frame dialog-frame.
   OPEN QUERY brw-auto-num-sec FOR EACH tt_auto-tank-sec EXCLUSIVE-LOCK.
   if parmode = 'ПРОСМОТР':U
   then do :
     disable
         b-choose-auto-firm c-AC-type varPS varauto-num varname varauto-firm sep
         C-neck f-error f-temp valve con-sleeve
         with frame Dialog-Frame .
   end .
END PROCEDURE.
