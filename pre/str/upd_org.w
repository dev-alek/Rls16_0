DEFINE BUFFER utd FOR utd.
define input parameter parparentproc as widget-handle no-undo .
define input parameter iDiadocConnection as component-handle no-undo.
define input parameter i-db-num as integer   no-undo .
define input parameter i-doc-id as integer no-undo .
define input parameter i-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма данных для возврата".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mPublishHand as handle no-undo.
define variable mDiadocApi as component-handle no-undo.
define stream File-stream.
define variable mdebug as logical no-undo.
mdebug= session:debug-alert.
function PutMes returns character
(idext as character ):
   if valid-handle(mPublishHand)
   then
      publish "WriteLogAsunc" from mPublishHand (idext,yes).
   else do:
      if idext begins "error"
      then do:
         message substring (idext,6)
            view-as alert-box.
         if mDiadocApi ne ?
         then
            idext = substitute ("&1 (&2)",idext , mDiadocApi:GetFullVersion())no-error.
      end.
      output stream File-stream to "diadoc_user.log" append.
      put stream File-stream unformatted now " " idext skip.
      output stream File-stream close.
   end.
end.
function PutErr returns character
(idext as character ):
   define variable vi as integer no-undo.
   define variable vnumerr as integer no-undo.
   define variable vtext as character extent 25 no-undo .
   if error-status:num-messages > 0 then do:
      vnumerr = error-status:num-messages.
      vnumerr = min(vnumerr,extent(vtext)).
      do vi = 1 to vnumerr:
         vtext[vi] = error-status:get-message(vi).
      end.
      idext = idext + chr(10) + "Ошибка: [":U.
      do vi = 1 to vnumerr:
         idext = idext + chr(10) + vtext[vi] no-error.
      end.
      idext = idext +  chr(10) +  " ]" no-error.
      if not  idext begins "Error"
      then
         idext = "Error " + idext.
      PutMes(idext).
   end.
end.
function PutStat returns character
(itext as character,
 iflag as logical):
   if valid-handle(mPublishHand)
   then
      publish "PutStatAsunc" from mPublishHand (itext,iflag).
   PutMes(itext).
end.
function chekStop returns logical
( ):
   define variable oStop as logical no-undo.
   if valid-handle(mPublishHand)
   then
      publish "StopProc" from mPublishHand (output oStop).
   return oStop.
end.
function  putloggetdesc returns logical
(is1 as character ,is2 as character ,
is3 as character ):
end.
function  getdesc returns logical
(input iObj as component-handle):
   if iObj eq ? then return false.
   if mdebug
   then do:
   output stream File-stream to "diadoc_load.txt" append.
   define variable vReflector as component-handle no-undo.
   define variable vDescobj  as component-handle no-undo.
   define variable vPropertyNames  as component-handle no-undo.
   define variable vMethodsNames as component-handle no-undo.
   define variable vMethodDesc as component-handle no-undo.
   define variable vMethodsName as character  no-undo.
   define variable vPropertyValue as char no-undo.
   create "Diadoc.Reflector" vReflector.
   vDescobj = vReflector:Describe(iObj).
  put   stream File-stream  unformatted skip (1)
   "------------------------------------------" skip
   vDescobj:GetInterfaceName() skip.
   define variable vPropertyName as character no-undo.
   define variable vPropertyType as character no-undo.
   .
   putloggetdesc(vDescobj:GetInterfaceName(),"","").
   putloggetdesc("property","","").
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
  put stream File-stream  unformatted skip "property" skip.
  vPropertyNames = vDescobj:GetPropertiesNames().
   vi= vPropertyNames:count.
   do vi= 1 to vPropertyNames:count :
      vPropertyName = "".
      vPropertyType = "".
      vPropertyValue = "".
      vPropertyName  = vPropertyNames:GetItem(vi - 1) no-error.
      vPropertyType  = vDescobj:GetPropertyType(vPropertyName) no-error .
      vPropertyValue = substring((vDescobj:GetProperty(vPropertyName)),1,4000) no-error.
      putloggetdesc(vPropertyName,vPropertyType,vPropertyValue).
     put stream File-stream  unformatted vPropertyName " " vPropertyType  " " vPropertyValue skip.
   end.
   release object vPropertyNames.
   put stream File-stream  unformatted skip "method" skip.
   vMethodsNames = vDescobj:GetMethodsNames().
   vi = vMethodsNames:count.
   do vi = 1 to vMethodsNames:count :
      vMethodsName = "".
      vMethodsName = vMethodsNames:GetItem(vi - 1)no-error.
      vMethodDesc  = vDescobj:GetMethodDesc(vMethodsName)no-error.
      putloggetdesc("method",vMethodsName, vMethodDesc:RetVal).
      put stream File-stream  unformatted vMethodsName  " retval " vMethodDesc:RetVal skip.
      do vii  = 1 to vMethodDesc:args:count:
         define variable varg as character no-undo.
         varg = "".
         varg = vMethodDesc:args:GetItem(vii - 1) no-error.
         put stream File-stream  unformatted " args " varg  skip .
         putloggetdesc(" args ",varg, "").
      end.
      release object vMethodDesc.
   end.
   release object vMethodsNames.
   put stream File-stream  unformatted "end---------------------------------------" skip.
   output stream File-stream close.
   release object vDescobj.
   release object vReflector.
   end.
   return true.
