block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcodeinf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rcodeinf.p $":U .
define variable vss-description as character no-undo init "".
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
DEFINE VARIABLE chrRCodeFile AS CHARACTER FORMAT "x(60)" LABEL "File".
DEFINE TEMP-TABLE RCodeInfo NO-UNDO
 FIELD FileName      AS CHARACTER LABEL "Name"      FORMAT "x(50)"
 FIELD Reliability   AS LOGICAL   LABEL ""          FORMAT "/?"
 FIELD CompVersion   AS INTEGER   LABEL "Version"   FORMAT ">>>>9"
 FIELD RCodeSize     AS INTEGER   LABEL "Size"    FORMAT ">>>>>>9"
 FIELD RCodeLength   AS INTEGER   LABEL "Length"    FORMAT ">>>>>>9"
 FIELD RCodeCRC      AS INTEGER   LABEL "CRC"       FORMAT ">>>>9"
 FIELD InitSegment   AS INTEGER   LABEL "Initial"   FORMAT ">>>>9"
 FIELD ActionSegment AS INTEGER   LABEL "Action"    FORMAT ">>>>9"
 FIELD ECodeSegment  AS CHARACTER LABEL "E-Code"    FORMAT "x(23)"
 FIELD DebugSegment  AS INTEGER   LABEL "Debug"     FORMAT ">>>>9"
 FIELD IProcNumber   AS INTEGER   LABEL "Int-Proc#" FORMAT ">>9"
 FIELD IProcSegment  AS CHARACTER LABEL "Int-Proc"  FORMAT "x(50)" VIEW-AS EDITOR SIZE 37 BY 1.5 SCROLLBAR-VERTICAL
 FIELD FrameNumber   AS INTEGER   LABEL "Frame#"    FORMAT ">>9"
 FIELD FrameSegment  AS CHARACTER LABEL "Frame"     FORMAT "x(50)" VIEW-AS EDITOR SIZE 37 BY 1.5 SCROLLBAR-VERTICAL
 FIELD Languages     AS CHARACTER LABEL "Languages" FORMAT "x(50)"
 FIELD TextSegment   AS CHARACTER LABEL "Text"      FORMAT "x(50)" VIEW-AS EDITOR SIZE 37 BY 1.5 SCROLLBAR-VERTICAL
 FIELD CodePage      AS CHARACTER LABEL "Code Page" FORMAT "x(9)"
 INDEX FileName IS UNIQUE PRIMARY
         FileName.
DEFINE VARIABLE chrSaveFile AS CHARACTER NO-UNDO.
DEFINE VARIABLE logResult    AS LOGICAL   NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE STREAM strRCodeFile.
DEFINE STREAM strTemp.
PROCEDURE GetShort:
  DEFINE  INPUT PARAMETER intPosition AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER intResult   AS INTEGER NO-UNDO.
  DEFINE VARIABLE rawRecord AS RAW NO-UNDO.
  DEFINE VARIABLE intByte AS INTEGER NO-UNDO.
  DEFINE VARIABLE i AS INTEGER NO-UNDO.
  ASSIGN LENGTH(rawRecord) = 2.
  SEEK   STREAM strRCodeFile TO intPosition.
  IMPORT STREAM strRCodeFile UNFORMATTED rawRecord.
  ASSIGN intResult = 0.
  DO i=2 TO 1 BY -1:
    ASSIGN intByte=GET-BYTE(rawRecord,i).
    IF intByte < 0 THEN ASSIGN intByte = 256 + intByte.
    ASSIGN intResult = intResult * 256 + intByte.
  END.
END PROCEDURE.
PROCEDURE GetLong:
  DEFINE  INPUT PARAMETER intPosition AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER intResult   AS INTEGER NO-UNDO.
  DEFINE VARIABLE rawRecord AS RAW NO-UNDO.
  DEFINE VARIABLE intByte AS INTEGER NO-UNDO.
  DEFINE VARIABLE i AS INTEGER NO-UNDO.
  ASSIGN LENGTH(rawRecord) = 4.
  SEEK   STREAM strRCodeFile TO intPosition.
  IMPORT STREAM strRCodeFile UNFORMATTED rawRecord.
  ASSIGN intResult = 0.
  DO i=4 TO 1 BY -1:
    ASSIGN intByte=GET-BYTE(rawRecord,i).
    IF intByte < 0 THEN ASSIGN intByte = 256 + intByte.
    ASSIGN intResult = intResult * 256 + intByte.
  END.
