DEFINE TEMP-TABLE tt-asi NO-UNDO LIKE Code
      index parent parent code.
DEFINE TEMP-TABLE tt-tank NO-UNDO LIKE Code
       index parent parent code.
define input  parameter parparentproc as handle no-undo.
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define stream sReadfile.
define variable mObj as character no-undo.
define variable mtypeasi as character no-undo.
define variable MCom as character no-undo.
define variable mteg as character no-undo.
define variable mvalue as character no-undo.
define buffer tt-asi_Exp for tt-asi.
define buffer tt-tank_exp for tt-tank.
define variable tempStr as character no-undo.
define variable is-ProcArch64 as logical no-undo.
os-command silent value( 'set pro >>procarch') .
    if search ("procarch") = ?
    then do:
message
       "Не найден файл с данными PROCESSOR_ARCHITECTURE, проверьте настройки propath - должен быть указан путь рабочий директории"
      view-as alert-box.
      return.
    end.
input from value (search('procarch')) no-convert.
    import tempStr.
    if not index ("PROCESSOR_ARCHITECTURE=AMD64", tempStr) = 0
      then assign is-ProcArch64 = true.
    import tempStr.
    if not index ("PROCESSOR_ARCHITEW6432=AMD64", tempStr) = 0
      then assign is-ProcArch64 = true.
    input close.
is-ProcArch64 = false.
DEFINE BUTTON bsavefile
     LABEL "Сохранить в файл"
     SIZE 20 BY 1.
DEFINE BUTTON btloabfile
     LABEL "Загрузить из файла"
     SIZE 21 BY 1.
DEFINE BUTTON Btload
     LABEL "Загрузить из реестра"
     SIZE 21 BY 1.
DEFINE BUTTON Btn_Cancel-2 AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.
DEFINE BUTTON Btn_OK
     LABEL "Сохранить в реестр"
     SIZE 20 BY 1.
DEFINE BUTTON Bt_ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.
DEFINE VARIABLE ftype AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "АСИ ТН","1",
                     "ifsfserver","2"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE fip AS CHARACTER FORMAT "X(256)":U
     LABEL "IP Адрес"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE FPort AS CHARACTER FORMAT "X(256)":U
     LABEL "IP-Port"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE fSpec AS CHARACTER FORMAT "X(10)":U
     LABEL "Спецификация"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Авто","99",
                     "1.0","0",
                     "1.1","1"
     DROP-DOWN-LIST
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE rfrtime AS CHARACTER FORMAT "X(100)":U
     LABEL "Частота опроса уровнемеров RefreshTime (Секунды)"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE tlive AS CHARACTER FORMAT "X(100)":U
     LABEL "Время жизни ответа TimeLive (Секунды)"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE BUTTON bt-add
     LABEL "Добавить"
     SIZE 10.75 BY 1.
DEFINE BUTTON bt-del
     LABEL "Удалить"
     SIZE 10.63 BY 1.
DEFINE BUTTON bt-edit
     LABEL "Сохранить/Изменить"
     SIZE 23 BY 1.
DEFINE VARIABLE fbit AS CHARACTER FORMAT "X(256)":U
     LABEL "Бит данных"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "4","5","6","7","8"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE fchet AS CHARACTER FORMAT "X(256)":U
     LABEL "Четность"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Чет","Even",
                     "Нечет","Odd",
                     "Нет","NONE",
                     "Маркер","Mark",
                     "Пробел","Space"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE fCom AS CHARACTER FORMAT "X(256)":U
     LABEL "COM порт"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Ethernet","COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9","COM10","COM11","COM12","COM13","COM14","COM15","COM16","COM17","COM18","COM19","COM20","COM21","COM22","COM23","","COM24","COM25","COM26","COM27","COM28","COM29","COM30","COM31","COM32","COM33","COM34","COM35","COM36","COM37","COM38","COM39","COM40","COM41","COM42","COM43","COM44","COM45","COM46","COM47","COM48","COM49","COM50","COM51","COM52","COM53","COM54","COM55","COM56","COM57","COM58","COM59","COM60","COM61","COM62","COM63","COM64","COM65","COM66","COM67","COM68","COM69","COM70","COM71","COM72","COM73","COM74","COM75","COM76","COM77","COM78","COM79","COM80","COM81","COM82","COM83","COM84","COM85","COM86","COM87","COM88","COM89","COM90","COM91","COM92","COM93","COM94","COM95","COM96","COM97","COM98","COM99","COM100","COM101","COM102","COM103","COM104","COM105","COM106","COM107","COM108","COM109","COM110","COM111","COM112","COM113","COM114","COM115","COM116","COM117","COM118","COM119","COM120","COM121","COM122","COM123","COM124","COM125","COM126","COM127","COM128","COM129","COM130","COM131","COM132","COM133","COM134","COM135","COM136","COM137","COM138","COM139","COM140","COM141","COM142","COM143","COM144","COM145","COM146","COM147","COM148","COM149","COM150","COM151","COM152","COM153","COM154","COM155","COM156","COM157","COM158","COM159","COM160","COM161","COM162","COM163","COM164","COM165","COM166","COM167","COM168","COM169","COM170","COM171","COM172","COM173","COM174","COM175","COM176","COM177","COM178","COM179","COM180","COM181","COM182","COM183","COM184","COM185","COM186","COM187","COM188","COM189","COM190","COM191","COM192","COM193","COM194","COM195","COM196","COM197","COM198","COM199","COM200","COM201","COM202","COM203","COM204","COM205","COM206","COM207","COM208","COM209","COM210","COM211","COM212","COM213","COM214","COM215","COM216","COM217","COM218","COM219","COM220","COM221","COM222","COM223","COM224","COM225","COM226","COM227","COM228","COM229","COM230","COM231","COM232","COM233","COM234","COM235","COM236","COM237","COM238","COM239","COM240","COM241","COM242","COM243","COM244","COM245","COM246","COM247","COM248","COM249","COM250","COM251","COM252","COM253","COM254","COM255","COM256"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE fspeed AS CHARACTER FORMAT "X(256)":U
     LABEL "Скорость"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "75","110","134","150","300","600","1200","1800","2400","4800","7200","9600","14400","19200","38400","57600","115200","128000"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE ftypeasi AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип АСИ/Протокол"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Modbus","Kedr","Veeder-root","DOMS","ifsfserver"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE fipasi AS CHARACTER FORMAT "X(256)":U
     LABEL "IP-адрес"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE fportasi AS CHARACTER FORMAT "X(256)":U
     LABEL "Порт"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE fSlaveId AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE TOut AS CHARACTER FORMAT "X(256)":U
     LABEL "Таймаут опроса TimeOut (миллисекунды)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE BUTTON bt-add-2
     LABEL "Добавить"
     SIZE 15 BY 1.
