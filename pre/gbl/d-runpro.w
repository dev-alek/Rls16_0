define input parameter parparentproc as widget-handle no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Запуск произвольной процедуры с параметрами".
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
define temp-table temp-param no-undo
  field run-name          as character
  field run-date          as date
  field run-time          as integer
  field num-param         as integer
  field param1            as character
  field param2            as character
  field param3            as character
  field run-persistent    as logical
  field run-parparentproc as logical
  index pi is unique primary run-name
  index pi1 run-date run-time
.
define stream runpr.
define stream sReadfile.
define variable v-store-file-name as character no-undo initial "d-runpro.txt" .
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
DEFINE VARIABLE COMBO-BOX-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 46.38 BY 1 NO-UNDO.
DEFINE VARIABLE FI-Parameter1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.63 BY 1 NO-UNDO.
DEFINE VARIABLE FI-Parameter2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.63 BY 1 NO-UNDO.
DEFINE VARIABLE FI-Parameter3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.63 BY 1 NO-UNDO.
DEFINE VARIABLE fi-procedure AS CHARACTER FORMAT "X(256)":U
     LABEL "Процедура"
     VIEW-AS FILL-IN
     SIZE 44.25 BY 1 NO-UNDO.
DEFINE VARIABLE rs-num-parameters AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без доп. параметров", 0,
"1 параметр", 1,
"2 параметра", 2,
"3 параметра", 3
     SIZE 23 BY 5.04 NO-UNDO.
DEFINE VARIABLE T-compil AS LOGICAL INITIAL no
     LABEL "Не компилировать"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.
DEFINE VARIABLE T-notsign AS LOGICAL INITIAL no
     LABEL "Без подписи"
     VIEW-AS TOGGLE-BOX
     SIZE 17.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-parparentproc AS LOGICAL INITIAL no
     LABEL "parparentproc"
     VIEW-AS TOGGLE-BOX
     SIZE 17.63 BY .79 NO-UNDO.
DEFINE VARIABLE T-persistent AS LOGICAL INITIAL no
     LABEL "persistent"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .79 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     COMBO-BOX-1 AT ROW 2.42 COL 14.75 COLON-ALIGNED NO-LABEL
     fi-procedure AT ROW 2.5 COL 14.75 COLON-ALIGNED
     T-parparentproc AT ROW 4 COL 3
     T-persistent AT ROW 4 COL 27
     rs-num-parameters AT ROW 5.25 COL 3 NO-LABEL
     FI-Parameter1 AT ROW 6.5 COL 25.63 COLON-ALIGNED NO-LABEL
     FI-Parameter2 AT ROW 7.88 COL 25.63 COLON-ALIGNED NO-LABEL
     FI-Parameter3 AT ROW 9.21 COL 25.63 COLON-ALIGNED NO-LABEL
     T-compil AT ROW 10.5 COL 3 WIDGET-ID 2
     T-notsign AT ROW 10.5 COL 26 WIDGET-ID 4
     SPACE(20.24) SKIP(0.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запуск процедуры"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       T-compil:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-notsign:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  run run-procedure in this-procedure no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске процедуры") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return no-apply .
  end.