end.
function getxsddocum returns logical
(iOrganization as component-handle):
   if iOrganization eq ? then return false.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType as component-handle no-undo.
   define variable vFunctions as component-handle no-undo.
   define variable vFunction as component-handle no-undo.
   define variable vVersions as component-handle no-undo.
   define variable vVersion as component-handle no-undo.
   define variable vTitles as component-handle no-undo.
   define variable vTitle as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable viiii as integer no-undo.
   if mdebug
   then do:
   output stream File-stream to "diadoc_doc.txt" append.
   vDocumentTypes = iOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      put stream File-stream  unformatted "DocumentType -> NAme " vDocumentType:name skip.
      put stream File-stream  unformatted "DocumentType -> Title " vDocumentType:Title skip.
      vFunctions = vDocumentType:Functions.
      do vii =1 to vFunctions:count:
         vFunction = vFunctions:GetItem(vii - 1 ).
         put stream File-stream  unformatted "DocumentType -> Function -> NAme " vFunction:name skip.
         vVersions = vFunction:Versions.
         do viii =1 to vVersions:count:
            vVersion = vVersions:GetItem(viii - 1 ).
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> version " vVersion:version skip.
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> IsActual " vVersion:IsActual skip.
            vTitles  = vVersion:Titles.
            do viiii =1 to vTitles:count:
               vTitle = vTitles:GetItem(viiii - 1 ).
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> IsFormal " vTitle:IsFormal skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> XsdUrl " vTitle:XsdUrl skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> HaveUserDataXSD " vTitle:HaveUserDataXSD skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> type " vTitle:type skip.
               release object vTitle.
            end.
           release object vTitles.
            release object vVersion.
         end.
         release object vVersions.
         release object vFunction.
      end.
      release object vFunctions.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   put stream File-stream  unformatted "--------------------------------------------------- " skip.
  output stream File-stream close.
  end.
   return true.
end.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON btn_GetOrgFNs
     LABEL "Обновить"
     SIZE 15 BY 1.14.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_guid_cont
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U
     LABEL ""
     SIZE 5 BY 1.
DEFINE BUTTON Btn_guid_org
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U
     LABEL ""
     SIZE 5 BY 1.
DEFINE QUERY Dialog-Frame FOR
      utd SCROLLING.
DEFINE QUERY FRAME-ORG FOR
      utd SCROLLING.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.24 COL 3
     Btn_Cancel AT ROW 1.24 COL 19
     btn_GetOrgFNs AT ROW 1.24 COL 35 WIDGET-ID 2
     SPACE(85.79) SKIP(12.71)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Данные организаций"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
DEFINE FRAME FRAME-ORG
     utd.OrganizationExt AT ROW 2.19 COL 32 COLON-ALIGNED WIDGET-ID 2
          LABEL "GUID" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 90 BY 1
     Btn_guid_org AT ROW 2.19 COL 125 WIDGET-ID 6
     utd.obj-FnsParticipantId AT ROW 3.86 COL 32 COLON-ALIGNED WIDGET-ID 4
          LABEL "Ид. орг.-уч. документооборота" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 90 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 3.62
         SIZE 130 BY 5.71
         TITLE "Наша организация" WIDGET-ID 200.