DEFINE BUTTON bt-del-2
     LABEL "Удалить"
     SIZE 15 BY 1.
DEFINE BUTTON bt-edit-2
     LABEL "Сохранить/Изменить"
     SIZE 23 BY 1.
DEFINE BUTTON BUTTON-2
     IMAGE-UP FILE "cmp/select.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE fnompres AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 1
     LABEL "Номер датчика для давления ПФ"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "1","2","3","4","5","6","7","8","9"
     DROP-DOWN-LIST
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE Faddr AS CHARACTER FORMAT "x(8)"
     LABEL "Номер канала"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1.
DEFINE VARIABLE Fcoor AS CHARACTER FORMAT "x(20)"
     LABEL "Коорд1"
     VIEW-AS FILL-IN
     SIZE 17.13 BY 1 NO-UNDO.
DEFINE QUERY BROWSE-3 FOR
      tt-asi SCROLLING.
DEFINE QUERY BROWSE-5 FOR
      tt-tank SCROLLING.
DEFINE BROWSE BROWSE-3
  QUERY BROWSE-3 NO-LOCK DISPLAY
      tt-asi.parent COLUMN-LABEL "Тип АСИ" FORMAT "x(20)":U
      tt-asi.code COLUMN-LABEL "COM порт" FORMAT "x(10)":U
      tt-asi.misc1 COLUMN-LABEL "Скорость" FORMAT "x(7)":U
      tt-asi.misc2 COLUMN-LABEL "Четность" FORMAT "x(10)":U
      tt-asi.misc3 COLUMN-LABEL "Бит Данных" FORMAT "x(9)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64 BY 3.5 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-5
  QUERY BROWSE-5 NO-LOCK DISPLAY
      tt-tank.code COLUMN-LABEL "Адрес / Номер канала" FORMAT "x(30)":U
      tt-tank.CodeValue COLUMN-LABEL "Коорд1" FORMAT "x(45)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61.5 BY 5 ROW-HEIGHT-CHARS .62 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_Cancel-2 AT ROW 1.25 COL 2 WIDGET-ID 2
     Btn_OK AT ROW 1.25 COL 18.5 WIDGET-ID 4
     Btload AT ROW 1.25 COL 40 WIDGET-ID 6
     Bt_ok AT ROW 2.5 COL 2 WIDGET-ID 12
     bsavefile AT ROW 2.5 COL 18.5 WIDGET-ID 8
     btloabfile AT ROW 2.5 COL 40 WIDGET-ID 10
     SPACE(7.50) SKIP(30.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры подключения уровнемеров" WIDGET-ID 100.
DEFINE FRAME FRAME-C
     BROWSE-5 AT ROW 1.25 COL 2 WIDGET-ID 500
     bt-add-2 AT ROW 6.5 COL 3.5 WIDGET-ID 10
     bt-del-2 AT ROW 6.5 COL 19.5 WIDGET-ID 12
     bt-edit-2 AT ROW 6.5 COL 36 WIDGET-ID 14
     Faddr AT ROW 7.75 COL 14.5 COLON-ALIGNED WIDGET-ID 4
     Fcoor AT ROW 7.75 COL 36.5 COLON-ALIGNED WIDGET-ID 22
     BUTTON-2 AT ROW 7.75 COL 57 WIDGET-ID 26
     fnompres AT ROW 9 COL 36.5 COLON-ALIGNED WIDGET-ID 28
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.5 ROW 23.5
         SIZE 66.5 BY 10.75
         TITLE "Параметры резервуарного парка" WIDGET-ID 600.
DEFINE FRAME FRAME-B
     BROWSE-3 AT ROW 1.5 COL 2 WIDGET-ID 300
     bt-add AT ROW 5.5 COL 2 WIDGET-ID 10
     bt-del AT ROW 5.5 COL 13.5 WIDGET-ID 12
     bt-edit AT ROW 5.5 COL 25 WIDGET-ID 14
     ftypeasi AT ROW 6.75 COL 19 COLON-ALIGNED WIDGET-ID 20
     fSlaveId AT ROW 6.75 COL 47 COLON-ALIGNED WIDGET-ID 24
     fCom AT ROW 8 COL 11 COLON-ALIGNED WIDGET-ID 16
     fchet AT ROW 8 COL 40 COLON-ALIGNED WIDGET-ID 8
     fbit AT ROW 9.25 COL 40 COLON-ALIGNED WIDGET-ID 10
     fportasi AT ROW 9.26 COL 40 COLON-ALIGNED WIDGET-ID 10
     fspeed AT ROW 9.25 COL 11 COLON-ALIGNED WIDGET-ID 18
     fipasi AT ROW 9.3 COL 11 COLON-ALIGNED WIDGET-ID 8
     TOut AT ROW 10.5 COL 40 COLON-ALIGNED WIDGET-ID 6
     fSpec AT ROW 11.6 COL 15 COLON-ALIGNED WIDGET-ID 10
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.5 ROW 10.5
         SIZE 66.5 BY 12.75
         TITLE "Параметры подключения" WIDGET-ID 400.
DEFINE FRAME FRAME-A
     fip AT ROW 1.25 COL 10 COLON-ALIGNED WIDGET-ID 4
     ftype AT ROW 1.25 COL 44.5 COLON-ALIGNED WIDGET-ID 8
     FPort AT ROW 2.75 COL 10 COLON-ALIGNED WIDGET-ID 6
     tlive AT ROW 4 COL 50.5 COLON-ALIGNED WIDGET-ID 6
     rfrtime AT ROW 5.25 COL 50.5 COLON-ALIGNED WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.5 ROW 3.75
         SIZE 66.5 BY 6.5
         TITLE "Параметры для внешних запросов" WIDGET-ID 200.
ASSIGN FRAME FRAME-A:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-C:FRAME = FRAME Dialog-Frame:HANDLE.
DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.
ASSIGN XXTABVALXX = FRAME FRAME-A:MOVE-AFTER-TAB-ITEM (btloabfile:HANDLE IN FRAME Dialog-Frame)
       XXTABVALXX = FRAME FRAME-B:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-C:HANDLE)
       XXTABVALXX = FRAME FRAME-A:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-B:HANDLE)
