DEFINE NEW GLOBAL SHARED VARIABLE appSrvUtils AS HANDLE                NO-UNDO.
IF NOT VALID-HANDLE(appSrvUtils) THEN
  RUN adecomm/as-utils.w PERSISTENT SET appSrvUtils.
THIS-PROCEDURE:ADD-SUPER-PROCEDURE(appSrvUtils).
CREATE WIDGET-POOL.
define input parameter p-1 as character no-undo .
define input parameter p-2 as character no-undo .
define input parameter p-3 as character no-undo .
define input parameter p-is as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сообщение" .
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
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Закрыть сообщение"
     SIZE 30 BY 1.25.
DEFINE VARIABLE mes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 103.5 BY 21.25
     FGCOLOR 12 FONT 8 NO-UNDO.
DEFINE FRAME gDialog
     mes AT ROW 1.5 COL 2 NO-LABEL WIDGET-ID 26
     Btn_OK AT ROW 23.25 COL 38.88
     SPACE(37.49) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сообщение о превышении"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
  IF CURRENT-WINDOW <> CURRENT-WINDOW THEN
  DO:
    IF CURRENT-WINDOW:MAX-WIDTH = CURRENT-WINDOW:VIRTUAL-WIDTH THEN
      CURRENT-WINDOW:MAX-WIDTH  = SESSION:WIDTH - 1 NO-ERROR.
    IF CURRENT-WINDOW:MAX-HEIGHT = CURRENT-WINDOW:VIRTUAL-HEIGHT THEN
      CURRENT-WINDOW:MAX-HEIGHT = SESSION:HEIGHT - 1 NO-ERROR.
  END.
PROCEDURE assignPageProperty IN SUPER:
  DEFINE INPUT PARAMETER pcProp AS CHARACTER.
  DEFINE INPUT PARAMETER pcValue AS CHARACTER.
END PROCEDURE.
PROCEDURE changePage IN SUPER:
END PROCEDURE.
PROCEDURE confirmExit IN SUPER:
  DEFINE INPUT-OUTPUT PARAMETER plCancel AS LOGICAL.
END PROCEDURE.
PROCEDURE constructObject IN SUPER:
  DEFINE INPUT PARAMETER pcProcName AS CHARACTER.
  DEFINE INPUT PARAMETER phParent AS HANDLE.
  DEFINE INPUT PARAMETER pcPropList AS CHARACTER.
  DEFINE OUTPUT PARAMETER phObject AS HANDLE.
END PROCEDURE.
PROCEDURE createObjects IN SUPER:
END PROCEDURE.
PROCEDURE deletePage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
PROCEDURE destroyObject IN SUPER:
END PROCEDURE.
PROCEDURE hidePage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
PROCEDURE initializeObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeVisualContainer IN SUPER:
END PROCEDURE.
PROCEDURE initPages IN SUPER:
  DEFINE INPUT PARAMETER pcPageList AS CHARACTER.
END PROCEDURE.
PROCEDURE notifyPage IN SUPER:
  DEFINE INPUT PARAMETER pcProc AS CHARACTER.
END PROCEDURE.
PROCEDURE passThrough IN SUPER:
  DEFINE INPUT PARAMETER pcLinkName AS CHARACTER.
  DEFINE INPUT PARAMETER pcArgument AS CHARACTER.
END PROCEDURE.
PROCEDURE removePageNTarget IN SUPER:
  DEFINE INPUT PARAMETER phTarget AS HANDLE.
  DEFINE INPUT PARAMETER piPage AS INTEGER.
END PROCEDURE.
PROCEDURE selectPage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
PROCEDURE toolbar IN SUPER:
  DEFINE INPUT PARAMETER pcValue AS CHARACTER.
END PROCEDURE.
PROCEDURE viewObject IN SUPER:
END PROCEDURE.
PROCEDURE viewPage IN SUPER:
  DEFINE INPUT PARAMETER piPageNum AS INTEGER.
END PROCEDURE.
FUNCTION disablePagesInFolder RETURNS LOGICAL
  (INPUT pcPageInformation AS CHARACTER) IN SUPER.
FUNCTION enablePagesInFolder RETURNS LOGICAL
  (INPUT pcPageInformation AS CHARACTER) IN SUPER.
FUNCTION getCallerProcedure RETURNS HANDLE IN SUPER.
FUNCTION getCallerWindow RETURNS HANDLE IN SUPER.
FUNCTION getContainerMode RETURNS CHARACTER IN SUPER.
FUNCTION getContainerTarget RETURNS CHARACTER IN SUPER.
FUNCTION getContainerTargetEvents RETURNS CHARACTER IN SUPER.
FUNCTION getCurrentPage RETURNS INTEGER IN SUPER.
FUNCTION getDisabledAddModeTabs RETURNS CHARACTER IN SUPER.
FUNCTION getDynamicSDOProcedure RETURNS CHARACTER IN SUPER.
FUNCTION getFilterSource RETURNS HANDLE IN SUPER.
FUNCTION getMultiInstanceActivated RETURNS LOGICAL IN SUPER.
FUNCTION getMultiInstanceSupported RETURNS LOGICAL IN SUPER.
FUNCTION getNavigationSource RETURNS CHARACTER IN SUPER.
FUNCTION getNavigationSourceEvents RETURNS CHARACTER IN SUPER.
FUNCTION getNavigationTarget RETURNS HANDLE IN SUPER.
FUNCTION getOutMessageTarget RETURNS HANDLE IN SUPER.
FUNCTION getPageNTarget RETURNS CHARACTER IN SUPER.
FUNCTION getPageSource RETURNS HANDLE IN SUPER.
FUNCTION getPrimarySdoTarget RETURNS HANDLE IN SUPER.
FUNCTION getReEnableDataLinks RETURNS CHARACTER IN SUPER.
FUNCTION getRunDOOptions RETURNS CHARACTER IN SUPER.
FUNCTION getRunMultiple RETURNS LOGICAL IN SUPER.
FUNCTION getSavedContainerMode RETURNS CHARACTER IN SUPER.
FUNCTION getSdoForeignFields RETURNS CHARACTER IN SUPER.
FUNCTION getTopOnly RETURNS LOGICAL IN SUPER.
FUNCTION getUpdateSource RETURNS CHARACTER IN SUPER.
FUNCTION getUpdateTarget RETURNS CHARACTER IN SUPER.
FUNCTION getWaitForObject RETURNS HANDLE IN SUPER.
FUNCTION getWindowTitleViewer RETURNS HANDLE IN SUPER.
FUNCTION getStatusArea RETURNS LOGICAL IN SUPER.
FUNCTION pageNTargets RETURNS CHARACTER
  (INPUT phTarget AS HANDLE,
   INPUT piPageNum AS INTEGER) IN SUPER.
