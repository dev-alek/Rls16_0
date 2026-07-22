CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вызов программы сравнения директорий *.r кодов".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_testXML-node no-undo
    field xmh-key       as integer
    field xmhNodName    as character
    index pi is primary unique
        xmh-key
    index nnm
        xmhNodName
.
define temp-table temp_testXML-entity no-undo
    field xme-key       as integer
    field xmh-key       as integer
    field xmeEntName    as character
    field xmeEntValue   as character
    index pi is primary unique
        xme-key
    index enm
        xmh-key
        xmeEntName
.
define temp-table temp_testXML-atribut no-undo
    field xme-key       as integer
    field xmeAtrName    as character
    field xmeAtrValue   as character
    index pi is primary unique
        xme-key
        xmeAtrName
.
define variable mRoot  as character no-undo init "Root".
define stream xmldom-out.
define variable mverfile_text as character   no-undo.
define variable mverfile      as integer  no-undo.
define variable v-xmldom-key       as integer      no-undo.
  define variable mTransaction  as logical no-undo init yes.
procedure xmldom-clear :
    define buffer buf_temp_testXML-node         for temp_testXML-node.
    define buffer buf_temp_testXML-entity       for temp_testXML-entity.
    define buffer buf_temp_testXML-atribut      for temp_testXML-atribut.
do
for buf_temp_testXML-node
  , buf_temp_testXML-entity
  , buf_temp_testXML-atribut
on error undo, return error
:
    empty temp-table buf_temp_testXML-node   .
    empty temp-table buf_temp_testXML-entity .
    empty temp-table buf_temp_testXML-atribut.
    assign
        v-xmldom-key = 0
        mTransaction = yes
    .
end.
end .
procedure xmldom-add :
define input parameter p-node-name      as character        no-undo.
define input parameter p-entity-name    as character        no-undo.
define input parameter p-entity-value   as character        no-undo.
    define buffer buf_temp_testXML-node         for temp_testXML-node.
    define buffer buf_temp_testXML-entity       for temp_testXML-entity.
do
for buf_temp_testXML-node
  , buf_temp_testXML-entity
on error undo, return error
:
    find last buf_temp_testXML-node
    use-index pi no-error.
    if not available buf_temp_testXML-node
    then do:
        assign
            v-xmldom-key = 0
        .
    end.
    else do:
        assign
            v-xmldom-key = buf_temp_testXML-node.xmh-key
        .
    end.
    find last buf_temp_testXML-entity
    use-index pi
    no-error.
    if available buf_temp_testXML-entity
    then do:
        assign
            v-xmldom-key = max(v-xmldom-key,buf_temp_testXML-entity.xme-key)
        .
    end.
    find first buf_temp_testXML-node
         where buf_temp_testXML-node.xmhNodName = p-node-name
    no-error.
    if not available buf_temp_testXML-node
    then do:
        assign
            v-xmldom-key = v-xmldom-key + 1
        .
        create buf_temp_testXML-node.
        assign
            buf_temp_testXML-node.xmh-key    = v-xmldom-key
            buf_temp_testXML-node.xmhNodName = p-node-name
        .
    end.
    assign
        v-xmldom-key = v-xmldom-key + 1
    .
    create buf_temp_testXML-entity.
    assign
        buf_temp_testXML-entity.xme-key      = v-xmldom-key
        buf_temp_testXML-entity.xmh-key      = buf_temp_testXML-node.xmh-key
        buf_temp_testXML-entity.xmeEntName   = p-entity-name
        buf_temp_testXML-entity.xmeEntValue  = p-entity-value
    .
end.
end.
function  xmldom-save-next-level  returns character
   ( iKey         as integer,
   i-doc-handle as handle,
   i-row-handle as handle):
   define buffer buf_temp_testXML-entity       for temp_testXML-entity.
   define buffer temp_testXML-atribut          for temp_testXML-atribut.
   define variable v-field-handle  as handle           no-undo.
   define variable v-text-handle   as handle           no-undo.
   create x-noderef v-field-handle.
   create x-noderef v-text-handle.
   for each buf_temp_testXML-entity
      where buf_temp_testXML-entity.xmh-key = iKey
        and not buf_temp_testXML-entity.xmeEntName begins "#"
   on error undo, return error:
      i-doc-handle :create-node ( v-field-handle, buf_temp_testXML-entity.xmeEntName , "ELEMENT" ).
      for each temp_testXML-atribut where temp_testXML-atribut.xme-key eq buf_temp_testXML-entity.xme-key
      no-lock:
         v-field-handle:SET-ATTRIBUTE(temp_testXML-atribut.xmeatrName,temp_testXML-atribut.xmeAtrValue).
      end.
      i-row-handle :append-child ( v-field-handle ).
      i-doc-handle :create-node ( v-text-handle, buf_temp_testXML-entity.xmeEntValue, "TEXT" ).
      v-field-handle :append-child ( v-text-handle ).
      if buf_temp_testXML-entity.xmeEntValue eq ?  then buf_temp_testXML-entity.xmeEntValue = "unknown_value".
      v-text-handle :node-value = buf_temp_testXML-entity.xmeEntValue.
     xmldom-save-next-level(buf_temp_testXML-entity.xme-key, i-doc-handle,v-field-handle).
   end.
   delete object v-field-handle.
   delete object v-text-handle.