DEFINE FRAME FRAME-Conrt
     utd.CounteragentId AT ROW 1.24 COL 32 COLON-ALIGNED WIDGET-ID 2
          LABEL "GUID" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 90 BY 1
     btn_guid_cont AT ROW 1.24 COL 125 WIDGET-ID 6
     utd.cli-FnsParticipantId AT ROW 2.91 COL 32 COLON-ALIGNED WIDGET-ID 4
          LABEL "Ид. орг.-уч. документооборота" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 90 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 9.81
         SIZE 130 BY 4.52
         TITLE "Контрагент" WIDGET-ID 300.
ASSIGN FRAME FRAME-Conrt:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-ORG:FRAME = FRAME Dialog-Frame:HANDLE.
DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.
ASSIGN XXTABVALXX = FRAME FRAME-ORG:MOVE-AFTER-TAB-ITEM (btn_GetOrgFNs:HANDLE IN FRAME Dialog-Frame)
       XXTABVALXX = FRAME FRAME-ORG:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-Conrt:HANDLE)
.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_guid_org IN FRAME FRAME-ORG
DO:
  run getguidorg no-error.
  if error-status:error
  then do:
     message return-value
     view-as alert-box.
     return no-apply.
  end.
END.
ON CHOOSE OF btn_GetOrgFNs IN FRAME Dialog-Frame
DO:
  run GetFNS (utd.OrganizationExt:screen-value in frame FRAME-ORG,
              utd.CounterAgentID:screen-value in frame FRAME-Conrt) no-error.
  if error-status:error
  then do:
     message return-value
     view-as alert-box.
     return no-apply.
  end.
  Btn_OK:sensitive in FRAME Dialog-Frame = yes.
END.
ON CHOOSE OF btn_guid_cont IN FRAME FRAME-Conrt
DO:
  run getguidcontr no-error.
  if error-status:error
  then do:
     message return-value
     view-as alert-box.
     return no-apply.
  end.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
   do with FRAME FRAME-ORG:
   assign
   utd.OrganizationExt
   utd.obj-FnsParticipantId
   .
   end.
   do with FRAME FRAME-Conrt:
   assign
   utd.cli-FnsParticipantId
   utd.CounteragentId
   .
   end.
  run save_proc.
END.
ON VALUE-CHANGED OF utd.CounteragentId IN FRAME FRAME-Conrt
DO:
  Btn_OK:sensitive in FRAME Dialog-Frame = no.
END.
ON VALUE-CHANGED OF utd.OrganizationExt IN FRAME FRAME-ORG
DO:
  Btn_OK:sensitive in FRAME Dialog-Frame = no.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first utd where utd.db-num eq i-db-num
                   and utd.doc-id eq i-doc-id
  no-lock no-error.
  if not avail utd
  then  do:
      message "Документ не найден."
      view-as alert-box.
      return.
  end.
  run Init_proc.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME FRAME-Conrt.
  HIDE FRAME FRAME-ORG.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH utd where utd.db-num eq i-db-num and utd.doc-id eq i-doc-id  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  ENABLE Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY FRAME-ORG FOR EACH utd where utd.db-num eq i-db-num and utd.doc-id eq i-doc-id SHARE-LOCK.
  GET FIRST FRAME-ORG.
  IF AVAILABLE utd THEN
    DISPLAY utd.OrganizationExt utd.obj-FnsParticipantId
      WITH FRAME FRAME-ORG.
  IF AVAILABLE utd THEN
    DISPLAY utd.CounteragentId utd.cli-FnsParticipantId
      WITH FRAME FRAME-Conrt.