FUNCTION setCallerObject RETURNS LOGICAL
  (INPUT h AS HANDLE) IN SUPER.
FUNCTION setCallerProcedure RETURNS LOGICAL
  (INPUT h AS HANDLE) IN SUPER.
FUNCTION setCallerWindow RETURNS LOGICAL
  (INPUT h AS HANDLE) IN SUPER.
FUNCTION setContainerMode RETURNS LOGICAL
  (INPUT cContainerMode AS CHARACTER) IN SUPER.
FUNCTION setContainerTarget RETURNS LOGICAL
  (INPUT pcObject AS CHARACTER) IN SUPER.
FUNCTION setCurrentPage RETURNS LOGICAL
  (INPUT iPage AS INTEGER) IN SUPER.
FUNCTION setDisabledAddModeTabs RETURNS LOGICAL
  (INPUT cDisabledAddModeTabs AS CHARACTER) IN SUPER.
FUNCTION setDynamicSDOProcedure RETURNS LOGICAL
  (INPUT pcProc AS CHARACTER) IN SUPER.
FUNCTION setFilterSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setInMessageTarget RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setMultiInstanceActivated RETURNS LOGICAL
  (INPUT lMultiInstanceActivated AS LOGICAL) IN SUPER.
FUNCTION setMultiInstanceSupported RETURNS LOGICAL
  (INPUT lMultiInstanceSupported AS LOGICAL) IN SUPER.
FUNCTION setNavigationSource RETURNS LOGICAL
  (INPUT pcSource AS CHARACTER) IN SUPER.
FUNCTION setNavigationSourceEvents RETURNS LOGICAL
  (INPUT pcEvents AS CHARACTER) IN SUPER.
FUNCTION setNavigationTarget RETURNS LOGICAL
  (INPUT cTarget AS CHARACTER) IN SUPER.
FUNCTION setOutMessageTarget RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setPageNTarget RETURNS LOGICAL
  (INPUT pcObject AS CHARACTER) IN SUPER.
FUNCTION setPageSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setPrimarySdoTarget RETURNS LOGICAL
  (INPUT hPrimarySdoTarget AS HANDLE) IN SUPER.
FUNCTION setReEnableDataLinks RETURNS LOGICAL
  (INPUT cReEnableDataLinks AS CHARACTER) IN SUPER.
FUNCTION setRouterTarget RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setRunDOOptions RETURNS LOGICAL
  (INPUT pcOptions AS CHARACTER) IN SUPER.
FUNCTION setRunMultiple RETURNS LOGICAL
  (INPUT plMultiple AS LOGICAL) IN SUPER.
FUNCTION setSavedContainerMode RETURNS LOGICAL
  (INPUT cSavedContainerMode AS CHARACTER) IN SUPER.
FUNCTION setSdoForeignFields RETURNS LOGICAL
  (INPUT cSdoForeignFields AS CHARACTER) IN SUPER.
FUNCTION setTopOnly RETURNS LOGICAL
  (INPUT plTopOnly AS LOGICAL) IN SUPER.
FUNCTION setUpdateSource RETURNS LOGICAL
  (INPUT pcSource AS CHARACTER) IN SUPER.
FUNCTION setUpdateTarget RETURNS LOGICAL
  (INPUT pcTarget AS CHARACTER) IN SUPER.
FUNCTION setWaitForObject RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setWindowTitleViewer RETURNS LOGICAL
  (INPUT phViewer AS HANDLE) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
FUNCTION setStatusArea RETURNS LOGICAL
  (INPUT plStatusArea AS LOGICAL) IN SUPER.
PROCEDURE applyLayout IN SUPER:
END PROCEDURE.
PROCEDURE disableObject IN SUPER:
END PROCEDURE.
PROCEDURE enableObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeObject IN SUPER:
END PROCEDURE.
PROCEDURE processAction IN SUPER:
  DEFINE INPUT PARAMETER pcAction AS CHARACTER.
END PROCEDURE.
FUNCTION getAllFieldHandles RETURNS CHARACTER IN SUPER.
FUNCTION getAllFieldNames RETURNS CHARACTER IN SUPER.
FUNCTION getCol RETURNS DECIMAL IN SUPER.
FUNCTION getDefaultLayout RETURNS CHARACTER IN SUPER.
FUNCTION getDisableOnInit RETURNS LOGICAL IN SUPER.
FUNCTION getEnabledObjFlds RETURNS CHARACTER IN SUPER.
FUNCTION getEnabledObjHdls RETURNS CHARACTER IN SUPER.
FUNCTION getHeight RETURNS DECIMAL IN SUPER.
FUNCTION getHideOnInit RETURNS LOGICAL IN SUPER.
FUNCTION getLayoutOptions RETURNS CHARACTER IN SUPER.
FUNCTION getLayoutVariable RETURNS CHARACTER IN SUPER.
FUNCTION getObjectEnabled RETURNS LOGICAL IN SUPER.
FUNCTION getObjectLayout RETURNS CHARACTER IN SUPER.
FUNCTION getRow RETURNS DECIMAL IN SUPER.
FUNCTION getWidth RETURNS DECIMAL IN SUPER.
FUNCTION getResizeHorizontal RETURNS LOGICAL IN SUPER.
FUNCTION getResizeVertical RETURNS LOGICAL IN SUPER.
FUNCTION setAllFieldHandles RETURNS LOGICAL
  (INPUT pcValue AS CHARACTER) IN SUPER.
FUNCTION setAllFieldNames RETURNS LOGICAL
  (INPUT pcValue AS CHARACTER) IN SUPER.
FUNCTION setDefaultLayout RETURNS LOGICAL
  (INPUT pcDefault AS CHARACTER) IN SUPER.
FUNCTION setDisableOnInit RETURNS LOGICAL
  (INPUT plDisable AS LOGICAL) IN SUPER.