END.
ON VALUE-CHANGED OF COMBO-BOX-1 IN FRAME Dialog-Frame
DO:
  ASSIGN COMBO-BOX-1 .
  run display-procedure-parameters in this-procedure .
 END.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if SearchFile(v-store-file-name) <> ?
  then do:
    run fill-temp in this-procedure .
    run fill-combo-box-list in this-procedure .
  end.
  RUN enable_UI .
  if parparentproc <> ?
  and valid-handle(parparentproc)
  then do:
    assign
      t-parparentproc :sensitive = true
    .
  end.
  if not objSrv:SystemSetting:DeveloperMode
  then
     assign
        T-compil:hidden  = no
        T-notsign:hidden = no
     .
  for each temp-param
  by temp-param.run-date descending
  by temp-param.run-time descending
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign
      COMBO-BOX-1  :screen-value in frame Dialog-Frame = temp-param.run-name
    .
    run display-procedure-parameters in this-procedure .
    leave .
  end.
  apply 'entry':u to fi-procedure  in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-procedure-parameters :
  do with frame Dialog-Frame
  :
    find first temp-param
      where temp-param.run-name = combo-box-1 :screen-value
      no-error .
    if available temp-param
    then do:
      assign
        fi-procedure  :screen-value = temp-param.run-name
        rs-num-parameters           = temp-param.num-param
        fi-parameter1 :screen-value = temp-param.param1
        fi-parameter2 :screen-value = temp-param.param2
        fi-parameter3 :screen-value = temp-param.param3
        t-persistent                = temp-param.run-persistent
      .
      if t-parparentproc :sensitive = true then do:
        assign
          t-parparentproc = temp-param.run-parparentproc
        .
      end.
    end.
    display
      t-parparentproc
      t-persistent
      rs-num-parameters
      with frame Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY COMBO-BOX-1 fi-procedure T-parparentproc T-persistent
          rs-num-parameters FI-Parameter1 FI-Parameter2 FI-Parameter3 T-compil
          T-notsign
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help COMBO-BOX-1 fi-procedure T-persistent
         rs-num-parameters FI-Parameter1 FI-Parameter2 FI-Parameter3 T-compil
         T-notsign
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-combo-box-list :
  do with frame Dialog-Frame
  :
    define variable v-file-list as character no-undo .
    assign
      v-file-list = '':U
    .
    for each temp-param
    by temp-param.run-date descending
    by temp-param.run-time descending
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      assign
        v-file-list = v-file-list
                    + (if v-file-list = '':U then '':U else ',':U )
                    + temp-param.run-name
      .
    end.
    assign
      combo-box-1 :list-items = v-file-list
    .
  end.
END PROCEDURE.
PROCEDURE fill-temp :
  define variable v-run-name          as character no-undo .
  define variable v-run-date          as date      no-undo .
  define variable v-run-time          as integer   no-undo .
  define variable v-num-param         as integer   no-undo .
  define variable v-param1            as character no-undo .
  define variable v-param2            as character no-undo .
  define variable v-param3            as character no-undo .
  define variable v-run-persistent    as logical   no-undo .
  define variable v-run-parparentproc as logical   no-undo .
  input stream runpr from value(v-store-file-name) .
  repeat
  :
    assign
      v-run-name          = '':U
      v-run-date          = ?
      v-run-time          = 0
      v-num-param         = 0
      v-param1            = '':U
      v-param2            = '':U
      v-param3            = '':U
      v-run-persistent    = false
      v-run-parparentproc = false
    .
    import stream runpr
      v-run-name
      v-run-date
      v-run-time
      v-num-param
      v-param1
      v-param2
      v-param3
      v-run-persistent
      v-run-parparentproc
      .
    create temp-param .
    assign
      temp-param.run-name          = v-run-name
      temp-param.run-date          = v-run-date
      temp-param.run-time          = v-run-time
      temp-param.num-param         = v-num-param
      temp-param.param1            = v-param1
      temp-param.param2            = v-param2
      temp-param.param3            = v-param3
      temp-param.run-persistent    = v-run-persistent
      temp-param.run-parparentproc = v-run-parparentproc
    .
  end.
  input stream runpr close .