.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fbit:HIDDEN IN FRAME FRAME-B           = TRUE.
ASSIGN
       fchet:HIDDEN IN FRAME FRAME-B           = TRUE.
ASSIGN
       fCom:HIDDEN IN FRAME FRAME-B           = TRUE.
ASSIGN
       fspeed:HIDDEN IN FRAME FRAME-B           = TRUE.
ON window-close OF FRAME Dialog-Frame
do:
  apply "END-ERROR":U to self.
end.
ON value-changed OF BROWSE-3 IN FRAME FRAME-B
do:
  if available tt-asi
  then do:
     assign
         ftypeasi:screen-value in frame FRAME-B = tt-asi.parent
         fCom    :screen-value in frame FRAME-B = tt-asi.code
         .
     apply  "VALUE-CHANGED" to ftypeasi in frame FRAME-B.
     apply  "VALUE-CHANGED" to fCom     in frame FRAME-B.
     assign
         fspeed  :screen-value in frame FRAME-B = tt-asi.Misc1
         fchet   :screen-value in frame FRAME-B = tt-asi.Misc2
         fbit    :screen-value in frame FRAME-B = tt-asi.Misc3
         fipasi  :screen-value in frame FRAME-B = tt-asi.misc5
         fportasi:screen-value in frame FRAME-B = tt-asi.misc6
         fSlaveId:screen-value in frame FRAME-B = tt-asi.misc7
         TOut:screen-value in frame FRAME-B = tt-asi.misc9
         fSpec:screen-value in frame FRAME-B = tt-asi.misc10
         .
        OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
       apply  "VALUE-CHANGED" to BROWSE-5 in frame FRAME-C.
   end.
end.
ON value-changed OF BROWSE-5 IN FRAME FRAME-C
do:
  if available tt-tank
  then assign
       Faddr:screen-value = tt-tank.code
       Fcoor:screen-value = tt-tank.CodeValue
       fnompres:screen-value = if tt-tank.misc1 eq "" then "1" else tt-tank.misc1
       .
end.
ON CHOOSE OF bsavefile IN FRAME Dialog-Frame
DO:
   define variable v-file-name as character no-undo.
   define variable vok as logical no-undo.
   SYSTEM-DIALOG GET-FILE v-file-name
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Файл реестра(*.reg) " "*.reg",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite
        save-as
        use-filename
        update vok
        default-extension "txt"
        .
    IF vok THEN do:
       run proc-save (v-file-name).
    end.
END.
ON value-changed OF fSpec IN FRAME FRAME-B
do:
  if available tt-asi and tt-asi.parent = "Modbus" then tt-asi.misc10 = fSpec:screen-value in frame FRAME-B.