FUNCTION setHideOnInit RETURNS LOGICAL
  (INPUT plHide AS LOGICAL) IN SUPER.
FUNCTION setLayoutOptions RETURNS LOGICAL
  (INPUT pcOptions AS CHARACTER) IN SUPER.
FUNCTION setObjectLayout RETURNS LOGICAL
  (INPUT pcLayout AS CHARACTER) IN SUPER.
FUNCTION setResizeHorizontal RETURNS LOGICAL
  (INPUT plResizeHorizontal AS LOGICAL) IN SUPER.
FUNCTION setResizeVertical RETURNS LOGICAL
  (INPUT plResizeVertical AS LOGICAL) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
FUNCTION getObjectTranslated RETURNS LOGICAL IN SUPER.
FUNCTION getObjectSecured RETURNS LOGICAL IN SUPER.
FUNCTION createUiEvents RETURNS LOGICAL IN SUPER.
PROCEDURE bindServer IN SUPER:
END PROCEDURE.
PROCEDURE destroyObject IN SUPER:
END PROCEDURE.
PROCEDURE destroyServerObject IN SUPER:
END PROCEDURE.
PROCEDURE disconnectObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeServerObject IN SUPER:
END PROCEDURE.
PROCEDURE restartServerObject IN SUPER:
END PROCEDURE.
PROCEDURE runServerObject IN SUPER:
  DEFINE INPUT PARAMETER phAppService AS HANDLE.
END PROCEDURE.
PROCEDURE startServerObject IN SUPER:
END PROCEDURE.
PROCEDURE unbindServer IN SUPER:
  DEFINE INPUT PARAMETER pcMode AS CHARACTER.
END PROCEDURE.
FUNCTION getAppService RETURNS CHARACTER IN SUPER.
FUNCTION getASBound RETURNS LOGICAL IN SUPER.
FUNCTION getAsDivision RETURNS CHARACTER IN SUPER.
FUNCTION getASHandle RETURNS HANDLE IN SUPER.
FUNCTION getASHasStarted RETURNS LOGICAL IN SUPER.
FUNCTION getASInfo RETURNS CHARACTER IN SUPER.
FUNCTION getASInitializeOnRun RETURNS LOGICAL IN SUPER.
FUNCTION getASUsePrompt RETURNS LOGICAL IN SUPER.
FUNCTION getServerFileName RETURNS CHARACTER IN SUPER.
FUNCTION getServerOperatingMode RETURNS CHARACTER IN SUPER.
FUNCTION runServerProcedure RETURNS HANDLE
  (INPUT pcServerFileName AS CHARACTER,
   INPUT phAppService AS HANDLE) IN SUPER.
FUNCTION setAppService RETURNS LOGICAL
  (INPUT pcAppService AS CHARACTER) IN SUPER.
FUNCTION setASDivision RETURNS LOGICAL
  (INPUT pcDivision AS CHARACTER) IN SUPER.
FUNCTION setASHandle RETURNS LOGICAL
  (INPUT phASHandle AS HANDLE) IN SUPER.
FUNCTION setASInfo RETURNS LOGICAL
  (INPUT pcInfo AS CHARACTER) IN SUPER.
FUNCTION setASInitializeOnRun RETURNS LOGICAL
  (INPUT plInitialize AS LOGICAL) IN SUPER.
FUNCTION setASUsePrompt RETURNS LOGICAL
  (INPUT plFlag AS LOGICAL) IN SUPER.
FUNCTION setServerFileName RETURNS LOGICAL
  (INPUT pcFileName AS CHARACTER) IN SUPER.
FUNCTION setServerOperatingMode RETURNS LOGICAL
  (INPUT pcServerOperatingMode AS CHARACTER) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
DEFINE NEW GLOBAL SHARED VARIABLE  gshAstraAppserver     AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshSessionManager     AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshRIManager          AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshSecurityManager    AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshProfileManager     AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshRepositoryManager  AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshTranslationManager AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshWebManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gscSessionId          AS CHARACTER NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdSessionObj         AS DECIMAL DECIMALS 9 NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshFinManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshGenManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gshAgnManager         AS HANDLE    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdTempUniqueID       AS DECIMAL DECIMALS 9  NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdUserObj            AS DECIMAL DECIMALS 9  NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdRenderTypeObj      AS DECIMAL DECIMALS 9  NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE  gsdSessionScopeObj    AS DECIMAL DECIMALS 9  NO-UNDO.
 DEFINE VARIABLE ghProp                AS HANDLE  NO-UNDO.
 DEFINE VARIABLE ghADMProps            AS HANDLE  NO-UNDO.
 DEFINE VARIABLE ghADMPropsBuf         AS HANDLE  NO-UNDO.
 DEFINE VARIABLE glADMLoadFromRepos    AS LOGICAL NO-UNDO.
 DEFINE VARIABLE glADMOk               AS LOGICAL NO-UNDO.
FUNCTION getObjectType RETURNS CHARACTER
  ( )  FORWARD.
PROCEDURE addLink IN SUPER:
  DEFINE INPUT PARAMETER phSource AS HANDLE.
  DEFINE INPUT PARAMETER pcLink AS CHARACTER.
  DEFINE INPUT PARAMETER phTarget AS HANDLE.
END PROCEDURE.
PROCEDURE addMessage IN SUPER:
  DEFINE INPUT PARAMETER pcText AS CHARACTER.
  DEFINE INPUT PARAMETER pcField AS CHARACTER.
  DEFINE INPUT PARAMETER pcTable AS CHARACTER.
END PROCEDURE.
PROCEDURE adjustTabOrder IN SUPER:
  DEFINE INPUT PARAMETER phObject AS HANDLE.
  DEFINE INPUT PARAMETER phAnchor AS HANDLE.
  DEFINE INPUT PARAMETER pcPosition AS CHARACTER.
END PROCEDURE.
PROCEDURE applyEntry IN SUPER:
  DEFINE INPUT PARAMETER pcField AS CHARACTER.
END PROCEDURE.
PROCEDURE changeCursor IN SUPER:
  DEFINE INPUT PARAMETER pcCursor AS CHARACTER.