end.
procedure xmldom-save :
define input parameter result  as character        no-undo.
define variable iType  as character no-undo init "file".
    define variable v-doc-handle    as handle           no-undo.
    define variable v-root-handle   as handle           no-undo.
    define variable v-row-handle    as handle           no-undo.
    define variable v-buf-handle    as handle           no-undo.
    define buffer buf_temp_testXML-node         for temp_testXML-node.
do
for buf_temp_testXML-node
on error undo, return error
:
    create x-document v-doc-handle.
    assign
        v-doc-handle :encoding = "windows-1251":U
    .
    create x-noderef v-root-handle.
    v-doc-handle :create-node ( v-root-handle, mRoot, "ELEMENT" ).
    v-doc-handle :append-child ( v-root-handle ).
    for each buf_temp_testXML-node where not buf_temp_testXML-node.xmhNodName begins "#"
    on error undo, return error
    :
        assign
            v-buf-handle = buffer buf_temp_testxml-node :handle
        .
        create x-noderef v-row-handle.
        v-doc-handle :create-node ( v-row-handle, buf_temp_testXML-node.xmhNodName, "ELEMENT" ).
        for each temp_testXML-atribut where temp_testXML-atribut.xme-key eq buf_temp_testXML-node.xmh-key
        no-lock:
           v-row-handle:SET-ATTRIBUTE(temp_testXML-atribut.xmeatrName,temp_testXML-atribut.xmeAtrValue).
        end.
        v-root-handle :append-child ( v-row-handle ).
        xmldom-save-next-level(buf_temp_testXML-node.xmh-key,v-doc-handle,v-row-handle).
        delete object v-row-handle.
    end.
    if    iType eq "file"
    then do:
       os-delete result.
       v-doc-handle :save ( iType, result ).
       output stream xmldom-out to value( result ) append.
       put stream xmldom-out unformatted chr(10).
       output stream xmldom-out close.
    end.
    else if iType eq "memptr"
    then
       v-doc-handle :save ( iType, result ).
    else
       v-doc-handle :save ( "file", iType ).
    delete object v-doc-handle.
    delete object v-root-handle.
end.
end .
function  xmldom-load-atribut returns logical
   (IParent    as handle,
   iParentkey as integer
   ):
   def var vanames as char no-undo.
   def var vname as char no-undo.
   define buffer temp_testXML-atribut          for temp_testXML-atribut.
   def var vi      as integer  no-undo.
   vanames = IParent:ATTRIBUTE-NAMES.
   do vi = 1 TO NUM-ENTRIES(vanames):
      vname = ENTRY(vi, vanames).
      create temp_testXML-atribut.
      assign
         temp_testXML-atribut.xme-key     = iParentkey
         temp_testXML-atribut.xmeatrName  = vname
         temp_testXML-atribut.xmeAtrValue = IParent:GET-ATTRIBUTE(vname)
      .
   END.