end.
ON choose OF bt-add IN FRAME FRAME-B
do:
  define buffer tt-asi_buf for tt-asi.
  if    ftypeasi:screen-value eq ?
     or fCom    :screen-value eq ?
  then do:
     message ftypeasi:label " и "  fCom:label "должны быть заполнены"
     view-as alert-box.
     return no-apply.
  end.
  if fCom    :screen-value in frame FRAME-B eq "Ethernet"
  then do:
     find first tt-asi_buf where tt-asi_buf.misc5 = fipasi      :screen-value in frame FRAME-B
                             and tt-asi_buf.misc6 = fportasi    :screen-value in frame FRAME-B
                        no-lock no-error.
     if available tt-asi_buf
     then do:
        message "Уже есть запись с тип IP "  tt-asi.misc5 " Порт " tt-asi.misc6
        view-as alert-box.
        return no-apply.
     end.
  end.
  else do:
     find first tt-asi_buf where tt-asi_buf.parent = ftypeasi:screen-value in frame FRAME-B
                             and tt-asi_buf.code   = fCom    :screen-value in frame FRAME-B
                        no-lock no-error.
     if available tt-asi_buf
     then do:
        message "Уже есть запись с тип АСИ "  tt-asi_buf.parent " Порт " tt-asi_buf.code
        view-as alert-box.
        return no-apply.
     end.
  end.
  create tt-asi.
  assign
     tt-asi.parent = ftypeasi:screen-value in frame FRAME-B
     tt-asi.code   = fCom    :screen-value in frame FRAME-B
     tt-asi.Misc1  = fspeed  :screen-value in frame FRAME-B when not fCom    :screen-value in frame FRAME-B eq "Ethernet"
     tt-asi.Misc2  = fchet   :screen-value in frame FRAME-B when not fCom    :screen-value in frame FRAME-B eq "Ethernet"
     tt-asi.Misc3  = fbit    :screen-value in frame FRAME-B when not fCom    :screen-value in frame FRAME-B eq "Ethernet"
     tt-asi.misc5  = fipasi  :screen-value in frame FRAME-B
     tt-asi.misc6  = fportasi:screen-value in frame FRAME-B
     tt-asi.misc7  = fSlaveId:screen-value in frame FRAME-B
     tt-asi.misc9  = TOut:screen-value in frame FRAME-B
     tt-asi.misc10   = (if ftypeasi:screen-value in frame FRAME-B = "Modbus"  then fSpec:screen-value in frame FRAME-B else "")
     .
  OPEN QUERY BROWSE-3 FOR EACH tt-asi NO-LOCK INDEXED-REPOSITION.
  apply  "VALUE-CHANGED" to BROWSE-3 in frame FRAME-B.
  OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
  apply  "VALUE-CHANGED" to BROWSE-5 in frame FRAME-C.
end.
ON choose OF bt-add-2 IN FRAME FRAME-C
do:
  if available tt-asi
  then do:
     define buffer tt-tank_buf for tt-tank.
     if    Faddr:screen-value eq ?
        or Fcoor:screen-value eq ?
     then do:
        message Faddr:label " и "  Fcoor:label "должны быть заполнены"
        view-as alert-box.
        return no-apply.
     end.
     find first tt-tank_buf where tt-tank_buf.parent    = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6
                              and tt-tank_buf.code      = Faddr:screen-value
     no-lock no-error.
     if available tt-tank_buf
     then
        message
        "Уже есть адрес " tt-tank_buf.code " для " tt-asi.parent tt-asi.code
        view-as alert-box.
     else do:
        find first tt-tank_buf where tt-tank_buf.CodeValue = Fcoor:screen-value
        no-lock no-error.
        if available tt-tank_buf
        then
           message
             "Уже есть  " Fcoor:label tt-tank_buf.CodeValue " для " replace (tt-tank_buf.parent, chr(4)," ")
           view-as alert-box.
        else do:
              create tt-tank.
              assign
                 tt-tank.parent    = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6
                 tt-tank.code      = Faddr:screen-value
                 tt-tank.CodeValue = Fcoor:screen-value
                 tt-tank.misc1  = fnompres:screen-value when ftypeasi    :screen-value in frame FRAME-B eq "kedr"
              .
              OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
              apply  "VALUE-CHANGED" to BROWSE-5 in frame FRAME-C.
        end.
     end.
  end.
end.
ON choose OF bt-del IN FRAME FRAME-B
do:
  if avail tt-asi
  then do:
      for each tt-tank where tt-tank.parent    = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6:
         delete tt-tank.
      end.
      delete tt-asi.
      assign
         ftypeasi:screen-value in frame FRAME-B = ""
         fCom    :screen-value in frame FRAME-B = ""
         fspeed  :screen-value in frame FRAME-B = ""
         fchet   :screen-value in frame FRAME-B = ""
         fbit    :screen-value in frame FRAME-B = ""
         fipasi  :screen-value in frame FRAME-B = ""
         fportasi:screen-value in frame FRAME-B = ""
         fSlaveId:screen-value in frame FRAME-B = ""
      .
      OPEN QUERY BROWSE-3 FOR EACH tt-asi NO-LOCK INDEXED-REPOSITION.
      apply  "VALUE-CHANGED" to BROWSE-3 in frame FRAME-B.
      OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
      apply  "VALUE-CHANGED" to BROWSE-5 in frame FRAME-c.
   end.
end.
ON choose OF bt-del-2 IN FRAME FRAME-C
do:
  if avail tt-tank then
  delete tt-tank.
  OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
