define input parameter PictName as char no-undo .
DEFINE INPUT PARAMETER p-extension AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER bttn AS CHARACTER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр картинки".
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
define variable stat as log no-undo .
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-descriptions as character no-undo .
define variable v-extensiond   as character no-undo .
define variable v-extensiont   as character no-undo .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1.
DEFINE BUTTON B-update
     LABEL "&Изменить"
     SIZE 10.5 BY 1.
DEFINE BUTTON Btn_Close AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
      VIEW-AS TEXT
     SIZE 35.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE IMAGE-1
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 65.8 BY 16.77.
DEFINE FRAME DLGCLOSE
     Btn_Close AT ROW 1 COL 1
     B-update AT ROW 1 COL 29
     b-help AT ROW 1 COL 57 WIDGET-ID 2
     FILL-IN-1 AT ROW 2.27 COL 15.5 COLON-ALIGNED
     IMAGE-1 AT ROW 3.77 COL 1
     SPACE(0.57) SKIP(0.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE BGCOLOR 8 "":L
         DEFAULT-BUTTON Btn_Close.
ASSIGN
       FRAME DLGCLOSE:SCROLLABLE       = FALSE
       FRAME DLGCLOSE:PRIVATE-DATA     =
                "DLGCLOSE".
ASSIGN
       Btn_Close:PRIVATE-DATA IN FRAME DLGCLOSE     =
                "Btn_Close".
ASSIGN
       IMAGE-1:RESIZABLE IN FRAME DLGCLOSE        = TRUE.
ON CHOOSE OF B-update IN FRAME DLGCLOSE
DO:
  DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
  DEFINE VARIABLE stat-chr AS CHARACTER NO-UNDO.
  DEFINE VARIABLE stat AS logical NO-UNDO.
  assign
  fill-in-1.
  run ref/photo-n.w ( input fill-in-1, input 'ИЗМЕНЕНИЕ':U ) .
  IF RETURN-VALUE = "error" THEN RETURN NO-APPLY.
  assign
  stat-chr = search( return-value  )
  .
  if stat-chr = ? then do:
    return no-apply.
  end.
  fill-in-1 = stat-chr.
  stat = image-1:load-image("cmp/MATRIX-RELOADED.jpg") .
  stat = image-1:load-image( return-value ) .
  DISPLAY
  image-1
  fill-in-1
  WITH FRAME DLGCLOSE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGCLOSE:PARENT eq ?
THEN FRAME DLGCLOSE:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME DLGCLOSE APPLY "END-ERROR":U TO SELF.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGCLOSE
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
on choose of b-help in frame DLGCLOSE
do:
  apply "help":u to frame DLGCLOSE .
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
                v-frame-width = frame DLGCLOSE:width - 0.3
                fh            = frame DLGCLOSE:first-child
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
    if error-status:error
    or v-image-order = '':U then
    v-image-order = "jpg,bmp".
    run get-custom-img-order IN THIS-PROCEDURE(OUTPUT v-descriptions, OUTPUT v-extensiond, OUTPUT v-extensiont).
    stat = image-1:load-image( PictName + ".":U + p-extension) .
    FILL-IN-1 = PictName + ".":U + p-extension .
    run enable_UI in this-procedure .
    IF LOOKUP("b-update", bttn) = 0 THEN DO:
        DISABLE
        b-update
        WITH FRAME DLGCLOSE.
    END.
    WAIT-FOR GO OF FRAME DLGCLOSE.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME DLGCLOSE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-1
      WITH FRAME DLGCLOSE.
  ENABLE Btn_Close IMAGE-1 B-update b-help FILL-IN-1
      WITH FRAME DLGCLOSE.
END PROCEDURE.