end.
define variable m-xme-key       as integer      no-undo.
function  xmldom-load-next-level returns logical
   (IParent    as handle,
   iParentkey as integer ,
   ifilever as int):
   define variable v-field-handle  as handle           no-undo.
   define variable v-text-handle   as handle           no-undo.
   define variable v-field-counter as integer          no-undo.
   define variable v-field-amount  as integer          no-undo.
   define variable vDateActive as date no-undo.
   define buffer buf_temp_testXML-entity       for temp_testXML-entity.
   create x-noderef v-field-handle.
   create x-noderef v-text-handle.
   assign
      v-field-amount = IParent :num-children
   .
   repeat v-field-counter = 1 to v-field-amount:
      IParent :get-child ( v-field-handle, v-field-counter ).
      if v-field-handle :num-children < 1
      then do:
         next.
      end.
      create buf_temp_testXML-entity.
      assign
         m-xme-key = m-xme-key + 1
         buf_temp_testXML-entity.xme-key     = m-xme-key
         buf_temp_testXML-entity.xmh-key     = iParentkey
      .
      v-field-handle :get-child ( v-text-handle, 1 ).
      if     IParent:name         eq "file-info"
         and v-field-handle :name eq "version"
      then do:
         mverfile = int(v-text-handle :node-value)no-error.
         if     ifilever ne ?
         then do:
            if  mverfile  eq ifilever
            then do:
               for each buf_temp_testXML-entity:
                  delete buf_temp_testXML-entity.
               end.
               return yes.
            end.
         end.
      end.
      else if     IParent:name         eq "file-info"
              and v-field-handle :name eq "DateActive"
      then do:
         vDateActive = date(v-text-handle :node-value)no-error.
         if     vDateActive ne ?
         then do:
            if  vDateActive  lt today
            then do:
               for each buf_temp_testXML-entity:
                  delete buf_temp_testXML-entity.
               end.
               return yes.
            end.
         end.
      end.
      else if     IParent:name         eq "file-info"
              and v-field-handle :name eq "NoTransaction"
      then do:
        mTransaction = no.
      end.
      assign
         buf_temp_testXML-entity.xmeEntName   = v-field-handle :name
         buf_temp_testXML-entity.xmeEntValue  = v-text-handle :node-value
      .
      if buf_temp_testXML-entity.xmeEntValue eq "unknown_value"  then buf_temp_testXML-entity.xmeEntValue = ?.
      xmldom-load-atribut(v-field-handle,buf_temp_testXML-entity.xme-key).
      xmldom-load-next-level (v-field-handle,buf_temp_testXML-entity.xme-key, ifilever ).
   end.
   delete object v-text-handle.
   delete object v-field-handle.
end.
function  xmldom-load-ver returns character
 (i-full-filename    as character ,
   ifilever as integer ):
   define variable v-doc-handle    as handle           no-undo.
   define variable v-root-handle   as handle           no-undo.
   define variable v-table-handle  as handle           no-undo.
   define variable v-table-counter as integer      no-undo.
   define variable v-table-amount  as integer      no-undo.
   define buffer buf_temp_testXML-node         for temp_testXML-node.
   mverfile = ?.
   mverfile_text = ?.
   do
   for buf_temp_testXML-node
   on error undo, return error
   :
      assign
         i-full-filename = search( i-full-filename )
      .
      if i-full-filename = ?
      then do:
         undo, return "Загружаемый файл не найден.".
      end.
      create x-document v-doc-handle.
      v-doc-handle :encoding = "windows-1251":U.
      create x-noderef v-root-handle.
      create x-noderef v-table-handle.
      v-doc-handle :load ( "file", i-full-filename, true ) no-error.
      if    error-status :error
         or not valid-handle ( v-doc-handle )
         or v-doc-handle = ?
      then do:
         undo, return error vss-description + substitute( "Ошибка загрузки XML-файла &1", i-full-filename ).
      end.
      v-doc-handle :get-document-element ( v-root-handle ) no-error.
      if    error-status :error
         or not valid-handle ( v-root-handle )
         or v-root-handle = ?
      then do:
         undo, return error vss-description + substitute( "Ошибка чтения корневого тэга XML-файла &1", i-full-filename ).
      end.
      assign
         v-table-amount = v-root-handle :num-children
      no-error.
      if    error-status :error
         or v-table-amount = ?
      then do:
         undo, return error vss-description + substitute( ".&1Неверная структура XML-файла &2", chr(10), i-full-filename ).
      end.
      m-xme-key = v-table-amount +  1.
        repeat v-table-counter = 1 to v-table-amount:
         v-root-handle :get-child ( v-table-handle, v-table-counter ).
         create buf_temp_testXML-node.
         assign
            buf_temp_testXML-node.xmh-key       = v-table-counter
            buf_temp_testXML-node.xmhNodName    = v-table-handle :name
         .
         xmldom-load-atribut(v-table-handle,buf_temp_testXML-node.xmh-key).
         if xmldom-load-next-level (v-table-handle,buf_temp_testXML-node.xmh-key,ifilever)
         then do:
            for each buf_temp_testXML-node:
               delete buf_temp_testXML-node.
            end.
            undo, return "Данные уже загружены.".
         end.
      end.
      delete object v-root-handle.
      delete object v-doc-handle.
      return mverfile_text.
   end.
end .
procedure xmldom-load :
define input parameter p-full-filename  as character        no-undo.
 xmldom-load-ver(p-full-filename,?) .