end.
ON choose OF bt-edit IN FRAME FRAME-B
do:
  define buffer tt-asi_buf for tt-asi.
  define buffer tt-tank_buf for tt-tank.
  if    ftypeasi:screen-value eq ?
     or fCom    :screen-value eq ?
  then do:
     message ftypeasi:label " и "  fCom:label "должны быть заполнены"
     view-as alert-box.
     return no-apply.
  end.
  if fCom    :screen-value in frame FRAME-B eq "Ethernet"
  then do:
     find first tt-asi_buf where tt-asi_buf.misc5 = fipasi      :screen-value in frame FRAME-B
                             and tt-asi_buf.misc6 = fportasi    :screen-value in frame FRAME-B
                             and recid (tt-asi_buf) ne recid(tt-asi)
                        no-lock no-error.
     if available tt-asi_buf
     then do:
        message "Уже есть запись с тип IP "  tt-asi.misc5 " Порт " tt-asi.misc6
        view-as alert-box.
        return no-apply.
     end.
  end.
  else do:
     find first tt-asi_buf where tt-asi_buf.parent = ftypeasi:screen-value in frame FRAME-B
                         and tt-asi_buf.code   = fCom    :screen-value in frame FRAME-B
                         and recid (tt-asi_buf) ne recid(tt-asi)
                         no-lock no-error.
     if available tt-asi_buf
     then do:
        message "Уже есть запись с тип АСИ "  tt-asi_buf.parent " Порт " tt-asi_buf.code
        view-as alert-box.
        return no-apply.
     end.
  end.
  if available tt-asi
  then do:
    for each tt-tank_buf where tt-tank_buf.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6:
         tt-tank_buf.parent = ftypeasi:screen-value in frame FRAME-B + chr(4)
                            + fCom    :screen-value in frame FRAME-B + chr(4)
                            + fipasi  :screen-value in frame FRAME-B + chr(4)
                            + fportasi:screen-value in frame FRAME-B
                            .
     end.
     assign
     tt-asi.Misc1 = ""
     tt-asi.Misc2 = ""
     tt-asi.Misc3 = ""
     tt-asi.misc8 = ""
     tt-asi.parent = ftypeasi:screen-value in frame FRAME-B
     tt-asi.code   = fCom    :screen-value in frame FRAME-B
     tt-asi.Misc1  = fspeed  :screen-value in frame FRAME-B when not fCom    :screen-value in frame FRAME-B eq "Ethernet"
     tt-asi.Misc2  = fchet   :screen-value in frame FRAME-B when not fCom    :screen-value in frame FRAME-B eq "Ethernet"
     tt-asi.Misc3  = fbit    :screen-value in frame FRAME-B when not fCom    :screen-value in frame FRAME-B eq "Ethernet"
     tt-asi.misc5  = fipasi  :screen-value in frame FRAME-B
     tt-asi.misc6  = fportasi:screen-value in frame FRAME-B
     tt-asi.misc7  = fSlaveId:screen-value in frame FRAME-B
     tt-asi.misc9  = TOut:screen-value in frame FRAME-B
     tt-asi.misc10   = (if ftypeasi:screen-value in frame FRAME-B = "Modbus"  then fSpec:screen-value in frame FRAME-B else "")
     .
     OPEN QUERY BROWSE-3 FOR EACH tt-asi NO-LOCK INDEXED-REPOSITION.
     apply  "VALUE-CHANGED" to BROWSE-3 in frame FRAME-B.
     OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
     apply  "VALUE-CHANGED" to BROWSE-5 in frame FRAME-C.
  end.
  else
     message "Нет записи АСИ"
     view-as alert-box.
end.
ON choose OF bt-edit-2 IN FRAME FRAME-C
do:
   define buffer tt-tank_buf for tt-tank.
  if     available tt-asi
     and available tt-tank
  then do:
     find first tt-tank_buf where tt-tank_buf.parent    eq tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6
                              and tt-tank_buf.code      eq Faddr:screen-value
                              and recid(tt-tank_buf)    ne recid(tt-tank)
     no-lock no-error.
     if available tt-tank_buf
     then
        message
        "Уже есть адрес " tt-tank_buf.code " для " tt-asi.parent tt-asi.code
        view-as alert-box.
     else do:
        FIND FIRST tt-tank_buf No-LOCK WHERE tt-tank_buf.CodeValue  = Fcoor:screen-value in frame FRAME-C
                                         and recid(tt-tank_buf)    ne recid(tt-tank) NO-ERROR.
        if available tt-tank_buf
        then
          message
             "Уже есть  " Fcoor:label tt-tank_buf.CodeValue " для " replace (tt-tank_buf.parent, chr(4)," ")
                view-as alert-box.
        else do:
           assign
              tt-tank.parent    = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6
              tt-tank.code      = Faddr:screen-value
              tt-tank.CodeValue = Fcoor:screen-value
              tt-tank.misc1  = fnompres:screen-value when ftypeasi    :screen-value in frame FRAME-B eq "kedr"
           .
           OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
           apply  "VALUE-CHANGED" to BROWSE-5 in frame FRAME-C.
        end.
     end.
  end.
end.
ON CHOOSE OF btloabfile IN FRAME Dialog-Frame
DO:
   define variable v-file-name as character no-undo.
   define variable vok as logical no-undo.
   system-dialog get-file v-file-name
            filters "Файлы реестра *.reg" "*.reg"
            title "Выберите файл списка"
            INITIAL-DIR "."
            return-to-start-dir
            must-exist
            update vok
            default-extension "cli".
   if  vok then do:
      run proc-load (v-file-name).
   end.