END PROCEDURE.
PROCEDURE RCodeInfo :
  DEFINE  INPUT PARAMETER chrFileName AS CHARACTER NO-UNDO.
  DEFINE PARAMETER BUFFER RCodeInfo FOR RCodeInfo.
  DEFINE VARIABLE rawRecord AS RAW NO-UNDO.
  DEFINE VARIABLE intFileOffset AS INTEGER   NO-UNDO.
  DEFINE VARIABLE intValue      AS INTEGER   NO-UNDO.
  DEFINE VARIABLE chrValue      AS CHARACTER NO-UNDO.
  INPUT  STREAM strRCodeFile FROM VALUE(chrFileName).
  run getlong
    (input 0
    ,output intvalue
    ).
  IF intValue <> 1456395017 THEN
  DO:
    MESSAGE
      chrFileName "has wrong format." SKIP
      "This procedure can analyze the r-code of V7 and above." skip
      VIEW-AS ALERT-BOX ERROR.
    INPUT STREAM strRCodeFile CLOSE.
  END.
  ELSE
  DO TRANSACTION:
    FIND FIRST RCodeInfo WHERE RCodeInfo.FileName=chrFileName NO-LOCK NO-ERROR.
    IF NOT AVAILABLE RCodeInfo THEN
    DO:
      CREATE RCodeInfo.
      ASSIGN RCodeInfo.FileName=chrFileName.
    END.
    RUN GetShort(14, OUTPUT RCodeInfo.CompVersion).
    RUN GetLong (64, OUTPUT RCodeInfo.RCodeLength).
    RUN GetShort(72, OUTPUT RCodeInfo.InitSegment).
    RUN GetShort(98, OUTPUT RCodeInfo.ActionSegment).
    ASSIGN chrValue="".
    DO i=100 TO 106 BY 2:
      RUN GetShort(i,OUTPUT intValue).
      ASSIGN chrValue = chrValue + MIN(chrValue,",")
                      + (IF intValue=? THEN "?" ELSE STRING(intValue)).
    END.
    ASSIGN RCodeInfo.ECodeSegment=chrValue.
    RUN GetShort(108,OUTPUT RCodeInfo.DebugSegment).
    RUN GetShort(110,OUTPUT RCodeInfo.IProcNumber).
    RUN GetShort(112,OUTPUT RCodeInfo.FrameNumber).
    ASSIGN intFileOffset = 112
           chrValue="".
    DO i=1 TO IProcNumber:
      ASSIGN intFileOffset = intFileOffset + 8.
      RUN GetShort(intFileOffset,OUTPUT intValue).
      ASSIGN chrValue = chrValue + MIN(chrValue,",")
                      + (IF intValue=? THEN "?" ELSE STRING(intValue)).
    END.
    ASSIGN RCodeInfo.IProcSegment=chrValue.
    IF FrameNumber > 0 THEN
    ASSIGN intFileOffset = intFileOffset + 8
           FrameNumber = FrameNumber - 1.
    ASSIGN chrValue = "".
    DO i=1 TO FrameNumber:
      ASSIGN intFileOffset = intFileOffset + 8.
      RUN GetShort(intFileOffset,OUTPUT intValue).
      ASSIGN chrValue = chrValue + MIN(chrValue,",")
                      + (IF intValue=? THEN "?" ELSE STRING(intValue)).
    END.
    ASSIGN RCodeInfo.FrameSegment=chrValue
           intFileOffset = intFileOffset + 2
           chrValue = "".
    DO i=1 TO 1:
      ASSIGN intFileOffset = intFileOffset + 8.
      RUN GetShort(intFileOffset,OUTPUT intValue).
      ASSIGN chrValue = chrValue + MIN(chrValue,",")
                      + (IF intValue=? THEN "?" ELSE STRING(intValue)).
    END.
    ASSIGN RCodeInfo.TextSegment=chrValue
           LENGTH(rawRecord) = 16
           intFileOffset = intFileOffset + 2.
    SEEK STREAM strRCodeFile TO intFileOffset.
    IMPORT STREAM strRCodeFile UNFORMATTED rawRecord.
    ASSIGN RCodeInfo.CodePage=GET-STRING(rawRecord,1)
           intFileOffset=intFileOffset + 103.
    RUN GetShort(intFileOffset,OUTPUT RCodeInfo.RCodeCRC).
    SEEK STREAM strRCodeFile TO END.
    ASSIGN RCodeInfo.RCodeSize=SEEK(strRCodeFile)
    RCODE-INFO:FILE-NAME = chrFileName NO-ERROR.
    ASSIGN RCodeInfo.Reliability=(RCodeInfo.RCodeCRC=RCODE-INFO:CRC-VALUE)
                             AND (RCodeInfo.CodePage=RCODE-INFO:CODEPAGE)
           RCodeInfo.Languages = RCODE-INFO:LANGUAGES
           LENGTH(rawRecord) = 0.
  END.
  INPUT STREAM strRCodeFile CLOSE.