end.
function getEnties returns character
(input  i-parkey      as integer ,
                                         input i-entity-name    as character ,
                                         output o-entity-value  as character,
                                         output o-found         as logical ):
    define variable v-entity-name       as character no-undo.
    define variable v-entity-name-next  as character no-undo.
    define buffer buf_temp_testXML-entity    for temp_testXML-entity.
    v-entity-name     = entry(1,i-entity-name).
    if num-entries(i-entity-name) > 1
    then
       assign
          v-entity-name-next =  substring (i-entity-name,length(v-entity-name) + 2)
       .
    find first buf_temp_testXML-entity
             where buf_temp_testXML-entity.xmh-key      = i-parkey
               and buf_temp_testXML-entity.xmeEntName   = v-entity-name
        no-error.
    if available buf_temp_testXML-entity
    then do:
       if v-entity-name-next eq ""
       then assign
          o-entity-value = buf_temp_testXML-entity.xmeEntValue
          o-found        = yes
       .
       else do :
           getEnties(buf_temp_testXML-entity.xme-key,v-entity-name-next,output o-entity-value,output o-found).
       end.
    end.
end .
procedure xmldom-read-unique :
define input parameter i-node-name      as character        no-undo.
define input parameter i-entity-name    as character        no-undo.
define output parameter o-entity-value  as character        no-undo.
define output parameter o-found         as logical          no-undo.
define variable v-entity-l1-name  as character no-undo.
define variable v-entity-l2-name  as character no-undo.
    define buffer buf_temp_testXML-node         for temp_testXML-node.
do
for buf_temp_testXML-node
on error undo, return error
:
    assign
        o-found = no
    .
    search-all-nodes:
    for each buf_temp_testXML-node
       where buf_temp_testXML-node.xmhNodName = i-node-name
    :
        getEnties(buf_temp_testXML-node.xmh-key,i-entity-name,output o-entity-value,output o-found).
   end.
end.
end .
define variable v-file-name as character no-undo .
define variable v-old-dir1  as character no-undo .
define variable v-old-dir2  as character no-undo .
define variable v-old-dir3  as character no-undo .
define stream sinp .
DEFINE VAR upg-load AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-compare DEFAULT
     LABEL "&Сравнение"
     SIZE 13 BY 1.
DEFINE BUTTON b-quit DEFAULT
     LABEL "Вы&ход"
     SIZE 10 BY 1.
DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 76.13 BY 13.92 NO-UNDO.
DEFINE FRAME DEFAULT-FRAME
     b-compare AT ROW 1 COL 1
     b-quit AT ROW 1 COL 14
     log-edit AT ROW 2.29 COL 2.5 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 78.63 BY 15.92.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW upg-load ASSIGN
         HIDDEN             = YES
         TITLE              = "Сравнение *.r кодов"
         HEIGHT             = 15.92
         WIDTH              = 78.63
         MAX-HEIGHT         = 23.04
         MAX-WIDTH          = 100
         VIRTUAL-HEIGHT     = 23.04
         VIRTUAL-WIDTH      = 100
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE upg-load = CURRENT-WINDOW.
ASSIGN
       FRAME DEFAULT-FRAME:HIDDEN           = TRUE.
ASSIGN
       log-edit:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(upg-load)
THEN upg-load:HIDDEN = no.
ON END-ERROR OF upg-load
OR ENDKEY OF upg-load ANYWHERE DO:
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF upg-load
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ON CHOOSE OF b-compare IN FRAME DEFAULT-FRAME
DO:
  run start-compile in this-procedure .
END.
ON CHOOSE OF b-quit IN FRAME DEFAULT-FRAME
DO:
  QUIT .
END.
ASSIGN CURRENT-WINDOW                = upg-load
       THIS-PROCEDURE:CURRENT-WINDOW = upg-load.
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.
PAUSE 0 BEFORE-HIDE.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
  quit .
END.
PROCEDURE callback-write-to-log :
  define input parameter p-msg-str as character no-undo .
  define variable lok as logical   no-undo .
  do with frame DEFAULT-FRAME
  on error undo, return error
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(upg-load)
  THEN DELETE WIDGET upg-load.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY log-edit
      WITH FRAME DEFAULT-FRAME IN WINDOW upg-load.
  ENABLE b-compare b-quit log-edit
      WITH FRAME DEFAULT-FRAME IN WINDOW upg-load.
  VIEW FRAME DEFAULT-FRAME IN WINDOW upg-load.
  VIEW upg-load.
