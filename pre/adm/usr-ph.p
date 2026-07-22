block-level on error undo, throw.
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-user-id      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usr-ph.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/usr-ph.p $":U .
define variable vss-description as character no-undo init "Показать изображение клиента".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable loc#log    as logical   no-undo .
define variable v-can-edit as logical no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rights_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-can-edit
    )  .
end.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable stat                 as character no-undo .
define variable Path-To-Dir-Pictures as character no-undo .
define variable Path-To-Pictures     as character no-undo .
define variable v-ii                 as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do:
  RUN verify-ini-entry("pict_path":U,
                        "REP-SETS":U,
                        "не определен путь к подкаталогу для хранения фото товара" + chr(10) +
                        "отсутствует параметр pict_path, секция [REP-SETS] ini-файла",
                        no,
                        output Path-To-Dir-Pictures) no-error.
  if error-status:error or Path-To-Dir-Pictures = ? then return error.
  RUN verify-file(Path-To-Dir-Pictures,
                  "Не найден каталог " + Path-To-Dir-Pictures + chr(10) +
                  "параметр pict_path, секция [REP-SETS] ini-файла",
                  no,
                  output loc#log) no-error.
  if error-status:error or not loc#log then return error.
  RUN verify-file((Path-To-Dir-Pictures + "usr\"),
                  "Не найден подкаталог " + Path-To-Dir-Pictures + "usr\",
                  no,
                  output loc#log) no-error.
  if error-status:error or not loc#log then return error.
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
   assign
   Path-To-Pictures = Path-To-Dir-Pictures + "usr\" + string( p-user-id )
   .
  if length( Path-To-Pictures ) > 56 then do:
    message
      "Слишком длинное имя файла ( с учетом полного пути )."
      view-as alert-box error .
  end.
  do v-ii = 1 to num-entries(v-image-order):
    assign
      stat = search( Path-To-Pictures  + "." + entry(v-ii, v-image-order) )
    .
    if stat <> ? then leave.
  end.
  if stat <> ? then do:
    run ref/view-pic.w ( Path-To-Pictures, entry(v-ii, v-image-order), if v-can-edit then "b-update" else "":U ) .
  end.
  else do:
    if not v-can-edit then do:
      message
      "Изображение отсутствует"
      view-as alert-box .
      RETURN.
    end.
    run ref/photo-n.w ( Path-To-Pictures, 'ДОБАВЛЕНИЕ':U  ) .
  end.
end.