END.
ON choose OF Btload IN FRAME Dialog-Frame
do:
  run proc-load (?).
end.
ON choose OF Btn_OK IN FRAME Dialog-Frame
do:
  run proc-save (?).
end.
ON CHOOSE OF Bt_ok IN FRAME Dialog-Frame
DO:
  find first sys-ctrl.
  run db-attr-write(sys-ctrl.db,"AsiIp",fip:screen-value in frame frame-a).
  run db-attr-write(sys-ctrl.db,"AsiPort",FPort:screen-value in frame frame-a).
  run db-attr-write(sys-ctrl.db,"AsiType",ftype:screen-value in frame frame-a).
END.
ON CHOOSE OF BUTTON-2 IN FRAME FRAME-C
DO:
  define variable place-list as character no-undo .
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel"
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input 'объект':U
               , input-output place-list).
  if place-list = "cancel"
  then do :
    return no-apply .
  end .
  if place-list <> '':U then do:
     FIND FIRST ub.place No-LOCK WHERE recid(ub.place) = integer(entry(1, place-list)) NO-ERROR.
     if available ub.place
     then Fcoor:screen-value in frame FRAME-C = ub.place.loc1.
  end.
END.
ON value-changed OF fCom IN FRAME FRAME-B
do:
  assign fcom.
  if fcom:screen-value begins "com"
  then do :
      assign
         fspeed:visible     = yes.
         fchet:visible      = yes.
         fbit:visible       = yes.
         fportasi:screen-value = "".
         fipasi  :screen-value = "".
         fipasi:visible     = no.
         fportasi:visible   = no.
      .
  end.
  else if fcom:screen-value eq "usb"
  then do with frame FRAME-B:
      assign
         fspeed:visible = no
         fchet:visible  = no
         fbit:visible   = no
         fspeed:screen-value = ""
         fchet:screen-value = ""
         fbit:screen-value = ""
         fportasi:screen-value = ""
         fipasi  :screen-value = ""
         fipasi:visible     = no
         fportasi:visible   = no
      .
   end.
   else if fcom:screen-value eq "Ethernet"
  then do with frame FRAME-B:
      assign
         fportasi:screen-value = ""
         fipasi  :screen-value = ""
         fspeed:visible = no
         fchet:visible  = no
         fbit:visible   = no
         fipasi:visible     = yes
         fportasi:visible   = yes
      .
   end.
   else
    do with frame FRAME-B:
      assign
         fspeed:visible = no
         fchet:visible  = no
         fbit:visible   = no
         fspeed:screen-value = ""
         fchet:screen-value = ""
         fbit:screen-value = ""
         fipasi:visible     = no
         fportasi:visible   = no
      .
   end.
end.
ON value-changed OF ftypeasi IN FRAME FRAME-B
do:
  fCom:screen-value = "".
  fCom:visible   = no.
  fSlaveId:visible = no.
  fnompres:visible IN FRAME FRAME-C = ftypeasi:screen-value eq "kedr".
  assign ftypeasi.
  if    ftypeasi:screen-value eq "Modbus"
     or ftypeasi:screen-value eq "kedr"
     or ftypeasi:screen-value eq "Veeder-root"
  then do:
     assign
         fCom:visible     = yes
         fSlaveId:visible = ftypeasi:screen-value eq "Modbus"
     .
  end.
  else if    ftypeasi:screen-value eq "DOMS"
          or ftypeasi:screen-value eq "ifsfserver"
  then
     assign
         fCom:visible   = no
         fCom:screen-value = "Ethernet"
     .
   apply  "VALUE-CHANGED" to fCom in frame FRAME-B.
   if ftypeasi:screen-value = "Modbus" then do:
      fSpec:visible in frame FRAME-B = yes.
        if available tt-asi then fSpec:screen-value in frame FRAME-B = tt-asi.misc10.
  end.
  else do:
      fSpec:visible in frame FRAME-B = no.
      fSpec:screen-value in frame FRAME-B = "".
  end.
end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
  run enable_UI.
  find first sys-ctrl.
  define variable mtype-attr as character no-undo.
  define variable mvalue-attr as character no-undo.
  run db-attr-value(sys-ctrl.db,"AsiIp",output mvalue-attr,output mtype-attr).
  fip:screen-value in frame frame-a = mvalue-attr.
  run db-attr-value(sys-ctrl.db,"AsiPort",output mvalue-attr,output mtype-attr).
  FPort:screen-value in frame frame-a = mvalue-attr.
  fSpec:screen-value in frame frame-b = "99" .
  run db-attr-value(sys-ctrl.db,"AsiType",output mvalue-attr,output mtype-attr).
  ftype:screen-value in frame frame-a = mvalue-attr.
  apply  "value-changed" to ftypeasi IN FRAME FRAME-B.
  apply  "VALUE-CHANGED" to fCom in frame FRAME-B.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME FRAME-A.
  HIDE FRAME FRAME-B.
  HIDE FRAME FRAME-C.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_Cancel-2 Btn_OK Btload Bt_ok bsavefile btloabfile
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  DISPLAY fip ftype FPort tlive rfrtime
      WITH FRAME FRAME-A.
  ENABLE fip ftype FPort tlive rfrtime
      WITH FRAME FRAME-A.
  DISPLAY fip ftype FPort tlive rfrtime
      WITH FRAME FRAME-A.
  fSpec:visible in frame FRAME-B = no.
  ENABLE fip ftype FPort tlive rfrtime
      WITH FRAME FRAME-A.
  DISPLAY ftypeasi fipasi TOut fSpec
      WITH FRAME FRAME-B.
  ENABLE BROWSE-3 bt-add bt-del bt-edit ftypeasi fSlaveId fCom fchet fbit
         fportasi fspeed fipasi TOut fSpec
      WITH FRAME FRAME-B.
  OPEN QUERY BROWSE-3 FOR EACH tt-asi NO-LOCK INDEXED-REPOSITION.
  DISPLAY Faddr Fcoor fnompres
      WITH FRAME FRAME-C.
  ENABLE BROWSE-5 bt-add-2 bt-del-2 bt-edit-2 Faddr Fcoor BUTTON-2 fnompres
      WITH FRAME FRAME-C.
  OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-load :