END PROCEDURE.
PROCEDURE createControls IN SUPER:
END PROCEDURE.
PROCEDURE destroyObject IN SUPER:
END PROCEDURE.
PROCEDURE displayLinks IN SUPER:
END PROCEDURE.
PROCEDURE editInstanceProperties IN SUPER:
END PROCEDURE.
PROCEDURE exitObject IN SUPER:
END PROCEDURE.
PROCEDURE hideObject IN SUPER:
END PROCEDURE.
PROCEDURE initializeObject IN SUPER:
END PROCEDURE.
PROCEDURE modifyListProperty IN SUPER:
  DEFINE INPUT PARAMETER phCaller AS HANDLE.
  DEFINE INPUT PARAMETER pcMode AS CHARACTER.
  DEFINE INPUT PARAMETER pcListName AS CHARACTER.
  DEFINE INPUT PARAMETER pcListValue AS CHARACTER.
END PROCEDURE.
PROCEDURE modifyUserLinks IN SUPER:
  DEFINE INPUT PARAMETER pcMod AS CHARACTER.
  DEFINE INPUT PARAMETER pcLinkName AS CHARACTER.
  DEFINE INPUT PARAMETER phObject AS HANDLE.
END PROCEDURE.
PROCEDURE removeAllLinks IN SUPER:
END PROCEDURE.
PROCEDURE removeLink IN SUPER:
  DEFINE INPUT PARAMETER phSource AS HANDLE.
  DEFINE INPUT PARAMETER pcLink AS CHARACTER.
  DEFINE INPUT PARAMETER phTarget AS HANDLE.
END PROCEDURE.
PROCEDURE repositionObject IN SUPER:
  DEFINE INPUT PARAMETER pdRow AS DECIMAL.
  DEFINE INPUT PARAMETER pdCol AS DECIMAL.
END PROCEDURE.
PROCEDURE returnFocus IN SUPER:
  DEFINE INPUT PARAMETER hTarget AS HANDLE.
END PROCEDURE.
PROCEDURE showMessageProcedure IN SUPER:
  DEFINE INPUT PARAMETER pcMessage AS CHARACTER.
  DEFINE OUTPUT PARAMETER plAnswer AS LOGICAL.
END PROCEDURE.
PROCEDURE toggleData IN SUPER:
  DEFINE INPUT PARAMETER plEnabled AS LOGICAL.
END PROCEDURE.
PROCEDURE viewObject IN SUPER:
END PROCEDURE.
FUNCTION anyMessage RETURNS LOGICAL IN SUPER.
FUNCTION assignLinkProperty RETURNS LOGICAL
  (INPUT pcLink AS CHARACTER,
   INPUT pcPropName AS CHARACTER,
   INPUT pcPropValue AS CHARACTER) IN SUPER.
FUNCTION fetchMessages RETURNS CHARACTER IN SUPER.
FUNCTION getChildDataKey RETURNS CHARACTER IN SUPER.
FUNCTION getContainerHandle RETURNS HANDLE IN SUPER.
FUNCTION getContainerHidden RETURNS LOGICAL IN SUPER.
FUNCTION getContainerSource RETURNS HANDLE IN SUPER.
FUNCTION getContainerSourceEvents RETURNS CHARACTER IN SUPER.
FUNCTION getContainerType RETURNS CHARACTER IN SUPER.
FUNCTION getDataLinksEnabled RETURNS LOGICAL IN SUPER.
FUNCTION getDataSource RETURNS HANDLE IN SUPER.
FUNCTION getDataSourceEvents RETURNS CHARACTER IN SUPER.
FUNCTION getDataSourceNames RETURNS CHARACTER IN SUPER.
FUNCTION getDataTarget RETURNS CHARACTER IN SUPER.
FUNCTION getDataTargetEvents RETURNS CHARACTER IN SUPER.
FUNCTION getDBAware RETURNS LOGICAL IN SUPER.
FUNCTION getDesignDataObject RETURNS CHARACTER IN SUPER.
FUNCTION getDynamicObject RETURNS LOGICAL IN SUPER.
FUNCTION getInstanceProperties RETURNS CHARACTER IN SUPER.
FUNCTION getLogicalObjectName RETURNS CHARACTER IN SUPER.
FUNCTION getLogicalVersion RETURNS CHARACTER IN SUPER.
FUNCTION getObjectHidden RETURNS LOGICAL IN SUPER.
FUNCTION getObjectInitialized RETURNS LOGICAL IN SUPER.
FUNCTION getObjectName RETURNS CHARACTER IN SUPER.
FUNCTION getObjectPage RETURNS INTEGER IN SUPER.
FUNCTION getObjectParent RETURNS HANDLE IN SUPER.
FUNCTION getObjectVersion RETURNS CHARACTER IN SUPER.
FUNCTION getObjectVersionNumber RETURNS CHARACTER IN SUPER.
FUNCTION getParentDataKey RETURNS CHARACTER IN SUPER.
FUNCTION getPassThroughLinks RETURNS CHARACTER IN SUPER.
FUNCTION getPhysicalObjectName RETURNS CHARACTER IN SUPER.
FUNCTION getPhysicalVersion RETURNS CHARACTER IN SUPER.
FUNCTION getPropertyDialog RETURNS CHARACTER IN SUPER.
FUNCTION getQueryObject RETURNS LOGICAL IN SUPER.
FUNCTION getRunAttribute RETURNS CHARACTER IN SUPER.
FUNCTION getSupportedLinks RETURNS CHARACTER IN SUPER.
FUNCTION getTranslatableProperties RETURNS CHARACTER IN SUPER.
FUNCTION getUIBMode RETURNS CHARACTER IN SUPER.
FUNCTION getUserProperty RETURNS CHARACTER
  (INPUT pcPropName AS CHARACTER) IN SUPER.
FUNCTION instancePropertyList RETURNS CHARACTER
  (INPUT pcPropList AS CHARACTER) IN SUPER.
FUNCTION linkHandles RETURNS CHARACTER
  (INPUT pcLink AS CHARACTER) IN SUPER.
FUNCTION linkProperty RETURNS CHARACTER
  (INPUT pcLink AS CHARACTER,
   INPUT pcPropName AS CHARACTER) IN SUPER.
FUNCTION mappedEntry RETURNS CHARACTER
  (INPUT pcEntry AS CHARACTER,
   INPUT pcList AS CHARACTER,
   INPUT plFirst AS LOGICAL,
   INPUT pcDelimiter AS CHARACTER) IN SUPER.
FUNCTION messageNumber RETURNS CHARACTER
  (INPUT piMessage AS INTEGER) IN SUPER.