END PROCEDURE.
PROCEDURE read-parameters :
define input  parameter p-file-name    as character no-undo .
define output parameter p-dir1         as character no-undo .
define output parameter p-dir2         as character no-undo .
define output parameter p-dir3         as character no-undo .
    define variable v-tag-value as character    no-undo.
    define variable v-found     as logical      no-undo.
do
on error undo, return error return-value
:
    run xmldom-clear in this-procedure.
    run xmldom-load in this-procedure ( p-file-name ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла конфигурации."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "version":U, output v-tag-value, output v-found   ).
    if v-found = no
    or v-tag-value <> "2.0":U
    then do:
        message
            "Несовместимый формат файла параметров компиляции"
            skip "Файл параметров компиляции:"
            skip p-file-name
            skip (1)
            skip "Программа рассчитана на считывание файла параметров "
            skip "Версии 2.0 "
        view-as alert-box error
        title "Параметры компиляции".
        return .
    end.
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "directory_old":U      , output p-dir1, output v-found   ).
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "directory_new":U      , output p-dir2, output v-found   ).
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "directory_patch":U    , output p-dir3, output v-found   ).
end.
END PROCEDURE.
PROCEDURE save-parameters :
  define input  parameter p-file-name as character no-undo .
  define input  parameter p-dir1      as character no-undo .
  define input  parameter p-dir2      as character no-undo .
  define input  parameter p-dir3      as character no-undo .
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
  define variable v-backup-file-name as character no-undo .
do
on error undo, return error return-value
:
    run xmldom-clear in this-procedure .
    run xmldom-add in this-procedure ( input "comparer":U, input "version":U        , input "2.0":U ).
    run xmldom-add in this-procedure ( input "comparer":U, input "directory_old":U  , input p-dir1  ).
    run xmldom-add in this-procedure ( input "comparer":U, input "directory_new":U  , input p-dir2  ).
    run xmldom-add in this-procedure ( input "comparer":U, input "directory_patch":U, input p-dir3  ).
    run xmldom-save in this-procedure ( input p-file-name ).
end.
END PROCEDURE.
PROCEDURE start-compile :
  define variable v-dir1 as character no-undo .
  define variable v-dir2 as character no-undo .
  define variable v-dir3 as character no-undo .
  define variable v-ok   as logical   no-undo .
  assign
    v-file-name = session :parameter
  .
  if v-file-name <> ""
  then do:
    if  search(v-file-name) <> ""
    and search(v-file-name) <> ?
    then do:
      run read-parameters in this-procedure
        (input  search(v-file-name)
        ,output v-dir1
        ,output v-dir2
        ,output v-dir3
        ) .
    end.
    else do:
      message
        "Не найден файл параметров" skip
        "Имя файла" v-file-name skip
        view-as alert-box error .
    end.
  end.
  assign
    v-old-dir1 = v-dir1
    v-old-dir2 = v-dir2
    v-old-dir3 = v-dir3
  .
  run utl/d-dirinp.w
    (input-output v-dir1
    ,input-output v-dir2
    ,input-output v-dir3
    ) .
  if v-dir1 = ""
  or v-dir2 = ""
  or v-dir3 = ""
  then do:
    return .
  end.
  if v-dir1 <> v-old-dir1
  or v-dir2 <> v-old-dir2
  or v-dir3 <> v-old-dir3
  then do:
    if v-file-name <> ""
    then do:
      assign
        v-ok = true
      .
      message
        "Файл с параметрами по умолчанию" search(v-file-name) skip
        "Вы изменили параметры сравнения файлов" skip
        "Сохранить новые значения параметров?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok = true
      then do:
        run save-parameters in this-procedure
          (input  ( if search( v-file-name ) = ? then v-file-name else search( v-file-name ) )
          ,input  v-dir1
          ,input  v-dir2
          ,input  v-dir3
          ) .
      end.
    end.
  end.
  if  v-file-name <> ""
  and v-file-name <> ?
  and (search(v-file-name) = ""
       or search(v-file-name) = ?
      )
  then do:
    assign
      v-ok = true
    .
    message
      "Имя файла" v-file-name skip
      "Файл с параметрами по умолчанию отсутствует" skip
      "Создать файл с параметрами?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok = true
    then do:
      run save-parameters in this-procedure
        (input  v-file-name
        ,input  v-dir1
        ,input  v-dir2
        ,input  v-dir3
        ) .
    end.
  end.
  run utl/rcodecmp.p
    (input v-dir1
    ,input v-dir2
    ,input v-dir3
    ) .
END PROCEDURE.