END PROCEDURE.
DEFINE VARIABLE chrTitle    AS CHARACTER     NO-UNDO.
DEFINE VARIABLE chrFileName AS CHARACTER     NO-UNDO.
DEFINE VARIABLE chrFileAttr AS CHARACTER     NO-UNDO.
DEFINE VARIABLE chrLanguage LIKE RCodeInfo.Languages NO-UNDO.
DEFINE VARIABLE rowRCodeInfo AS ROWID NO-UNDO.
DEFINE QUERY qryRCodeInfo FOR RCodeInfo.
DEFINE BROWSE brwRCodeInfo
        QUERY qryRCodeInfo DISPLAY
                RCodeInfo.FileName
                RCodeInfo.RCodeSize
                RCodeInfo.Reliability
WITH 5 DOWN WIDTH 65 separators .
DEFINE BUTTON Btn_Add
       LABEL "&Add"
       SIZE 12 BY 1.
DEFINE BUTTON Btn_Clear
       LABEL "&Clear":L
       SIZE 12 BY 1.
DEFINE BUTTON Btn_Save
       LABEL "&Save":L
       SIZE 12 BY 1.
DEFINE BUTTON Btn_Exit AUTO-GO
       LABEL "Exit":L
       SIZE 12 BY 1.
DEFINE FRAME frmRCodeFiles SKIP(0.3)
    brwRCodeInfo AT ROW 1.2 COL 1 SKIP(0.3)
    Btn_Add      AT ROW 1.5 COL 66.5
    Btn_Clear    AT ROW 2.7 COL 66.5
    Btn_Save     AT ROW 3.9 COL 66.5
    Btn_Exit     AT ROW 5.1 COL 66.5
    RCodeInfo.CompVersion COLON 12         RCodeInfo.InitSegment   COLON 40
    RCodeInfo.RCodeLength COLON 12         RCodeInfo.ActionSegment COLON 40
    RCodeInfo.CodePage    COLON 12         RCodeInfo.DebugSegment  COLON 40
    RCodeInfo.RCodeCRC    COLON 12         RCodeInfo.ECodeSegment  COLON 40
    RCodeInfo.IProcNumber COLON 12         RCodeInfo.IProcSegment  COLON 40
    RCodeInfo.FrameNumber COLON 12         RCodeInfo.FrameSegment  COLON 40
    chrLanguage  FORMAT "x(15)"
           VIEW-AS COMBO-BOX COLON 12        RCodeInfo.TextSegment   COLON 40
WITH
     VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D
     DEFAULT-BUTTON Btn_Add
     CANCEL-BUTTON  Btn_Exit
     KEEP-TAB-ORDER
     CENTERED ROW 1
      TITLE "R-Code List"
     .
PROCEDURE OnOpenQuery :
  run display-dependent-info in this-procedure .
END PROCEDURE.
ON VALUE-CHANGED OF brwRCodeInfo
DO:
  run display-dependent-info in this-procedure .
END.
procedure display-dependent-info :
  do
  on error undo, return error
  :
    if available RCodeInfo then do:
      ASSIGN chrLanguage = ENTRY(1,RCodeInfo.Languages)
            chrLanguage:LIST-ITEMS IN FRAME frmRCodeFiles = RCodeInfo.Languages.
      DISPLAY chrLanguage WITH FRAME frmRCodeFiles.
      DISPLAY RCodeInfo
      EXCEPT RCodeInfo.FileName
              RCodeInfo.RCodeSize
              RCodeInfo.Languages
              RCodeInfo.Reliability
      WITH FRAME frmRCodeFiles.
    end.
  end.
