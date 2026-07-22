define INPUT parameter PictName as char no-undo .
define INPUT parameter p-mode as char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отсутствие фото товара".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define NEW shared variable RepPathName        as character no-undo .
define NEW shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-image-order      AS CHARACTER NO-UNDO INIT "jpg,bmp":U.
define variable v-image-format     as character extent 62 init
[
 "Windows bitmap                                                          ", "*.bmp"
,"Computer-aided Acquisition and Logistics Support                        ", "*.cal"
,"Microsoft Windows Clipboard                                             ", "*.clp"
,"Halo CUT                                                                ", "*.cut"
,"Intel FAX format                                                        ", "*.dcx"
,"Windows device-independent bitmap                                       ", "*.dib"
,"Encapsulated PostScript                                                 ", "*.eps"
,"1 Graphics Interchange Format                                           ", "*.gif"
,"IBM IOCA                                                                ", "*.ica"
,"Microsoft Icon File format                                              ", "*.ico"
,"Amiga IFF                                                               ", "*.iff"
,"GEM bitmap                                                              ", "*.img"
,"Joint Bi-level Image Experts Group                                      ", "*.jbig"
,"JPEG                                                                    ", "*.jpg"
,"serView                                                                 ", "*.lv "
,"Macintosh MacPaint                                                      ", "*.mac"
,"Microsoft Windows Paint                                                 ", "*.msp"
,"Kodak Photo CD                                                          ", "*.pcd"
,"Macintosh PICT                                                          ", "*.pct"
,"PC Paintbrush                                                           ", "*.pcx"
,"GIF (Graphics Interchange Format) replacement                           ", "*.png"
,"Adobe Photoshop                                                         ", "*.psd"
,"Sun Raster (1-, 8-, 24-, or 32-bit Standard, BGR, RGB, and byte encoded)", "*.ras"
,"TARGA                                                                   ", "*.tga"
,"Tag image file format                                                   ", "*.tif"
,"Windows bitmap for wireless devices                                     ", "*.wbmp"
,"Windows metafiles                                                       ", "*.wmf"
,"WordPerfect graphics                                                    ", "*.wpg"
,"(also .bm) X bitmap                                                     ", "*.xbm"
,"Pixmap                                                                  ", "*.xpm"
,"UNIX X Window Dump File format                                          ", "*.xwd"
] no-undo.
procedure get-custom-img-order :
define output parameter p-descriptions as character no-undo .
define output parameter p-extensiond   as character no-undo .
define output parameter p-extensiont   as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as integer no-undo .
  do
  on error undo, return error
  :
    assign
    p-descriptions = fill(chr(4), 30)
    p-extensiond   = fill(chr(4), 30)
    p-extensiont   = fill(chr(4), 30)
    .
    do ii = 2 to 62 by 2:
      assign
      v-entry = lookup(left-trim(v-image-format[ii], ".*"), v-image-order)
      .
      if v-entry > 0 then do:
        assign
        entry(v-entry, p-descriptions, chr(4)) = substitute("&1 &2", trim(v-image-format[ii - 1]), v-image-format[ii])
        entry(v-entry, p-extensiond, chr(4)) = v-image-format[ii]
        entry(v-entry, p-extensiont, chr(4)) = left-trim(v-image-format[ii], ".*")
        .
      end.
    end.
    assign
    p-descriptions = trim(p-descriptions, chr(4))
    p-extensiond   = trim(p-extensiond, chr(4))
    p-extensiont   = trim(p-extensiont, chr(4))
    p-descriptions = replace(p-descriptions, (chr(4) + chr(4)), chr(4))
    p-extensiond   = replace(p-extensiond, (chr(4) + chr(4)),  chr(4))
    p-extensiont   = replace(p-extensiont, (chr(4) + chr(4)), chr(4))
    .
  end.
end procedure.
define variable v-descriptions as character no-undo .
define variable v-extensiond   as character no-undo .
define variable v-extensiont   as character no-undo .
DEFINE VARIABLE v-old-file     AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "no"
     SIZE 3 BY 1.
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE F-image-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 78 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY .67 NO-UNDO.
DEFINE IMAGE IMAGE-new
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 28.5 BY 7.25.
DEFINE FRAME DLGOKCAN
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 41.5
     B-file AT ROW 7 COL 80.5
     F-image-name AT ROW 4 COL 3 NO-LABEL
     file-name AT ROW 7 COL 2 NO-LABEL
     "и соотв. расширением (.bmp, .jpg и т.д.) - кнопка ОТМЕНА" VIEW-AS TEXT
          SIZE 72.5 BY 1 AT ROW 5 COL 6
     "ИЛИ" VIEW-AS TEXT
          SIZE 5.5 BY 1 AT ROW 6 COL 3
          FGCOLOR 4
     "Если Вы сейчас вводите изображение, Вам следует сохранить его в файле с именем" VIEW-AS TEXT
          SIZE 82.5 BY 1 AT ROW 3 COL 3.5
     "выбрать уже имеющийся у Вас файл изображения для копирования - кнопка ENTER" VIEW-AS TEXT
          SIZE 76 BY 1 AT ROW 6 COL 8.5
     IMAGE-new AT ROW 8.75 COL 2.5
     SPACE(54.99) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE BGCOLOR 8 FGCOLOR 1 "":L
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.
ASSIGN
       file-name:READ-ONLY IN FRAME DLGOKCAN        = TRUE.