END PROCEDURE.
PROCEDURE GetFNS :
    define input  parameter iORGGuid  as character no-undo.
    define input  parameter iContGuid as character no-undo.
    define variable vOrganization as component-handle no-undo.
    define variable vCounteragent as component-handle no-undo.
    vOrganization = iDiadocConnection:GetOrganizationById(iORGGuid) no-error.
    if vOrganization eq ?
    then do:
       return error "Нет доступа к организации".
    end.
    utd.OrganizationExt:screen-value in frame FRAME-ORG = vOrganization:guid.
    utd.obj-FnsParticipantId:screen-value in frame FRAME-ORG = vOrganization:FnsParticipantId.
    vCounteragent = vOrganization:GetCounteragentById(iContGuid).
    release object vOrganization.
    if vCounteragent eq ?
    then do:
       return error "Не найден контрагент".
    end.
    utd.CounterAgentId      :screen-value in frame frame-conrt = vCounteragent:Guid.
    utd.cli-FnsParticipantId:screen-value in frame frame-conrt = vCounteragent:FnsParticipantId.
    release object vCounteragent.
END PROCEDURE.
PROCEDURE getGuidOrg :
  define variable vFNS     as character no-undo.
  define variable vguid as character no-undo.
  do
  on error undo, return error return-value
  :
    run str/upd_org_brow.w (iDiadocConnection:GetOrganizationList(),
                            output vguid,
                            output vFNS).
    if vguid ne "" then
    do:
       utd.OrganizationExt:screen-value in frame FRAME-ORG = vguid.
       utd.obj-FnsParticipantId:screen-value in frame FRAME-ORG = vfns.
       Btn_OK:sensitive in FRAME Dialog-Frame = no.
    end.
    else do:
       Btn_OK:sensitive in FRAME Dialog-Frame = no.
    end.
  end.
END PROCEDURE.
PROCEDURE getGuidContr :
  define variable vFNS     as character no-undo.
  do
  on error undo, return error return-value
  :
    define variable vGuid as character no-undo.
    define variable vOrganization as component-handle no-undo.
    vOrganization = iDiadocConnection:GetOrganizationById(utd.OrganizationExt:screen-value in frame frame-org) no-error.
    if vOrganization eq ?
    then do:
       puterr( "ERROR Для выбора контр агента нужно правильно заполнить свою организацию.").
       return.
    end.
    define variable vOrganizationContr as component-handle no-undo.
    vOrganizationContr = vOrganization:GetCounteragentListByStatus("IsMyCounteragent") no-error.
    if vOrganizationContr eq ?
    then do:
       release object vOrganization.
       puterr( "ERROR Не удается получить список котр агентов ").
       return.
    end.
    run str/upd_org_brow.w (vOrganizationContr,
                            output vguid,
                            output vfns).
    release object vOrganizationContr no-error.
    release object vOrganization no-error.
    if vGuid ne "" then
    do:
       utd.CounteragentId:screen-value in frame frame-conrt = vguid.
       utd.cli-FnsParticipantId:screen-value in frame frame-conrt = vfns.
       Btn_OK:sensitive in FRAME Dialog-Frame = yes.
    end.
    else do:
       Btn_OK:sensitive in FRAME Dialog-Frame = no.
    end.
  end.
END PROCEDURE.
PROCEDURE Init_proc :
   if     i-mode            eq 'ИЗМЕНЕНИЕ':U
      and iDiadocConnection ne ?
   then do:
      btn_GetOrgFNs       :visible   in frame Dialog-Frame  = yes.
      btn_GetOrgFNs       :sensitive in frame Dialog-Frame  = yes.
      utd.CounterAgentId  :sensitive in FRAME FRAME-Conrt   = yes.
      utd.OrganizationExt :sensitive in FRAME FRAME-ORG     = yes.
      Btn_guid_cont       :visible   in frame FRAME-Conrt   = yes.
      Btn_guid_org        :visible   in frame FRAME-ORG     = yes.
      Btn_guid_cont       :sensitive in frame FRAME-Conrt   = yes.
      Btn_guid_org        :sensitive in frame FRAME-ORG     = yes.
   end.
   else do:
      btn_GetOrgFNs       :visible   in frame Dialog-Frame  = no.
      Btn_guid_cont       :visible   in frame FRAME-Conrt   = no.
      Btn_guid_org        :visible   in frame FRAME-ORG     = no.
   end.
END PROCEDURE.
PROCEDURE save_proc :
END PROCEDURE.