end procedure.
ON CHOOSE OF Btn_Add IN FRAME frmRCodeFiles
DO:
  ASSIGN chrRCodeFile="ALL":U
         chrTitle="Please Select a R-Code File or Type " + "ALL.":U.
  SYSTEM-DIALOG GET-FILE chrRCodeFile
      TITLE chrTitle
      FILTERS "R-code (*.r)" "*.r"
      USE-FILENAME
      UPDATE logResult.
  IF logResult THEN
  DO:
    ASSIGN i = MAX(R-INDEX(chrRCodeFile,"/"),
                   R-INDEX(chrRCodeFile,"~\"))
           chrFileName = SUBSTRING(chrRCodeFile,i + 1).
    IF chrFileName = "ALL" THEN
    DO:
      ASSIGN logResult = SESSION:SET-WAIT-STATE("GENERAL").
      INPUT STREAM strTemp FROM OS-DIR(SUBSTRING(chrRCodeFile,1,i - 1)).
      REPEAT:
        IMPORT STREAM strTemp chrFileName chrRCodeFile chrFileAttr.
        IF CAN-DO(chrFileAttr,"F")
        AND SUBSTRING(chrFileName,LENGTH(chrFileName) - 1)=".r" THEN
        DO:
          ASSIGN chrRCodeFile=LC(chrRCodeFile).
          RUN RCodeInfo(chrRCodeFile, BUFFER RCodeInfo).
        END.
      END.
      INPUT STREAM strTemp CLOSE.
      ASSIGN logResult = SESSION:SET-WAIT-STATE("")
             rowRCodeInfo=?.
    END.
    ELSE
    IF SEARCH(chrRCodeFile)<>? THEN
    DO:
      RUN RCodeInfo(chrRCodeFile, BUFFER RCodeInfo).
      ASSIGN rowRCodeInfo=ROWID(RCodeInfo).
    END.
  END.
  OPEN QUERY qryRCodeInfo FOR EACH RCodeInfo NO-LOCK.
  IF NUM-RESULTS("qryRCodeInfo":U) > 0 THEN
  ASSIGN logResult = brwRCodeInfo:SCROLL-TO-CURRENT-ROW().
  IF rowRCodeInfo <> ? THEN
  REPOSITION qryRCodeInfo TO ROWID rowRCodeInfo NO-ERROR.
  RUN OnOpenQuery.
END.
ON CHOOSE OF Btn_Clear IN FRAME frmRCodeFiles
DO:
  IF AVAILABLE RCodeInfo THEN
  DO TRANSACTION:
    DELETE RCodeInfo.
    ASSIGN logResult = brwRCodeInfo:DELETE-CURRENT-ROW().
  END.
END.
ON CHOOSE OF Btn_Save IN FRAME frmRCodeFiles
DO:
  ASSIGN chrTitle="Save to File."
         chrSaveFile=OS-GETENV("CLIENTMON").
  IF chrSaveFile = ? THEN chrSaveFile="client.mon".
  SYSTEM-DIALOG GET-FILE chrSaveFile
      TITLE chrTitle
      FILTERS "Monitor File (*.mon)" "*.mon"
      SAVE-AS
      USE-FILENAME
      UPDATE logResult.
  IF logResult THEN
  DO:
    ASSIGN chrFileAttr=FILL("-":U,64).
    OUTPUT STREAM strTemp TO VALUE(chrSaveFile) APPEND.
    FOR EACH RCodeInfo NO-LOCK:
      PUT STREAM strTemp UNFORMATTED                  SKIP
         chrFileAttr   SKIP   RCodeInfo.FileName      SKIP
         CompVersion:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.CompVersion   SKIP
           "Size" TO 12 ": "  RCodeInfo.RCodeSize     SKIP
         RCodeLength:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.RCodeLength   SKIP
            CodePage:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.CodePage      SKIP
            RCodeCRC:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.RCodeCRC      SKIP
         InitSegment:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.InitSegment   SKIP
       ActionSegment:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.ActionSegment SKIP
        ECodeSegment:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.ECodeSegment  SKIP
        DebugSegment:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.DebugSegment  SKIP
         IProcNumber:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.IProcNumber   SKIP.
      IF RCodeInfo.IProcNumber > 0 THEN
      PUT STREAM strTemp UNFORMATTED
        IProcSegment:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.IProcSegment  SKIP.
      PUT STREAM strTemp UNFORMATTED
         FrameNumber:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.FrameNumber   SKIP.
      IF RCodeInfo.FrameNumber > 0 THEN
      PUT STREAM strTemp UNFORMATTED
        FrameSegment:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.FrameSegment  SKIP.
      PUT STREAM strTemp UNFORMATTED
         TextSegment:LABEL IN FRAME frmRCodeFiles TO 12 ": " RCodeInfo.TextSegment   SKIP
       "Languages" TO 12 ": " RCodeInfo.Languages     SKIP.
      IF RCodeInfo.Reliability <> TRUE THEN
      PUT STREAM strTemp UNFORMATTED
        "Warning: Information is unreliable." SKIP.
    END.
    OUTPUT STREAM strTemp CLOSE.
  END.
END.
VIEW FRAME frmRCodeFiles .
DO
ON error  undo, leave
on endkey undo,  leave
on stop   undo,  retry
:
  ENABLE
    brwRCodeInfo
    Btn_Add
    Btn_Save
    Btn_Exit
    IProcSegment
    FrameSegment
    TextSegment
    chrLanguage
    with frame frmRCodeFiles .
  assign
    IProcSegment :read-only = true
    FrameSegment :read-only = true
    TextSegment  :read-only = true
  .
  brwRCodeInfo :set-repositioned-row( 3, "CONDITIONAL" ) .
  APPLY "ENTRY" TO Btn_Add .
  WAIT-FOR GO OF FRAME frmRCodeFiles .
END.
