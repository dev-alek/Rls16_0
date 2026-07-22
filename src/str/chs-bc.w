&scop FRAME-NAME     d-chs-bc
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно просмотра информации о бар-коде

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/

define input        parameter parparentproc as handle                   no-undo.
define input        parameter f-title       as character                no-undo.
define input        parameter add-sens      as logical                  no-undo.
define input        parameter not-term      as logical                  no-undo. /*Если ?, то проверяться не будет*/
define input        parameter in-add        as logical                  no-undo. /*Включаем ли режим добавления-изменения бар-кода*/
define output       parameter b-c           as character                no-undo. /* обрабатываемый бар-код */
define output       parameter rate          like doc-line.cli-base-rate no-undo. /* коэффициент для единиц из бар-кода        */
define output       parameter ret-mode      as character                no-undo. /*режим обработки бар-кода*/
define input-output parameter add-scan      as logical initial no       no-undo.
define input-output parameter bar-str       like prod-bc.b-str          no-undo. /* возвращаем, чтобы при следущем заведении бар-кода они видели предидущий*/

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Окно просмотра информации о бар-коде" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ str/tt-tax.i new }
{ str/lib-trn.i  }
{ str/libbcrcn.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }

define variable b-c-g   AS int              NO-UNDO. /* обрабатываемый собственный бар-код */

define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.                  /* тип параметра конфигурации */
define variable varPlace AS LOG NO-UNDO.
/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-exit
     LABEL "&Ввод ":L
     SIZE 9.75 BY 1.15.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 9.75 BY 1.15.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 9.75 BY 1.15.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
  add-scan VIEW-AS TOGGLE-BOX LABEL "Копировать кол-во со сканера"
  bar-str LABEL "КОД" AT ROW 2 COL 10 COLON-ALIGNED SKIP
  b-exit AT ROW 4 COL 2.5
  b-quit AT ROW 4 COL 12.5
  b-help AT ROW 4 COL 22.5
  SPACE(0) SKIP(0.38)
  WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D SCROLLABLE
         TITLE "Строка":L
         DEFAULT-BUTTON b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME {&frame-name}:SCROLLABLE = FALSE.

/* ************************  Control Triggers  ************************ */

{ str/bc-res.i "check" "mes" }
{ str/libbcrcn.i }
ON LEAVE OF add-scan IN FRAME {&frame-name} DO:
   ASSIGN FRAME {&frame-name} add-scan.
END.

ON CHOOSE OF b-quit IN FRAME {&frame-name} /* Отмена */ DO:
   ASSIGN
   b-c = ?
   rate = ?.
END.

on end-error, stop of frame {&frame-name} do:
   apply "choose" to b-quit in frame {&frame-name}.
   return no-apply.
end.

ON return, MOUSE-SELECT-DBLCLICK OF bar-str IN FRAME {&frame-name} DO:
apply "choose" to b-exit in frame {&frame-name}.
return no-apply.
END.

ON CHOOSE OF b-exit IN FRAME {&frame-name} DO:

   { str/sclspref.i }
   IF INPUT FRAME {&frame-name} bar-str = "" THEN DO:
      MESSAGE "Введите бар-код."
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
      RETURN NO-APPLY.
   END.
   /*Если знак вопроса, то вообще ничего не проверяем.
     Если yes, то наравне с терминальным удовдолетворит и корневой*/
   if not-term ne ? then DO:
      ASSIGN bar-str.
      RUN check-code in this-procedure ( input bar-str
                                        ,input 0
                                        ,input 1
                                        ,input  v-cntxp-doc-prt
                                        ,input varscales-pref
                                        ,input varpgscales-pref
                                        ,output varPlace
                                        ,output b-c-g
                                        ,output rate) NO-ERROR.
      /*Случай когда вполне удоволетворит и корневой признак*/
      IF RETURN-VALUE = "Ссылка не на подробный признак." AND not-term THEN
         RUN check-code  in this-procedure ( input bar-str
                                            ,input 0
                                            ,input 1
                                            ,input NO
                                            ,input varscales-pref
                                            ,input varpgscales-pref
                                            ,output varPlace
                                            ,output b-c-g
                                            ,output rate) NO-ERROR.
         IF ERROR-STATUS:ERROR THEN DO:
         IF RETURN-VALUE <> "" THEN DO:
            MESSAGE RETURN-VALUE
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
         END.
         ELSE DO:
            MESSAGE "Ошибка из процедуры проверки бар-кода."
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
         END.
         RETURN NO-APPLY.
      END.
      IF RETURN-VALUE <> ""      AND
         RETURN-VALUE <> "PLACE" THEN DO:
           MESSAGE RETURN-VALUE
              VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
      END.
      assign ret-mode = return-value.
      b-c = string(b-c-g).
   END.
   ELSE b-c = INPUT FRAME {&frame-name} bar-str.
   APPLY "go" TO FRAME {&frame-name}.
END.


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, return
   ON END-KEY UNDO MAIN-BLOCK, return:
frame {&frame-name}:title = f-title.
DISPLAY bar-str add-scan WITH FRAME {&frame-name}.
IF in-add THEN ENABLE add-scan WITH FRAME {&FRAME-NAME}.
ELSE HIDE add-scan IN FRAME {&frame-name}.
ENABLE bar-str b-help b-quit b-exit WITH FRAME {&FRAME-NAME}.
WAIT-FOR GO OF FRAME {&FRAME-NAME} focus bar-str.
END.

RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.


&UNDEFINE FRAME-NAME