ON CHOOSE OF B-exit IN FRAME DLGOKCAN
DO:
  DEFINE VARIABLE err-status AS INTEGER NO-UNDO.
  DEFINE VARIABLE err-name AS character NO-UNDO.
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
  define variable v-file-directory   as character no-undo .
  define variable vo-full-path        as character no-undo .
  define variable vo-path             as character no-undo .
  define variable vo-file-name        as character no-undo .
  define variable vo-file-name-no-ext as character no-undo .
  define variable vo-file-name-ext    as character no-undo .
  define variable vo-file-directory   as character no-undo .
  assign
  file-name.
  if file-name = '':U then do:
    message
    "Не задан файл"
    view-as alert-box error .
    return no-apply.
  end.
run gbl/filename.p (
                    input  FILE-NAME
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
if error-status:error then do:
  message
  substitute("Отсутствует или не найден файл &1", file-name)
  view-as alert-box error .
  return no-apply.
end.
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
    run gbl/filename.p (
                        input  v-old-file
                        ,output vo-full-path
                        ,output vo-path
                        ,output vo-file-name
                        ,output vo-file-name-no-ext
                        ,output vo-file-name-ext
                        ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
      IF v-full-path <> vo-full-path THEN DO:
          OS-DELETE VALUE(vo-full-path).
          err-status = OS-ERROR.
          IF err-status <> 0 THEN DO:
            run gbl/os-errnm.p (INPUT err-status, OUTPUT err-name).
            MESSAGE substitute("Ошибка при удалении старого файла изображения &1:&2&3"
                                , vo-full-path
                               , chr(10)
                                , err-name) VIEW-AS ALERT-BOX.
            RETURN NO-APPLY.
          END.
      END.
  END.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    OS-COPY VALUE(FILE-NAME) VALUE(Pictname + "." + v-file-name-ext).
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    OS-COPY VALUE(FILE-NAME) VALUE(vo-path + chr(47) + vo-file-name-no-ext + "." + v-file-name-ext ).
  end.
    err-status = OS-ERROR.
  IF err-status <> 0 THEN DO:
    run gbl/os-errnm.p (INPUT err-status, OUTPUT err-name).
  END.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    RETURN (Pictname + ("." + v-file-name-ext) ).
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    RETURN (vo-path + chr(47) + vo-file-name-no-ext + "." + v-file-name-ext ) .
  end.
END.
ON CHOOSE OF B-file IN FRAME DLGOKCAN
DO:
DEFINE VARIABLE v_os-file   AS CHAR NO-UNDO INIT "".
DEFINE VARIABLE ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-file-directory   as character no-undo .
define variable v-choose           as LOGICAL   no-undo .
define variable stat               as LOGICAL   no-undo .
ASSIGN
FILE-NAME
v_os-file = FILE-NAME
.
run gbl/d-file.p (
 input-output v_os-file
,input-output v-file-directory
,input        v-descriptions
,input        v-extensiond
,input        chr(4)
,input        v-extensiont
,input        YES
,input        NO
,input        yes
,input        "Введите имя файла изображения"
,output       v-choose
).
IF v-choose <> YES THEN do:
       RETURN NO-APPLY.
end.
ASSIGN
file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) )
.
run gbl/filename.p (
                    input  v_os-file
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
if error-status:error  = ? then do:
  return no-apply.
end.
assign
file-name = v-full-path.
DISPLAY
file-name WITH FRAME DLGOKCAN.
stat = image-new:load-image( FILE-NAME) .
END.
ON CHOOSE OF B-quit IN FRAME DLGOKCAN
DO:
  RETURN "error".
END.
ON LEAVE OF file-name IN FRAME DLGOKCAN
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME DLGOKCAN.
    END.
    APPLY "TAB":U TO file-name IN FRAME DLGOKCAN.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run adm/shattri.p (
      input "get":U
      ,input  ''
      ,input  0
      ,input  'images':U
      ,input  'imgorder':U
      ,output v-image-order
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  delete object v-tth.
  RUN get-custom-img-order IN THIS-PROCEDURE(OUTPUT v-descriptions, OUTPUT v-extensiond, OUTPUT v-extensiont).
  RUN Myenable.
  WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY F-image-name file-name
      WITH FRAME DLGOKCAN.
  ENABLE B-exit IMAGE-new B-quit b-help B-file F-image-name
      WITH FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE MyEnable :
define variable stat AS LOGICAL NO-UNDO.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    F-image-name = PictName  + ".???".
END.
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
    v-old-file = PictName.
    F-image-name = PictName.
    stat = image-new:load-image( PictName)  IN FRAME DLGOKCAN.
    DISPLAY image-new
    WITH FRAME DLGOKCAN.
END.
DISPLAY
F-image-name
file-name
WITH FRAME DLGOKCAN.
ENABLE
B-exit
image-new
B-quit
b-help
B-file
F-image-name
WITH FRAME DLGOKCAN.
END PROCEDURE.