define input  parameter iFile as character no-undo.
define variable vtxt as character no-undo.
define variable vip as character no-undo.
define variable vport as character no-undo.
define variable currentSection as character no-undo.
for each tt-asi_exp:
   delete tt-asi_exp.
end.
for each tt-tank_exp:
   delete tt-tank_exp.
end.
if iFile eq ? then do:
   iFile = "measurer_par_exp.reg".
   output to "measurer_par_exp.reg".
   output close.
   os-command silent value ("reg export HKEY_LOCAL_MACHINE\SOFTWARE\MEASURER_PAR " + search("measurer_par_exp.reg") + " /y /reg:" + (if is-ProcArch64 then "64" else "32") + " >> measurer_par_exp.rez 2>&1").
end.
input STREAM sReadfile FROM VALUE(iFile).
repeat:
   import stream sReadfile unformatted vtxt.
   vtxt = trim(vtxt).
   vtxt = replace (vtxt,'"','').
   if vtxt begins "[" then do:
      currentSection = vtxt.
      if vtxt eq "[HKEY_LOCAL_MACHINE\SOFTWARE\MEASURER_PAR]" then do:
         mObj = "head".
         next.
      end.
      else if vtxt eq "[HKEY_LOCAL_MACHINE\SOFTWARE\MEASURER_PAR\Modbus]" or
              vtxt eq "[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\MEASURER_PAR\Modbus]" then do:
         mObj = "modbus".
         next.
      end.
      else if vtxt begins "[HKEY_LOCAL_MACHINE\SOFTWARE\MEASURER_PAR\" then do:
         if index (vtxt,"TankTop") ne 0 then
            assign mObj = "tank".
         else
            assign
               mObj = "asi"
               vip = ""
               vport = "".
         vtxt = entry(4,vtxt,"\").
         mtypeasi = entry(1,vtxt," ") .
         assign
            MCom = entry(2,vtxt," ")
            MCom = trim(MCom,"]")
            no-error.
         if error-status:error then
            message "Ошибка загрузки данных из реестра" view-as alert-box.
         if MCom begins "Ethernet" then
            MCom = "Ethernet".
         if mObj = "asi" then do:
            create tt-asi_exp.
            assign
               tt-asi_exp.parent = mtypeasi
               tt-asi_exp.code = mcom
            .
            validate tt-asi_exp.
         end.
         next.
      end.
      else do:
         mObj = "".
         next.
      end.
   end.
   else if mObj ne "" then do:
      assign
         mteg = entry(1,vtxt,"=")
         mvalue = entry(2,vtxt,"=")
         no-error.
      if not error-status:error then do:
         if mObj = "head" then do:
            if mteg = "IP" then
               Fip:screen-value in frame frame-a = mvalue.
            else if mteg = "PORT" then
               FPort:screen-value = mvalue.
            else if mteg = "RefreshTime" then
               rfrtime:screen-value = mvalue.
            else if mteg = "TimeLive" then
               tlive:screen-value = mvalue.
            else if mteg = "TYPE" then
               ftype:screen-value = if mvalue eq ? or mvalue eq "?" then "1" else mvalue.
         end.
         else if mObj = "asi" then do:
            if mteg = "TimeOut" then
               tt-asi_exp.misc9 = mvalue.
            else if mteg = "PORT_NUM" then
               tt-asi_exp.code = "COM" + mvalue.
            else if mteg = "Baud" then
               tt-asi_exp.misc1 = mvalue.
            else if mteg = "Parity" then
               tt-asi_exp.misc2 = mvalue.
            else if mteg = "Databits" then
               tt-asi_exp.misc3 = mvalue.
            else if mteg = "License" then
               tt-asi_exp.misc4 = mvalue.
            else if mteg = "ip" then do:
               vip = mvalue.
               tt-asi_exp.misc5 = mvalue.
            end.
            else if mteg = "Port" then assign
               vport = mvalue
               tt-asi_exp.misc6 = mvalue.
            else if mteg = "SlaveId" then
               tt-asi_exp.misc7 = mvalue.
            else  if mteg = "Spec" then do:
               tt-asi_exp.misc10 = mvalue.
            end.
         end.
         else if mObj = "tank" then do:
            if mteg begins "ID_" then do:
               create tt-tank_exp.
               assign
                  tt-tank_exp.parent = mtypeasi + chr(4) + mcom + chr(4) + Vip + chr(4) + vport
                  tt-tank_exp.code = substring(mteg,4)
                  tt-tank_exp.CodeValue = entry(1,mvalue,":")
                  tt-tank_exp.misc1 = entry(2,mvalue,":")
                  no-error.
            end.
         end.
      end.
   end.
end.
input stream sReadfile close.
OPEN QUERY BROWSE-3 FOR EACH tt-asi NO-LOCK INDEXED-REPOSITION.
apply "VALUE-CHANGED" to BROWSE-3 in frame FRAME-B.
OPEN QUERY BROWSE-5 FOR EACH tt-tank       WHERE tt-tank.parent = tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 NO-LOCK INDEXED-REPOSITION.
apply "VALUE-CHANGED" to BROWSE-5 in frame FRAME-C.
end procedure.
PROCEDURE proc-save :
define input  parameter iFile as character no-undo.
define variable vhead as character no-undo.
define buffer tt-asi for tt-asi.
define buffer tt-tank for tt-tank.
define variable vi as integer no-undo.
output to value(if iFile ne ? then iFile else "measurer_par_imp.reg").
do with frame FRAME-A:
   put unformatted  "Windows Registry Editor Version 5.00" skip.
   put unformatted  "[HKEY_LOCAL_MACHINE\SOFTWARE\MEASURER_PAR]" skip
   substitute('"IP"="&1"',       Fip:screen-value   ) skip
   substitute('"PORT"="&1"',     Fport:screen-value ) skip.
   put unformatted
   substitute('"TYPE"="&1"',     ftype:screen-value ) skip
   substitute('"CodePage"="&1"', "1251"             ) skip(1).
   if tlive:screen-value  ne "" and tlive:screen-value  ne ?    then  put unformatted  substitute('"TimeLive"="&1"', tlive:screen-value) skip .
   if rfrtime:screen-value  ne "" and rfrtime:screen-value  ne ?    then  put unformatted  substitute('"RefreshTime"="&1"', rfrtime:screen-value) skip .
end.
for each tt-asi:
   if tt-asi.code begins "Ethernet"
   then
      vi = vi + 1.
   vhead = substitute("[HKEY_LOCAL_MACHINE\SOFTWARE\MEASURER_PAR\&1 &2&3" ,
                      tt-asi.parent ,
                      ( tt-asi.code),
                      if tt-asi.code begins "Ethernet" then string(vi) else "") .
   put unformatted vhead + "]" skip.
   if tt-asi.misc9 ne "" and tt-asi.misc9 ne ?
   then
      put unformatted substitute('"TimeOut"="&1"', tt-asi.misc9 ) skip(1).
   if tt-asi.code begins "com"
   then
      put unformatted substitute('"PORT_NUM"="&1"', substring(tt-asi.code,4)              ) skip
                      substitute('"Baud"="&1"'    , tt-asi.misc1                          ) skip
                      substitute('"Parity"="&1"'  , (if tt-asi.misc2 eq "3" then "NONE" else tt-asi.misc2)) skip
                      substitute('"Databits"="&1"', tt-asi.misc3                          ) skip.
   if tt-asi.code begins "Ethernet"
   then
       put unformatted substitute('"ip"="&1"', tt-asi.misc5       ) skip
                      substitute('"Port"="&1"'    , tt-asi.misc6  ) skip  .
   if tt-asi.misc10 ne "" then put unformatted substitute('"Spec"="&1"', tt-asi.misc10) skip.
   put unformatted substitute('"SlaveId"="&1"', tt-asi.misc7  ) skip.
   if tt-asi.misc4 ne "" and tt-asi.misc4 ne ?
   then
      put unformatted substitute('"License"="&1"', tt-asi.misc4 ) skip(1).
   if tt-asi.misc8 ne "" and tt-asi.misc8 ne ?
   then
      put unformatted substitute('"PRES_SENSOR_NUM"="&1"', tt-asi.misc8 ) skip(1).
   put unformatted vhead + "\TankTop]" skip.
   for each tt-tank where tt-tank.parent eq tt-asi.parent + chr(4) + tt-asi.code + chr(4) + tt-asi.misc5 + chr(4) + tt-asi.misc6 :
       if tt-tank.misc1 eq ""
       then
          put unformatted substitute('"ID_&1"="&2"',tt-tank.code, tt-tank.CodeValue) skip.
       else
          put unformatted substitute('"ID_&1"="&2:&3"',tt-tank.code, tt-tank.CodeValue, tt-tank.misc1) skip.
   end.
   put unformatted skip(1).
end.
  output close.
  if iFile eq ?
  then do:
     run trg/userlog.p (
                  input 'MEASURER_PAR'
                , input ("Запущено сохранение настроек для АСИ в реестр"  + chr(3) + userid("ub"))
                , input ?
                , input ?
                , input "") no-error.
     os-command silent value ("reg delete HKEY_LOCAL_MACHINE\SOFTWARE\MEASURER_PAR /f /reg:" + (if is-ProcArch64 then "64" else "32") + " > measurer_par_del.rez 2>&1").
     os-command silent value ("reg import " + search("measurer_par_imp.reg")      + " /reg:" + (if is-ProcArch64 then "64" else "32") + " > measurer_par_imp.rez 2>&1").
     define variable vtxt as character no-undo.
     input STREAM sReadfile FROM  VALUE("measurer_par_imp.rez") CONVERT TARGET  "1251" source 'ibm866'.
     import stream sReadfile unformatted vtxt.
     input close.
     message vtxt
     view-as alert-box.
  end.
end procedure.
