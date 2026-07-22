DEFINE INPUT PARAMETER vattaxcd as integer no-undo.
DEFINE INPUT PARAMETER slttaxcd as integer no-undo.
DEFINE OUTPUT PARAMETER v_os-file   AS CHAR NO-UNDO INIT "".
DEFINE OUTPUT PARAMETER choice      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-artic     AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-name      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-engl-name AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-unit-base AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-VAT-code  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-SLT-code  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-struct      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-11      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-22      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-33      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-44      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-city      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-grp      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-gds-prt      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-client      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER  line     AS integer NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Параметры файла альтернативного импорта товаров" .
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
DEFINE stream gds-file.
define temp-table temp_grplib_found-grp no-undo
    field full-name  as character
    field node-code  as integer
    field level      as integer
    index pi is primary unique full-name
    index lv level
.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл импорта"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE RS-codir AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "1251", 1,
"KOI8-R", 2
     SIZE 15.25 BY 2.63 NO-UNDO.
DEFINE RECTANGLE RECT-atribut
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.63 BY 12.83.
DEFINE VARIABLE T-11 AS LOGICAL INITIAL no
     LABEL "Назначение товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-22 AS LOGICAL INITIAL no
     LABEL "Характеристики товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-33 AS LOGICAL INITIAL no
     LABEL "Правила эксплуатации"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-44 AS LOGICAL INITIAL no
     LABEL "Сертификат товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-artic AS LOGICAL INITIAL yes
     LABEL "Артикул"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE T-city AS LOGICAL INITIAL no
     LABEL "Страна"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-client AS LOGICAL INITIAL no
     LABEL "Производитель"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-engl-name AS LOGICAL INITIAL no
     LABEL "Англ. название"
     VIEW-AS TOGGLE-BOX
     SIZE 17.63 BY 1 NO-UNDO.
DEFINE VARIABLE T-gds-prt AS LOGICAL INITIAL no
     LABEL "Шкала"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-grp AS LOGICAL INITIAL no
     LABEL "Группа товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-name AS LOGICAL INITIAL yes
     LABEL "Название"
     VIEW-AS TOGGLE-BOX
     SIZE 17.75 BY 1 NO-UNDO.