FUNCTION propertyType RETURNS CHARACTER
  (INPUT pcPropName AS CHARACTER) IN SUPER.
FUNCTION reviewMessages RETURNS CHARACTER IN SUPER.
FUNCTION setChildDataKey RETURNS LOGICAL
  (INPUT cChildDataKey AS CHARACTER) IN SUPER.
FUNCTION setContainerHidden RETURNS LOGICAL
  (INPUT plHidden AS LOGICAL) IN SUPER.
FUNCTION setContainerSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setContainerSourceEvents RETURNS LOGICAL
  (INPUT pcEvents AS CHARACTER) IN SUPER.
FUNCTION setDataLinksEnabled RETURNS LOGICAL
  (INPUT lDataLinksEnabled AS LOGICAL) IN SUPER.
FUNCTION setDataSource RETURNS LOGICAL
  (INPUT phObject AS HANDLE) IN SUPER.
FUNCTION setDataSourceEvents RETURNS LOGICAL
  (INPUT pcEventsList AS CHARACTER) IN SUPER.
FUNCTION setDataSourceNames RETURNS LOGICAL
  (INPUT pcSourceNames AS CHARACTER) IN SUPER.
FUNCTION setDataTarget RETURNS LOGICAL
  (INPUT pcTarget AS CHARACTER) IN SUPER.
FUNCTION setDataTargetEvents RETURNS LOGICAL
  (INPUT pcEvents AS CHARACTER) IN SUPER.
FUNCTION setDBAware RETURNS LOGICAL
  (INPUT lAware AS LOGICAL) IN SUPER.
FUNCTION setDesignDataObject RETURNS LOGICAL
  (INPUT pcDataObject AS CHARACTER) IN SUPER.
FUNCTION setDynamicObject RETURNS LOGICAL
  (INPUT lTemp AS LOGICAL) IN SUPER.
FUNCTION setInstanceProperties RETURNS LOGICAL
  (INPUT pcPropList AS CHARACTER) IN SUPER.
FUNCTION setLogicalObjectName RETURNS LOGICAL
  (INPUT c AS CHARACTER) IN SUPER.
FUNCTION setLogicalVersion RETURNS LOGICAL
  (INPUT cVersion AS CHARACTER) IN SUPER.
FUNCTION setObjectName RETURNS LOGICAL
  (INPUT pcName AS CHARACTER) IN SUPER.
FUNCTION setObjectParent RETURNS LOGICAL
  (INPUT phParent AS HANDLE) IN SUPER.
FUNCTION setObjectVersion RETURNS LOGICAL
  (INPUT cObjectVersion AS CHARACTER) IN SUPER.
FUNCTION setParentDataKey RETURNS LOGICAL
  (INPUT cParentDataKey AS CHARACTER) IN SUPER.
FUNCTION setPassThroughLinks RETURNS LOGICAL
  (INPUT pcLinks AS CHARACTER) IN SUPER.
FUNCTION setPhysicalObjectName RETURNS LOGICAL
  (INPUT cTemp AS CHARACTER) IN SUPER.
FUNCTION setPhysicalVersion RETURNS LOGICAL
  (INPUT cVersion AS CHARACTER) IN SUPER.
FUNCTION setRunAttribute RETURNS LOGICAL
  (INPUT cRunAttribute AS CHARACTER) IN SUPER.
FUNCTION setSupportedLinks RETURNS LOGICAL
  (INPUT pcLinkList AS CHARACTER) IN SUPER.
FUNCTION setTranslatableProperties RETURNS LOGICAL
  (INPUT pcPropList AS CHARACTER) IN SUPER.
FUNCTION setUIBMode RETURNS LOGICAL
  (INPUT pcMode AS CHARACTER) IN SUPER.
FUNCTION setUserProperty RETURNS LOGICAL
  (INPUT pcPropName AS CHARACTER,
   INPUT pcPropValue AS CHARACTER) IN SUPER.
FUNCTION showmessage RETURNS LOGICAL
  (INPUT pcMessage AS CHARACTER) IN SUPER.
FUNCTION Signature RETURNS CHARACTER
  (INPUT pcName AS CHARACTER) IN SUPER.
