/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Счетчик

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


{ rep/repfrm.i def}                                                      - обьявление фрайма
{ rep/repfrm.i on  {кратность счетчика} {lable-счетчика} {кнопка stop} } - аналог w a i t - o n
{ rep/repfrm.i disp {счетчик} {текстовая строка1} {текстовая строка2} {текстовая строка3} } - аналог r - m e s s . i
{ rep/repfrm.i off}                                                      - аналог w a i t - o f f

Creation date: 10/24/01 4:51

*/

&If "{1}" = "def" &then
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .

DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.

DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.

DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.      
  mFramHandle = frame InfoFrame:handle.

  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError"). 
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
/* ***************  Runtime Attributes and UIB Settings  ************** */
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.

END.
&endif

&If "{1}" = "on" &then
/*
2- {кратность счетчика}
3- {lable-счетчика} название    счетчика , если не задан то "Обработано записей"  .
4- {кнопка stop}
5- {имя Stream  в который будет записываться фраза }
*/
&glob user-stream-name {5}
  &if "{2}" <> "" &then
assign v-account = ( if integer( {2} ) = 0 then 100 else integer( {2} ) ).
  &else
assign v-account = 100.
  &endif
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError"). 
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
&IF "{3}" <> ""  &then
        Assign  RecordsDone: label = {3} .
&endif

&if "{4}" = "stop"  &then
   v-button-stop = true  .
&else
   v-button-stop = false .
&endif
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.

&endif

&If "{1}" = "disp" &then
/*
параметры
2 = счетчик
3 = текстовая строка1
4 = текстовая строка2
5 = текстовая строка3

*/
&if "{2}" <> "" &then
IF ( {2} modulo v-account = 0 )  then DO: &endif

&if "{3}" <> "" &then
 Assign
    v-kol-spice = (50 - LENGTH({3})) / 2
    RecordsString = fill(' ',v-kol-spice) + string({3})
    .
&endif
&if "{4}" <> "" &then
 Assign
    v-kol-spice = (50 - LENGTH({4})) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string({4})
    .

&endif
&if "{5}" <> "" &then
 Assign
    v-kol-spice = (50 - LENGTH({5})) / 2
    RecordsString3 = fill(' ',v-kol-spice) + string({5})
    .
&endif
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError"). 
          end.
           if mFrameView
           then do:
            DISPLAY
              &if "{2}" <> "" &then  {2} @ RecordsDone  &endif
              &if "{3}" <> "" &then  RecordsString   @ RecordsString   &endif
              &if "{4}" <> "" &then  RecordsString2  @ RecordsString2  &endif
              &if "{5}" <> "" &then  RecordsString3  @ RecordsString3  &endif
              WITH FRAME InfoFrame.
           end.
&if "{2}" <> "" &then
End. &endif
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
           &if "{&user-stream-name}" <> "" &then
           PUT STREAM {&user-stream-name} UNFORMATTED "Процесс формирования отчета прерван пользователем!" SKIP(1).
           &endif
         RETURN error.
         End.
   end.
&endif

&If "{1}" = "off" &then
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
&endif
/* $Workfile$ e n d */