DEFINE VARIABLE T-SLT-code AS LOGICAL INITIAL no
     LABEL "Код НП"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-struct AS LOGICAL INITIAL no
     LABEL "Состав сырья"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-unit-base AS LOGICAL INITIAL no
     LABEL "Основная единица измерения"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-VAT-code AS LOGICAL INITIAL no
     LABEL "Код НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-file AT ROW 2.88 COL 43.13
     file-name AT ROW 2.92 COL 3.38
     T-artic AT ROW 5 COL 24.5
     RS-codir AT ROW 5.38 COL 3.38 NO-LABEL
     T-name AT ROW 5.79 COL 24.5
     T-engl-name AT ROW 6.58 COL 24.5
     T-unit-base AT ROW 7.42 COL 24.5
     T-VAT-code AT ROW 8.21 COL 24.5
     T-SLT-code AT ROW 9 COL 24.5
     T-struct AT ROW 9.79 COL 24.5
     T-11 AT ROW 10.58 COL 24.5
     T-22 AT ROW 11.42 COL 24.5
     T-33 AT ROW 12.21 COL 24.5
     T-44 AT ROW 13 COL 24.5
     T-city AT ROW 13.79 COL 24.5
     T-grp AT ROW 14.58 COL 24.5
     T-gds-prt AT ROW 15.42 COL 24.5
     T-client AT ROW 16.21 COL 24.5
     RECT-atribut AT ROW 4.42 COL 24
     "Кодировка" VIEW-AS TEXT
          SIZE 15.75 BY .92 AT ROW 4.21 COL 3.38
     "Импортируемые поля" VIEW-AS TEXT
          SIZE 19.25 BY .88 AT ROW 4 COL 26.25
          FGCOLOR 3
     SPACE(10.37) SKIP(12.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры файла импорта"
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
  define variable NEN as integer No-UNDO.
  define variable vars as integer no-undo EXTENT 15.
  assign
  file-name
  v_os-file = file-name
  RS-codir
  choice = RS-codir
  T-artic
  T-name
  T-engl-name
  T-unit-base
  T-VAT-code
  T-SLT-code
  T-struct
  T-11
  T-22
  T-33
  T-44
  T-city
  T-grp
  T-gds-prt
  T-client
  NEN = NEN + integer(T-artic)
  vars[1] = NEN
  p-artic = vars[1]
  NEN = NEN + integer(T-name)
  vars[2] = if T-name then NEN else 0
  p-name = vars[2]
  NEN = NEN + integer(T-engl-name)
  vars[3] = if T-engl-name then NEN else 0
  p-engl-name = vars[3]
  NEN = NEN + integer(T-unit-base)
  vars[4] = if T-unit-base then NEN else 0
  p-unit-base = vars[4]
  NEN = NEN + integer(T-VAT-code)
  vars[5] = if T-VAT-code then NEN else 0
  p-VAT-code = vars[5]
  NEN = NEN + integer(T-SLT-code)
  vars[6] = if T-SLT-code then NEN else 0
  p-SLT-code = vars[6]
  NEN = NEN + integer(T-Struct)
  vars[7] = if T-Struct then NEN else 0
  p-Struct = vars[7]
  NEN = NEN + integer(T-11)
  vars[8] = if T-11 then NEN else 0
  p-grp = vars[8]
  NEN = NEN + integer(T-22)
  vars[9] = if T-22 then NEN else 0
  p-grp = vars[9]
  NEN = NEN + integer(T-33)
  vars[10] = if T-33 then NEN else 0
  p-grp = vars[10]
  NEN = NEN + integer(T-44)
  vars[11] = if T-44 then NEN else 0
  p-grp = vars[11]
  NEN = NEN + integer(T-city)
  vars[12] = if T-city then NEN else 0
  p-city = vars[12]
  NEN = NEN + integer(T-grp)
  vars[13] = if T-grp then NEN else 0
  p-grp = vars[13]
  NEN = NEN + integer(T-gds-prt)
  vars[14] = if T-gds-prt then NEN else 0
  p-gds-prt = vars[14]
  NEN = NEN + integer(T-client)
  vars[15] = if T-client then NEN else 0
  p-client = vars[15]
  .
  IF v_os-file = "" or v_os-file = ? then do:
    message "Не определен файл импорта!" view-as alert-box ERROR.
    return no-apply.
  END.
  IF (T-SLT-code OR T-VAt-code) AND NOT T-unit-base then do:
    message "Невозможно импортировать код НДС и/или код НП" SKIP
            "без импорта основной единицы измерения" view-as alert-box ERROR.
    return no-apply.
  end.
  line = NEN.
  CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (v_os-file) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (v_os-file) convert source "KOI8-R".
        END.
  END CASE.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
    define variable ll_commit AS LOG    NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
          " Текстовые файлы (*.gim) " "*.gim",
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        return-to-start-dir
        must-exist
        update ll_commit
        default-extension "gim"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    assign v_os-file = "".
END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO file-name IN FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY file-name T-artic RS-codir T-name T-engl-name T-unit-base T-VAT-code
          T-SLT-code T-struct T-11 T-22 T-33 T-44 T-city T-grp T-gds-prt
          T-client
      WITH FRAME Dialog-Frame.
  ENABLE RECT-atribut B-exit b-quit B-file file-name RS-codir T-engl-name
         T-unit-base T-VAT-code T-SLT-code T-struct T-11 T-22 T-33 T-44 T-city
         T-grp T-gds-prt T-client
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-node-code :
define input parameter p-search-name  as character    no-undo.
define output parameter cod-grp  like gds-grp.node-code no-undo.
define var p-fill-path    as logical      no-undo.
define variable v-upper-code    as integer          no-undo.
define variable v-not-found     as logical init yes no-undo.
define variable v-counter       as integer           no-undo.
define variable v-level         as integer           no-undo.
define variable v-full-name     as character         no-undo.
define buffer buf_gds-grp       for gds-grp.
run grplib-get-root-code ( output v-upper-code ) no-error .
if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
end.
assign
    v-full-name  = ""
    v-level      = num-entries( p-search-name, chr(47) ) .
for each temp_grplib_found-grp    :
    delete temp_grplib_found-grp.
end.
start-name-analyze:
do v-counter = 1 to v-level :
    if v-counter < v-level  then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(47) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(47) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + (if v-full-name = "" then "" else chr(47)) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
    end.
    else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(47) )
            :
                assign
                    v-not-found = no
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47))
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(47) ).
            end.
    end.
end.
for each temp_grplib_found-grp no-lock:
  cod-grp =  temp_grplib_found-grp.node-code.
end.
END PROCEDURE.
PROCEDURE grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
define buffer buf_gds-grp       for gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
END PROCEDURE.