FUNCTION getObjectType RETURNS CHARACTER IN SUPER.
  IF VALID-HANDLE(gshRepositoryManager) THEN
  DO:
    IF TRUE THEN
    DO:
      IF NOT
      DYNAMIC-FUNC('prepareInstance':U IN gshRepositoryManager,
                          STRING(THIS-PROCEDURE) + ',':U + STRING(FRAME gDialog:HANDLE),SOURCE-PROCEDURE)
      then
      DO:
        STOP.
      END.
      ASSIGN
        ghADMPropsBuf      = WIDGET-HANDLE(ENTRY(1, THIS-PROCEDURE:ADM-DATA, CHR(1))).
        glADMLoadFromRepos = VALID-HANDLE(ghADMPropsBUF).
    END.
  END.
 IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
 DO:
  CREATE TEMP-TABLE ghADMProps.
  ghADMProps:UNDO    = FALSE.
  ghADMProps:ADD-NEW-FIELD('ObjectName':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ObjectVersion':U, 'CHAR':U, 0, ?,
    'ADM2.2':U).
  ghADMProps:ADD-NEW-FIELD('ObjectType':U, 'CHAR':U, 0, ?,
    'SmartDialog':U).
  ghADMProps:ADD-NEW-FIELD('ContainerType':U, 'CHAR':U, 0, ?,
    'DIALOG-BOX':U).
  ghADMProps:ADD-NEW-FIELD('PropertyDialog':U, 'CHAR':U, 0, ?,
    'adm2/support/visuald.w':U).
  ghADMProps:ADD-NEW-FIELD('QueryObject':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('ContainerHandle':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('InstanceProperties':U, 'CHAR':U, 0, ?,
    'LogicalObjectName,PhysicalObjectName,DynamicObject,RunAttribute,HideOnInit,DisableOnInit,ObjectLayout':U ).
  ghADMProps:ADD-NEW-FIELD('SupportedLinks':U, 'CHAR':U, 0, ?,
    'Data-Target,Data-Source,Page-Target,Update-Source,Update-Target':U).
  ghADMProps:ADD-NEW-FIELD('ContainerHidden':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ObjectInitialized':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('ObjectHidden':U, 'LOGICAL':U, 0, ?, yes).
  ghADMProps:ADD-NEW-FIELD('HideOnInit':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('UIBMode':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ContainerSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('ContainerSourceEvents':U, 'CHAR':U, 0, ?,
    'initializeObject,hideObject,viewObject,destroyObject,enableObject,confirmExit,confirmCancel,confirmOk,isUpdateActive':U).
  ghADMProps:ADD-NEW-FIELD('DataSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('DataSourceEvents':U, 'CHAR':U, 0, ?,
    'dataAvailable,queryPosition,updateState,deleteComplete,fetchDataSet,confirmContinue,confirmCommit,confirmUndo,assignMaxGuess,isUpdatePending':U).
  ghADMProps:ADD-NEW-FIELD('TranslatableProperties':U, 'CHAR':U, 0, ?,
    '':U).
  ghADMProps:ADD-NEW-FIELD('ObjectPage':U, 'INT':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('DBAware':U, 'LOGICAL':U, 0, ?,
                          no).
  ghADMProps:ADD-NEW-FIELD('DesignDataObject':U, 'CHAR':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('DataSourceNames':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('DataTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('DataTargetEvents':U, 'CHARACTER':U, 0, ?,
     'updateState,rowObjectState,fetchBatch,LinkState':U).
  ghADMProps:ADD-NEW-FIELD('LogicalObjectName':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PhysicalObjectName':U, 'CHARACTER':U, ?, ?, "":U).
  ghADMProps:ADD-NEW-FIELD('LogicalVersion':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PhysicalVersion':U, 'CHARACTER':U, ?, ?, "":U).
  ghADMProps:ADD-NEW-FIELD('DynamicObject':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('RunAttribute':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ChildDataKey':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ParentDataKey':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('DataLinksEnabled':U, 'LOGICAL':U, ?, ?, YES).
  ghADMProps:ADD-NEW-FIELD('InactiveLinks':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('InstanceId':U, 'DECIMAL':U).
  ghADMProps:ADD-NEW-FIELD('SuperProcedure':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SuperProcedureMode':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SuperProcedureHandle':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('LayoutPosition':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ClassName':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('RenderingProcedure':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ThinRenderingProcedure':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('Label':U, 'CHAR':U, 0, ?, ?).
END.
FUNCTION getObjectType RETURNS CHARACTER
  ( ) :
  DEFINE VARIABLE cType AS CHARACTER NO-UNDO.
ASSIGN
 ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
 glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
          ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
 cType = ghProp:BUFFER-FIELD('ObjectType':U):BUFFER-VALUE
  NO-ERROR.
  RETURN cType.
END FUNCTION.
IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
DO:
  ghADMProps:ADD-NEW-FIELD('AppService':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ASDivision':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ASHandle':U, 'HANDLE':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ASHasConnected':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ASHasStarted':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ASInfo':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ASInitializeOnRun':U, 'LOGICAL':U, 0, ?, YES).
  ghADMProps:ADD-NEW-FIELD('ASUsePrompt':U, 'LOGICAL':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('BindSignature':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('BindScope':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ServerOperatingMode':U, 'CHAR':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ServerFileName':U,  'CHAR':U, 0, ?,?).
  ghADMProps:ADD-NEW-FIELD('ServerFirstCall':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('NeedContext':U, 'LOGICAL':U, 0, ?, ?).
END.
IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
DO:
  ghADMProps:ADD-NEW-FIELD('ObjectLayout':U,     'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('LayoutOptions':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ObjectEnabled':U,    'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('LayoutVariable':U,   'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('DefaultLayout':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('DisableOnInit':U,    'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('EnabledObjFlds':U,   'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('EnabledObjHdls':U,   'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('FieldSecurity':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('SecuredTokens':U,    'CHARACTER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('AllFieldHandles':U,  'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('AllFieldNames':U,    'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('MinHeight':U,        'DECIMAL':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('MinWidth':U,         'DECIMAL':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('ResizeHorizontal':U, 'LOGICAL':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ResizeVertical':U,   'LOGICAL':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ObjectSecured':U,    'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('ObjectTranslated':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('PopupButtonsInFields':U, 'LOGICAL':U, 0, ?, no).
  ghADMProps:ADD-NEW-FIELD('ColorInfoBG':U,      'INTEGER':U, 0, ?, 10).
  ghADMProps:ADD-NEW-FIELD('ColorInfoFG':U,      'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ColorWarnBG':U,      'INTEGER':U, 0, ?, 3).
  ghADMProps:ADD-NEW-FIELD('ColorWarnFG':U,      'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ColorErrorBG':U,     'INTEGER':U, 0, ?, 12).
  ghADMProps:ADD-NEW-FIELD('ColorErrorFG':U,     'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('BGColor':U,          'INTEGER':U, 0, ?, 12).
  ghADMProps:ADD-NEW-FIELD('FGColor':U,          'INTEGER':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('FieldPopupMapping','CHARACTER':U, 0, ?, '':U).
END.
IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
DO:
  ghADMProps:ADD-NEW-FIELD('CurrentPage':U, 'INT':U, 0, ?, 0).
  ghADMProps:ADD-NEW-FIELD('PendingPage':U, 'INT':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('ContainerTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ContainerTargetEvents':U, 'CHAR':U, 0, ?,
    'exitObject,okObject,cancelObject,updateActive':U).
  ghADMProps:ADD-NEW-FIELD('ContainerToolbarSource':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('ContainerToolbarSourceEvents':U, 'CHAR':U, 0, ?,
    'toolbar,okObject,cancelObject':U).
  ghADMProps:ADD-NEW-FIELD('OutMessageTarget':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('PageNTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('PageSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('FilterSource':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('UpdateSource':U, 'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('UpdateTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('CommitSource':U, 'HANDLE':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('CommitSourceEvents':U, 'CHAR':U, 0, ?,
          'commitTransaction,undoTransaction':U).
  ghADMProps:ADD-NEW-FIELD('CommitTarget':U, 'CHAR':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('CommitTargetEvents':U, 'CHAR':U, 0, ?, 'rowObjectState':U).
  ghADMProps:ADD-NEW-FIELD('StartPage':U, 'INT':U, 0, ?, ?).
  ghADMProps:ADD-NEW-FIELD('RunMultiple':U, 'LOGICAL':U, 0, ?, NO).
  ghADMProps:ADD-NEW-FIELD('WaitForObject':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('DynamicSDOProcedure':U, 'CHAR':U, 0, ?,
      'adm2/dyndata.w':U).
  ghADMProps:ADD-NEW-FIELD('RunDOOptions':U, 'CHARACTER':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('InitialPageList':U, 'CHARACTER':U, 0, ?, '':U).
  ghADMProps:ADD-NEW-FIELD('WindowFrameHandle':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('Page0LayoutManager':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('MultiInstanceSupported':U, 'LOGICAL':U, ?, ? , NO ).
  ghADMProps:ADD-NEW-FIELD('MultiInstanceActivated':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('ContainerMode':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SavedContainerMode':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('SdoForeignFields':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('NavigationSource':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('NavigationTarget':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PrimarySdoTarget':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('NavigationSourceEvents':U, 'CHAR':U, 0, ?,
    'fetchFirst,fetchNext,fetchPrev,fetchLast,startFilter':U).
  ghADMProps:ADD-NEW-FIELD('CallerWindow':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('CallerProcedure':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('CallerObject':U, 'HANDLE':U).
  ghADMProps:ADD-NEW-FIELD('DisabledAddModeTabs':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('ReEnableDataLinks':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('WindowTitleViewer':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('UpdateActive':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('ObjectsCreated':U, 'LOGICAL':U).
  ghADMProps:ADD-NEW-FIELD('InstanceNames':U, 'CHARACTER':U, 0, ?,'':U) .
  ghADMProps:ADD-NEW-FIELD('ClientNames':U, 'CHARACTER':U, 0, ?,'':U) .
  ghADMProps:ADD-NEW-FIELD('ContainedDataObjects':U, 'CHARACTER':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('ContainedAppServices':U, 'CHARACTER':U, 0, ?,'':U).
  ghADMProps:ADD-NEW-FIELD('DataContainer':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('HasDbAwareObjects':U, 'LOGICAL':U, 0, ?,?).
  ghADMProps:ADD-NEW-FIELD('HasDynamicProxy':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('HideOnClose':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('HideChildContainersOnClose':U, 'LOGICAL':U, 0, ?,?).
  ghADMProps:ADD-NEW-FIELD('HasObjectMenu':U, 'LOGICAL':U, 0, ?,NO).
  ghADMProps:ADD-NEW-FIELD('RequiredPages':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('RemoveMenuOnHide':U, 'LOGICAL':U, 0, ?, TRUE).
  ghADMProps:ADD-NEW-FIELD('ProcessList':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PageLayoutInfo':U, 'CHARACTER':U).
  ghADMProps:ADD-NEW-FIELD('PageTokens':U, 'CHARACTER':U).
END.
DEFINE VARIABLE ghContainer AS HANDLE NO-UNDO.
ghContainer = FRAME gDialog:HANDLE.
    IF NOT glADMLoadFromRepos THEN
      RUN start-super-proc ("adm2/smart.p":U).
    DEFINE VARIABLE cObjectName AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE iStart      AS INTEGER    NO-UNDO.
  IF NOT VALID-HANDLE(WIDGET-HANDLE(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1)))) THEN
  DO:
    ghADMProps:TEMP-TABLE-PREPARE('ADMProps':U).
    ghADMPropsBuf = ghADMProps:DEFAULT-BUFFER-HANDLE.
    ghADMPropsBuf:BUFFER-CREATE().
    THIS-PROCEDURE:ADM-DATA = STRING(ghADMPropsBuf) + CHR(1) + CHR(1).
    cObjectName =  'LogicalObjectName,PhysicalObjectName,DynamicObject,RunAttribute,HideOnInit,DisableOnInit,ObjectLayout':U.
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('InstanceProperties':U):BUFFER-VALUE = cObjectName
 .
    ASSIGN cObjectName = REPLACE(THIS-PROCEDURE:FILE-NAME, "~\":U, "~/":U)
           iStart = R-INDEX(cObjectName, "~/":U) + 1
           cObjectName =
                IF R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U) <= iStart THEN
                   SUBSTR(cObjectName, iStart)
                ELSE
                   SUBSTR(cObjectName,
                          iStart,
                          R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U) - iStart).
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ObjectName':U):BUFFER-VALUE = cObjectName
 .
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ContainerHandle':U):BUFFER-VALUE = FRAME gDialog:HANDLE
 .
  END.
  ELSE DO:
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ObjectType':U):BUFFER-VALUE = 'SmartDialog':U
  ghProp:BUFFER-FIELD('ContainerType':U):BUFFER-VALUE = 'DIALOG-BOX':U
  ghProp:BUFFER-FIELD('PhysicalVersion':U):BUFFER-VALUE = '':U
  ghProp:BUFFER-FIELD('PhysicalObjectName':U):BUFFER-VALUE = (IF '':U <> '':U THEN '':U ELSE THIS-PROCEDURE:FILE-NAME)
    .
  END.
PROCEDURE adm-clone-props :
  DEFINE VARIABLE hReposBuffer AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hPropTable   AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hBuffer      AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hTable       AS HANDLE     NO-UNDO.
  hReposBuffer = WIDGET-H(ENTRY(1,THIS-PROCEDURE:ADM-DATA,CHR(1))).
  IF VALID-HANDLE(hReposBuffer) AND hReposBuffer:NAME <> 'ADMProps':U THEN
  DO:
    hReposBuffer:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(THIS-PROCEDURE) + '")':U)
    NO-ERROR.
    IF hReposBuffer:AVAIL THEN
    DO:
      CREATE TEMP-TABLE hPropTable.
      hPropTable:CREATE-LIKE(hReposBuffer).
      hPropTable:TEMP-TABLE-PREPARE('ADMProps':U).
      hBuffer = hPropTable:DEFAULT-BUFFER-HANDLE.
      hBuffer:BUFFER-CREATE().
      hBuffer:BUFFER-COPY(hReposBuffer).
      dynamic-function("deleteProperties":U IN TARGET-PROCEDURE)
 .
      THIS-PROCEDURE:ADM-DATA = STRING(hBuffer) + CHR(1) + CHR(1).
    END.
  END.
END PROCEDURE.
PROCEDURE start-super-proc :
  DEFINE INPUT PARAMETER pcProcName AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE        hProc      AS HANDLE     NO-UNDO.
  hProc = SESSION:FIRST-PROCEDURE.
  DO WHILE VALID-HANDLE(hProc) AND hProc:FILE-NAME NE pcProcName:
    hProc = hProc:NEXT-SIBLING.
  END.
  IF NOT VALID-HANDLE(hProc) THEN
    RUN VALUE(pcProcName) PERSISTENT SET hProc.
  THIS-PROCEDURE:ADD-SUPER-PROCEDURE(hProc, SEARCH-TARGET).
  RETURN.
END PROCEDURE.
  DEFINE VARIABLE cAppService          AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cASDivision          AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cServerOperatingMode AS CHARACTER  NO-UNDO.
  IF NOT glADMLoadFromRepos THEN
    RUN start-super-proc("adm2/appserver.p":U).
 cAppService = DYNAMIC-FUNC('getAppService':U IN TARGET-PROCEDURE)
 .
  IF SESSION:REMOTE THEN
  DO:
    ASSIGN cAppService          = '':U
           cASDivision          = 'Server':U
           cServerOperatingMode = CAPS(SESSION:SERVER-OPERATING-MODE).
  END.
  ELSE IF cAppService = '':U THEN
    ASSIGN cAppService  = '':U.
  IF cASDivision = '':U THEN
     cServerOperatingMode = 'NONE':U.
  ELSE
   DYNAMIC-FUNC('setASDivision':U IN TARGET-PROCEDURE,cASDivision)
 .
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('ServerOperatingMode':U):BUFFER-VALUE = cServerOperatingMode
 .
   DYNAMIC-FUNC('setAppService':U IN TARGET-PROCEDURE,cAppService)
 .
DEFINE VARIABLE cFields AS CHARACTER NO-UNDO.
IF NOT glADMLoadFromRepos THEN
  RUN start-super-proc ("adm2/visual.p":U).
  cFields =  REPLACE("Btn_OK":U, " ":U, ",":U).
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('EnabledObjFlds':U):BUFFER-VALUE = cFields
 .
  IF VALID-HANDLE(gshSessionManager) THEN
  DO:
    ON HELP OF FRAME gDialog ANYWHERE
      RUN contextHelp IN gshSessionManager (INPUT THIS-PROCEDURE, INPUT FOCUS).
  END.
  ON CTRL-PAGE-UP OF FRAME gDialog ANYWHERE DO:
    RUN processAction IN TARGET-PROCEDURE (INPUT "CTRL-PAGE-UP":U).
  END.
  ON CTRL-PAGE-DOWN OF FRAME gDialog ANYWHERE DO:
    RUN processAction IN TARGET-PROCEDURE (INPUT "CTRL-PAGE-DOWN":U).
  END.
IF NOT glADMLoadFromRepos THEN
DO:
  RUN start-super-proc("adm2/containr.p":U).
  RUN modifyListProperty IN TARGET-PROCEDURE
                         (TARGET-PROCEDURE,
                          'Add':U,
                          'ContainerSourceEvents':U,
                          'initializeDataObjects':U).
  IF  CAN-DO(dynamic-function("getSupportedLinks":U IN TARGET-PROCEDURE)
 ,'data-target':U)
  AND CAN-DO(dynamic-function("getSupportedLinks":U IN TARGET-PROCEDURE)
 ,'data-source':U) THEN
    RUN modifyListProperty IN TARGET-PROCEDURE
                           (TARGET-PROCEDURE,
                            'Add':U,
                            'ContainerSourceEvents':U,
                            'buildDataRequest':U).
  IF NOT CAN-DO(dynamic-function("getSupportedLinks":U IN TARGET-PROCEDURE)
 ,'containertoolbar-target':U) THEN
    RUN modifyListProperty IN TARGET-PROCEDURE
                          (TARGET-PROCEDURE,
                           'Add':U,
                           'SupportedLinks':U,
                           'ContainerToolbar-Target':U).
END.
PAUSE 0 BEFORE-HIDE.
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('WindowFrameHandle':U):BUFFER-VALUE = FRAME gDialog:handle
 .
ASSIGN
   ghProp = WIDGET-H(ENTRY(1,TARGET-PROCEDURE:ADM-DATA,CHR(1)))
   glADMOk = IF ghProp:NAME = 'ADMProps':U OR (ghProp:AVAIL AND ghProp:BUFFER-FIELD('Target':U):BUFFER-VALUE = TARGET-PROCEDURE) THEN TRUE
             ELSE ghProp:FIND-FIRST('WHERE Target = WIDGET-H("':U + STRING(TARGET-PROCEDURE) + '")':U)
  ghProp:BUFFER-FIELD('DataContainer':U):BUFFER-VALUE = TRUE
 .
ASSIGN
       FRAME gDialog:SCROLLABLE       = FALSE
       FRAME gDialog:HIDDEN           = TRUE.
ASSIGN
       mes:AUTO-RESIZE IN FRAME gDialog      = TRUE.
ON WINDOW-CLOSE OF FRAME gDialog
DO:
    APPLY "END-ERROR":U TO SELF.
  END.
DEFINE VARIABLE iStartPage AS INTEGER NO-UNDO.
IF THIS-PROCEDURE:PERSISTENT THEN
DO:
  MESSAGE "A SmartDialog is not intended to be run " + CHR(10) +
    "Persistent or to be placed in another ":U + CHR(10) +
    "SmartObject at AppBuilder design time."
    VIEW-AS ALERT-BOX ERROR.
  RUN disable_UI.
  DELETE PROCEDURE THIS-PROCEDURE.
  RETURN.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME gDialog:PARENT eq ?
  THEN FRAME gDialog:PARENT = ACTIVE-WINDOW.
RUN createObjects.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN initializeObject.
  WAIT-FOR GO OF FRAME gDialog focus Btn_OK.
END.
RUN destroyObject.
PROCEDURE adm-create-objects :
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME gDialog.
END PROCEDURE.
PROCEDURE enable_UI :
        mes = "Слив запрещен! Объем по ТТН " + p-1 + " л превышает свободный объем резервуара " + p-2 + ". " + chr(10) +
          "Проверьте введенные данные из ТТН или значение фактического объема в резервуаре".
  DISPLAY mes
    WITH FRAME gDialog.
  ENABLE Btn_OK
      WITH FRAME gDialog.
  VIEW FRAME gDialog.
END PROCEDURE.
