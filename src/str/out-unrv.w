&Scoped-define FRAME-NAME     d-out-unrv
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и снятие установок резерва по РН

Автор: Чернова Светлана Александровна
Дата создания: 10/14/07
Author: Svetlana Chernova
Creation date: 10/14/07



*/

/* ***************************  Definitions  ************************** */

define input parameter parparentproc as   handle              no-undo.
define input parameter pardoc-code   like ub.trn-doc.doc-code no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Просмотр и снятие установок резерва по РН".
define variable varlog as logical no-undo.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }


/* ***********************  Control Definitions  ********************** */
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1.

DEFINE BUTTON b-unrv AUTO-GO
     LABEL "С&нять":L
     SIZE 10 BY 1.

DEFINE VARIABLE period AS INTEGER FORMAT "->9":U INITIAL 0
     LABEL "С&рок резерва (дней)"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
    b-save AT ROW 1 COL 1
  b-quit AT ROW 1 COL 11


  trn-doc.doc-date AT ROW 2 COL 25 COLON-ALIGNED LABEL "Дата с&чета" VIEW-AS FILL-IN SIZE 9.25 BY 1
  period AT ROW 4 COL 25 COLON-ALIGNED
  trn-doc.rsrv-date AT ROW 5.5 COL 25 COLON-ALIGNED LABEL "Дата снятия ре&зерва" VIEW-AS FILL-IN SIZE 9.25 BY 1
  b-unrv AT ROW 1 COL 21
  b-help AT ROW 1 COL 31
  SPACE(1.76) SKIP(0.85)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
  DEFAULT-BUTTON b-save.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME {&frame-name}:SCROLLABLE       = FALSE.

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-save
ON CHOOSE OF b-save IN FRAME {&frame-name} /* Сохранить */
DO:
define variable v-today as date      no-undo.
if trn-doc.status_ = {&permitted} then do:
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
  if input frame {&frame-name} trn-doc.rsrv-date < v-today then do:
    varlog = yes.
    message "Нельзя назначать отгрузку раньше, чем сегодня."
                    skip (2) "Исправить дату ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then return no-apply.
    disp v-today @ trn-doc.rsrv-date with frame {&frame-name}.
  end.
  varlog = yes.
  do while can-do (v-cntxp-holidays, string (weekday (input frame {&frame-name} trn-doc.rsrv-date))) :
    if varlog then do:
      message "Отгрузка попадает на выходной." skip (2) "Переместить ее на рабочий день ?"
                      view-as alert-box question buttons Yes-No update varlog.
      if not varlog then leave.
      varlog = no.
    end.
    disp input frame {&frame-name} trn-doc.rsrv-date + 1 @ trn-doc.rsrv-date with frame {&frame-name}.
  end.
end.
assign trn-doc.rsrv-date = input frame {&frame-name} trn-doc.rsrv-date.
END.

&Scoped-define SELF-NAME b-unrv
ON CHOOSE OF b-unrv IN FRAME {&frame-name} /* Снять */
DO:
varlog = yes.
message "Снятие резервов по накладной №" trn-doc.doc-code "Продолжать ?"
                view-as alert-box question buttons OK-Cancel update varlog.
if not varlog then return no-apply.
run str/unrv-out.p (parparentproc, trn-doc.doc-code) no-error.
if error-status:error then return no-apply.
   message "Резервирование по накладной №" trn-doc.doc-code "отменено." skip (2)
           "Накладная переведена в ЗАПРОС.".
END.

&Scoped-define SELF-NAME trn-doc.rsrv-date
ON LEAVE OF trn-doc.rsrv-date IN FRAME {&frame-name} /* Дата снятия резерва */
DO:
disp input frame {&frame-name} trn-doc.rsrv-date - trn-doc.doc-date @ period with frame {&frame-name}.
END.

&Scoped-define SELF-NAME period
ON return, LEAVE OF period IN FRAME {&frame-name} /* {&period} резерва (дней) */
DO:
disp trn-doc.doc-date + input frame {&frame-name} period @ trn-doc.rsrv-date with frame {&frame-name}.
END.

&UNDEFINE SELF-NAME

/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, return:
  find trn-doc where trn-doc.doc-code = pardoc-code exclusive.
  period = integer (trn-doc.rsrv-date) - integer (trn-doc.doc-date).
  if trn-doc.status_ = {&permitted} then do:
    /* планирование отгрузки */
    if not can-do ({&expense_write-off}, trn-doc.doc-type) then do:
      message "Снять резервы или изменить дату отгрузки по данному документу нельзя.".
      return.
    end.
    case trn-doc.doc-type
    :
      when {&expense}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_expense_shipping':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          varlog
        }
      end.
      when {&write-off}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_write-off_shipping':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          varlog
        }
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип документа" skip
          "Тип документа" trn-doc.doc-type skip
          "Код документа" trn-doc.doc-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    if not varlog then return.
    if trn-doc.flag_ = no then do:
      message "Документ уже отпечатан в набор. Изменение даты отгрузки невозможно.".
      return.
    end.
    if v-cntxt-db-num-obj <> v-cntxt-db-num then do:
      message "Изменение даты отгрузки возможно только на базе данных объекта : " v-cntxt-db-num-obj.
      return.
    end.
    frame {&frame-name}:title = "Накладная № " + trn-doc.doc-code + ".     ОТГРУЗКА".
    period:label = "С&рок отгрузки (дней)".
    trn-doc.rsrv-date:label = "Дата отгру&зки".
  end.
  else do:
    /* работа с резервами */
    if not can-do ( {&expense_write-off_return}, trn-doc.doc-type) or
     (trn-doc.internal and trn-doc.doc-type <> {&expense}) or
     trn-doc.status_ <> {&wayb} then do:
      message "Снять резервы или изменить дату отгрузки по данному документу нельзя.".
      return.
    end.
    case trn-doc.doc-type
    :
      when {&expense}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_expense_rsrv-dtl-action-reserv':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          varlog
        }
      end.
      when {&write-off}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_write-off_rsrv-dtl-action-reserv':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          varlog
        }
      end.
      when {&return}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_return_rsrv-dtl-action-reserv':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          varlog
        }
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип документа" skip
          "Тип документа" trn-doc.doc-type skip
          "Код документа" trn-doc.doc-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    if not varlog then return.
    if v-cntxt-db-num-obj <> v-cntxt-db-num then do:
      message "Резервы можно снимать только на активной стороне.".
      return.
    end.
    frame {&frame-name}:title = "Накладная № " + trn-doc.doc-code + ".     РЕЗЕРВ".
    ENABLE b-unrv WITH FRAME {&frame-name}.
  end.
  DISPLAY period trn-doc.doc-date trn-doc.rsrv-date WITH FRAME {&frame-name}.
  ENABLE period trn-doc.rsrv-date b-quit b-save b-help WITH FRAME {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus trn-doc.rsrv-date.
END.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

&UNDEFINE FRAME-NAME