END PROCEDURE.
PROCEDURE run-procedure :
  def var lok             as logical   no-undo .
  def var h-proc-handle   as handle    no-undo .
  def var v-proc-name      as character no-undo .
  def var v-num-parameters as integer   no-undo .
  def var v-parameter1     as character no-undo .
  def var v-parameter2     as character no-undo .
  def var v-parameter3     as character no-undo .
  define variable  str-tmp as character no-undo .
  define variable  num-pt  as integer   no-undo .
  do with frame Dialog-Frame:
    assign
      rs-num-parameters
      t-persistent
      t-parparentproc
      t-compil
      t-notsign
      .
    assign
      v-proc-name      = fi-procedure  :screen-value
      v-num-parameters = rs-num-parameters
      v-parameter1     = fi-parameter1 :screen-value
      v-parameter2     = fi-parameter2 :screen-value
      v-parameter3     = fi-parameter3 :screen-value
    .
    if v-proc-name = '':U
    then do:
      message
        "Необходимо ввести имя процедуры"
        view-as alert-box information .
      apply "entry":U to fi-procedure .
      undo, return error .
    end.
    if SearchFile(v-proc-name) = ?
    then do:
      search_block:
      do
      :
        define variable v-index-sub-dir       as integer   no-undo .
        define variable v-sub-dir-list        as character no-undo .
        define variable v-num-entries-sub-dir as integer   no-undo .
        define variable v-sub-dir-item        as character no-undo .
        define variable v-index-suffix        as integer   no-undo .
        define variable v-suffix-list         as character no-undo .
        define variable v-num-entries-suffix  as integer   no-undo .
        define variable v-suffix-item         as character no-undo .
        define variable v-search-proc-name    as character no-undo .
        define variable v-use-prog            as logical   no-undo .
        assign
          v-sub-dir-list        = ',adm/,arc/,bge/,cmp/,cus/,exe/,gbl/,nws/,osn/,rcs/,ref/,rep/,str/,trg/,utl/':U
          v-num-entries-sub-dir = num-entries(v-sub-dir-list)
          v-suffix-list         = ',.p,.w':U
          v-num-entries-suffix  = num-entries(v-suffix-list)
        .
        do v-index-sub-dir = 1 to v-num-entries-sub-dir
        :
          assign
            v-sub-dir-item = entry(v-index-sub-dir, v-sub-dir-list)
          .
          do v-index-suffix = 1 to v-num-entries-suffix
          :
            assign
              v-suffix-item = entry(v-index-suffix, v-suffix-list)
            .
            assign
              v-search-proc-name = SearchFile(v-sub-dir-item + v-proc-name + v-suffix-item)
            .
            if v-search-proc-name <> ?
            then do:
              message
                substitute("Найдена процедура &1", v-search-proc-name) skip
                "Запустить её?" skip
                view-as alert-box question buttons yes-no update v-use-prog .
              if v-use-prog = true
              then do:
                assign
                  v-proc-name = v-sub-dir-item + v-proc-name + v-suffix-item
                .
                leave search_block .
              end.
            end.
          end.
        end.
      end.
    end.
    if SearchFile(v-proc-name) = ?
    then do:
       message
          substitute("Не найдена процедура &1", v-proc-name)
       view-as alert-box.
       return no-apply.
    end.
    find first temp-param
      where temp-param.run-name = v-proc-name
      no-error .
    if not available temp-param
    then do:
      create temp-param .
      assign
        temp-param.run-name = v-proc-name
      .
    end.
    assign
      temp-param.num-param         = v-num-parameters
      temp-param.param1            = v-parameter1
      temp-param.param2            = v-parameter2
      temp-param.param3            = v-parameter3
      temp-param.run-persistent    = t-persistent
      temp-param.run-date          = today
      temp-param.run-time          = time
    .
    if t-parparentproc :sensitive = true then do:
      assign
        temp-param.run-parparentproc = t-parparentproc
      .
    end.
    run write-temp in this-procedure .
    run fill-combo-box-list in this-procedure .
    do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
       define variable vKey as integer no-undo.
       define variable vCheksum as character no-undo.
       define variable vlogfile as character no-undo.
       define variable vText as character no-undo.
       define variable vError as logical no-undo init yes.
       define variable vParamlist as character no-undo.
       if     objSrv:SystemSetting:DeveloperMode
          and T-compil:sensitive
          and not T-compil
       then do:
          run utl\compiler.p(input-output v-proc-name).
          if v-proc-name eq ?
          then return error.
       end.
       if T-notsign:sensitive
          and T-notsign
       then
          verror = no.
       else do:
          vKey = random(1,999999999).
          define variable vAsyncHelper as class ibs.th.file.AsyncHelperth no-undo.
          vAsyncHelper = new ibs.th.file.AsyncHelperth().
          vAsyncHelper:MyUser =  "".
          vAsyncHelper:MyPass =  "nocrypt:".
          vAsyncHelper:MyBachMode = no.
          vAsyncHelper:AsyncProc("utl/proc-chekproc", substitute("&1&8&2&8&3&8&4&8&5&8&6&8&7":U
                                                    , SearchFile(v-proc-name) ,v-num-parameters, t-parparentproc :checked, vKey,v-parameter1,v-parameter2,v-parameter3,chr(4) ),1).
          vAsyncHelper:myTimeOut = 300.
          run ibs\th\file\waithelper.p (vAsyncHelper,"proc-chekproc", 1,"Проверка процедуры.").
          vtext = "Процедура имеет не правильную подпись.".
          vlogfile = vAsyncHelper:getlog(?).
          if vAsyncHelper:FileExists(vlogfile)
          then do:
             input stream sReadfile FROM  VALUE(vlogfile).
             repeat:
                import stream sReadfile unformatted vText.
                if vtext begins "error"
                then assign
                   vtext = substring(vtext,7)
                .
                else do:
                   vCheksum = vText.
                   if (vCheksum ne encode(string(vKey * 13)) + string(index(encode(string(vKey)), "k"))
 )
                   then assign
                      vtext = "Процедура имеет не правильную подпись."
                   .
                   else
                      vError = no.
                end.
             end.
             input stream sReadfile close  .
             os-delete value(vlogfile).
          end.
          else assign
              vtext = "Не получен результат проверки."
              vError = yes.
          vAsyncHelper:delworkdir().
          delete object vAsyncHelper.
       end.
       if vError
       then do:
          run trg/userlog.p (
                input 'run-proc'
                , input (substitute( "&1. Не прошла проверка подписи. &2", vss-workfile, vtext)  + chr(3) + v-proc-name )
                , input ?
                , input ?
                , input "") no-error.
          undo, return error substitute( "&1. Не прошла проверка подписи. &2", vss-workfile, vtext) .
       end.
       else do:
          if can-do("true,yes", t-persistent :screen-value)
          then do:
              case v-num-parameters :
                when 0
                then do:
                   vParamlist = "".
                end.
                when 1
                then do:
                   vParamlist = v-parameter1.
                end.
                when 2
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2.
                end.
                when 3
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 + "|" + v-parameter3.
                end.
             end.
             run trg/userlog.p (
                input 'run-proc'
                , input ("Начато выполнение процедуры "  + chr(3) + v-proc-name  + chr(3) + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
             case v-num-parameters :
                when 0
                then do:
                   vParamlist = "".
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                       ) no-error .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                          (input vkey
                          ,output vCheksum
                           )no-error.
                   end.
                end.
                when 1
                then do:
                   vParamlist = v-parameter1.
                   if parparentproc <> ?
                   and valid-handle(parparentproc)
                   and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                         ,input v-parameter1
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum
                         ,input v-parameter1
                         ) no-error .
                   end.
                end.
                when 2
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2.
                   if parparentproc <> ?
                   and valid-handle(parparentproc)
                   and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ) no-error.
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum
                         ,input v-parameter1
                         ,input v-parameter2
                         ) no-error.
                   end.
                end.
                when 3
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 + "|" + v-parameter3.
                   if parparentproc <> ?
                   and valid-handle(parparentproc)
                   and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) no-error.
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input vkey
                         ,output vCheksum
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) no-error.
                   end.
                end.
             end case .
             if not error-status:error
             then
                message
                   "Процедура запущена" skip
                   "Указатель процедуры" h-proc-handle skip
                   view-as alert-box .
          end.
          else do:
             case v-num-parameters :
                when 0
                then do:
                   vParamlist = "".
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                         ) no-error .
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ) no-error.
                   end.
                end.
                when 1
                then do:
                   vParamlist = v-parameter1.
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                         ,input v-parameter1
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ,input v-parameter1
                         )no-error.
                   end.
                end.
                when 2
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 .
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ,input v-parameter1
                         ,input v-parameter2
                         )no-error.
                   end.
                end.
                when 3
                then do:
                   vParamlist = v-parameter1 + "|" + v-parameter2 + "|" + v-parameter3.
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ,input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         )no-error.
                   end.
                   else do:
                      run value (v-proc-name)
                         (input vkey
                         ,output vCheksum
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         )no-error.
                   end.
                end.
             end case.
          end.
          if not error-status :error
          then do:
             run trg/userlog.p (
                input 'run-proc'
                , input ("Завершено выполнение процедуры без ошибок "  + chr(3) + v-proc-name  + chr(3) + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
             return.
          end.
          else if  not objSrv:SystemSetting:DeveloperMode
          then do:
             run trg/userlog.p (
                input 'run-proc'
                , input ("Завершено выполнение процедуры с ошибками "  + chr(3) + v-proc-name + chr(3) + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
             undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ).
          end.
          message "Данная процедура не запустится у клиент."
             view-as alert-box warning .
          if can-do("true,yes", t-persistent :screen-value)
          then do:
             case v-num-parameters :
                when 0
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ) .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle .
                   end.
                end.
                when 1
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ,input v-parameter1
                         ) .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input v-parameter1
                         ) .
                   end.
                end.
                when 2
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ) .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input v-parameter1
                         ,input v-parameter2
                         ) .
                   end.
                end.
                when 3
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) .
                   end.
                   else do:
                      run value (v-proc-name) persistent set h-proc-handle
                         (input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ) .
                   end.
                end.
             end case .
             message
                "Процедура запущена" skip
                "Указатель процедуры" h-proc-handle skip
                view-as alert-box .
          end.
          else do:
             case v-num-parameters :
                when 0
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ) .
                   end.
                   else do:
                      run value (v-proc-name)
                         .
                   end.
                end.
                when 1
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ,input v-parameter1
                         ).
                   end.
                   else do:
                      run value (v-proc-name)
                         (input v-parameter1
                         ).
                   end.
                end.
                when 2
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ).
                   end.
                   else do:
                      run value (v-proc-name)
                         (input v-parameter1
                         ,input v-parameter2
                         ).
                   end.
                end.
                when 3
                then do:
                   if parparentproc <> ?
                  and valid-handle(parparentproc)
                  and t-parparentproc :checked
                   then do:
                      run value (v-proc-name)
                         (input parparentproc
                         ,input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ).
                   end.
                   else do:
                      run value (v-proc-name)
                         (input v-parameter1
                         ,input v-parameter2
                         ,input v-parameter3
                         ).
                   end.
                end.
             end case.
             run trg/userlog.p (
                input 'run-proc'
                , input ("Выполнена процедура"  + chr(3) + v-proc-name + chr(3) + vParamlist)
                , input ?
                , input ?
                , input "") no-error.
          end.
       end.
    end.
  end.
END PROCEDURE.
PROCEDURE write-temp :
  define variable v-ind as integer   no-undo .
  output stream runpr to value(v-store-file-name) .
  for each temp-param
  by temp-param.run-date descending
  by temp-param.run-time descending
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    if temp-param.run-name <> '':U
    then do:
      export stream runpr temp-param .
      assign
        v-ind = v-ind + 1
      .
      if v-ind >= 10 then do:
        leave .
      end.
    end.
  end.
  output stream runpr close .
END PROCEDURE.
