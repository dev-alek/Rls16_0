&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-chs-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-chs-gds
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор списка товаров

Автор: Чернова Светлана Александровна
Дата создания: 13/03/02
Author: Svetlana Chernova
Creation date: 13/03/02

*/

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.

define input        parameter parParentProc  as widget-handle no-undo.
define input        parameter p-type-doc     as character no-undo .
define input        parameter f-title        as character no-undo.
define input        parameter parcli-type  like ub.trn-doc.cli-type   no-undo.
define input        parameter parcli-code  like ub.trn-doc.cli-code   no-undo.
define input        parameter parhost-code like ub.trn-doc.host-code  no-undo.
define input-output parameter parartic     like ub.doc-line.artic     no-undo.
define output       parameter ref-list       as character no-undo.
define output       parameter table for  tt-gds-list .
define input        parameter ver-flor       as logical   no-undo .
 /* для     ( g#stat     = {&inquiry} and
              g#type     = {&expense} and
              g#internal = false   ) */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Выбор списка товаров" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/usr-flt.i  }
{ ref/grp-attr.i }
{ cmp/gds-list.i gds-list def shared  }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cus/ord-outp.i def }

define variable conf-par   as character no-undo .  /* для чтения параметра конфигурации */
define variable par-type   as character no-undo .  /* тип параметра конфигурации */
define variable nn as integer no-undo .
define variable v-erase    as logical   no-undo .
define variable v-mess-err as character no-undo .

define buffer g-producer for ub.clients.

&scop after-run ~
if ref-list = '' then do: ~
  apply "entry" to ub.goods.artic in frame {&frame-name}. ~
  return no-apply. ~
end. ~
find ub.goods where recid (ub.goods) = integer (entry (1, ref-list)) no-lock. ~
assign  parartic     = ub.goods.artic. ~
disp ub.goods.prod-type ub.goods.prod-code ub.goods.artic with frame {&frame-name}. ~
apply "go" to frame {&frame-name}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-chs-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.ext-artic

/* Definitions for DIALOG-BOX d-chs-gds                                 */
&Scoped-define FIELDS-IN-QUERY-d-chs-gds ub.ext-artic.ext-artic
&Scoped-define ENABLED-FIELDS-IN-QUERY-d-chs-gds ub.ext-artic.ext-artic
&Scoped-define ENABLED-TABLES-IN-QUERY-d-chs-gds ub.ext-artic
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-d-chs-gds ub.ext-artic
&Scoped-define QUERY-STRING-d-chs-gds FOR EACH ub.ext-artic SHARE-LOCK
&Scoped-define OPEN-QUERY-d-chs-gds OPEN QUERY d-chs-gds FOR EACH ub.ext-artic SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-chs-gds ub.ext-artic
&Scoped-define FIRST-TABLE-IN-QUERY-d-chs-gds ub.ext-artic


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.goods.artic ub.goods.prod-code ub.goods.prod-type ~
ext-artic.ext-artic
&Scoped-define ENABLED-TABLES ub.goods ub.ext-artic
&Scoped-define FIRST-ENABLED-TABLE ub.goods
&Scoped-define SECOND-ENABLED-TABLE ub.ext-artic
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help r-goods r-list
&Scoped-Define DISPLAYED-FIELDS ub.goods.artic ub.goods.prod-code ub.goods.prod-type ~
ext-artic.ext-artic
&Scoped-define DISPLAYED-TABLES ub.goods ub.ext-artic
&Scoped-define FIRST-DISPLAYED-TABLE ub.goods
&Scoped-define SECOND-DISPLAYED-TABLE ub.ext-artic


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON r-goods
     LABEL "Справочник"
     SIZE 13 BY 1 TOOLTIP "Справочник товаров".

DEFINE BUTTON r-list
     LABEL "Список"
     SIZE 13 BY 1 TOOLTIP "Список товаров".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY d-chs-gds FOR
      ub.ext-artic SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-chs-gds
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 43
     ub.goods.artic AT ROW 3 COL 19.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     r-goods AT ROW 3 COL 38.75
     ub.goods.prod-code AT ROW 4.17 COL 19.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.13 BY 1
     ub.goods.prod-type AT ROW 4.17 COL 30.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     r-list AT ROW 4.17 COL 38.75
     ub.ext-artic.ext-artic AT ROW 5.38 COL 19.5 COLON-ALIGNED
          LABEL "Внешний артикул"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     SPACE(14.50) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-chs-gds
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-chs-gds:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN ub.ext-artic.ext-artic IN FRAME d-chs-gds
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-chs-gds
/* Query rebuild information for DIALOG-BOX d-chs-gds
     _TblList          = "ub.ext-artic"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-chs-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-chs-gds
ON CHOOSE OF b-exit IN FRAME d-chs-gds /* Ввод  */
DO:

run check-goods no-error.
if error-status:error then run run-ref in this-procedure .
{&after-run}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-chs-gds
ON CHOOSE OF b-quit IN FRAME d-chs-gds /* Отмена */
DO:
  ref-list = "".
END.

on end-error, stop of frame {&frame-name} do:
apply "choose" to b-quit in frame {&frame-name}.
return no-apply.
end.

ON return, MOUSE-SELECT-DBLCLICK OF ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code, ub.ext-artic.ext-artic IN FRAME {&frame-name} DO:
apply "choose" to b-exit in frame {&frame-name}.
return no-apply.
END.


ON ctrl-cursor-down OF ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code IN FRAME {&frame-name} DO:
   run run-ref in this-procedure .
   {&after-run}
end.
on alt-cursor-down of ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code in frame {&frame-name} do:
   run run-list in this-procedure .
   {&after-run}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-goods d-chs-gds
ON CHOOSE OF r-goods IN FRAME d-chs-gds /* Справочник */
DO:
  run run-ref in this-procedure .
{&after-run}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-list d-chs-gds
ON CHOOSE OF r-list IN FRAME d-chs-gds /* Список */
DO:
  run run-list in this-procedure .
  {&after-run}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-chs-gds


IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, return
   ON END-KEY UNDO MAIN-BLOCK, return:
frame {&frame-name}:title = f-title + " -  " + {&add-def}.
ENABLE ub.goods.artic ub.goods.prod-code ub.goods.prod-type r-goods r-list b-exit b-quit b-help WITH FRAME {&frame-name}.
find first ub.clients where ub.clients.obj-type = parcli-type and
                         ub.clients.obj-code = parcli-code no-lock no-error.
if available ub.clients then enable ub.ext-artic.ext-artic with frame {&frame-name}.
                     else ub.ext-artic.ext-artic:visible in frame {&frame-name} = no.
disp parartic     @ ub.goods.artic
with frame {&frame-name}.
if input frame {&frame-name} ub.goods.prod-type = "" or
   input frame {&frame-name} ub.goods.prod-type = ?  or
   input frame {&frame-name} ub.goods.prod-type = "?"
   then
   disp {&cmp} @ ub.goods.prod-type with frame {&frame-name}.
WAIT-FOR GO OF FRAME {&FRAME-NAME} focus ub.goods.artic.
END.

run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pr d-chs-gds
PROCEDURE pr :
END PROCEDURE.
/*----------------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE run-ref:
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-cond as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .

if can-find (ub.clients where ub.clients.obj-type = input frame {&frame-name} ub.goods.prod-type
                       and ub.clients.obj-code = input frame {&frame-name} ub.goods.prod-code no-lock) then do:
  /* товар не найден, но производитель задан правильно - вызываем справочник по производителю */
  find g-producer where g-producer.obj-type = input frame {&frame-name} ub.goods.prod-type
                               and g-producer.obj-code = input frame {&frame-name} ub.goods.prod-code no-lock.
  v-list = {&producer}.
end.
else
v-list = {&all}.
v-stat = {&current}.
run ref/gds-ref.p
    ( parParentProc
    ,"b-sel,b-mark,b-add"
    ,v-stat
    ,v-list
    ,v-cond
    ,?
    ,?
    ,(if available g-producer then g-producer.obj-type else ?)
    ,(if available g-producer then g-producer.obj-code else ?)
    ,v-cntxt-obj-type
    ,v-cntxt-obj-code
    ,?
    , output ref-list).

define variable new-ref-list as character no-undo init "" .
define variable i as integer   no-undo .

repeat i = 1 to num-entries (ref-list) :
  find first ub.goods where recid (ub.goods) = integer (entry (i, ref-list)) no-lock  .
    run ver-gds in this-procedure  (ub.goods.gds-code, output v-erase ,output v-mess-err) no-error  .
    if v-erase = false then do:
       new-ref-list = new-ref-list + min (",", new-ref-list) + string (recid (ub.goods)).
    end.
end.

if num-entries (ref-list) <> num-entries (new-ref-list) then
run view-exept-gds ( substitute("Не все отмеченные позиции вошли в список !&1Просмотреть товары не вошедшие в список ?", {&new-line})) .
ref-list = new-ref-list .




/*найдем g-producer потому что мог смениться*/

run uf-get in this-procedure(
     input  {&uf-gds-ref-p}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, {&delim-par}) = 8
then do:
  assign
  v-list       = entry(2, v-uf-List_, {&delim-par})
  v-prod-type  = entry(6, v-uf-List_, {&delim-par})
  v-prod-code  = integer(entry(7, v-uf-List_, {&delim-par}))
  no-error
  .
  if not error-status:error and v-list = {&producer} then do:
    find first g-producer no-lock where
              g-producer.obj-type = v-prod-type
          AND g-producer.obj-code = v-prod-code no-error .
  end.
end.

define variable iii as integer no-undo .
  repeat iii = 1 to num-entries(ref-list) :
      FIND FIRST ub.goods WHERE recid(ub.goods) = int(entry(iii, ref-list))  no-lock .
      if avail ub.goods then do:
        if not can-find(first tt-gds-list where tt-gds-list.gds-code = ub.goods.gds-code no-lock ) Then do:
            create tt-gds-list.
            BUFFER-COPY ub.goods to tt-gds-list .
            assign  tt-gds-list.nn = iii.
        end.
      end.
  end.

END PROCEDURE.

PROCEDURE run-list:
define variable v-f as logical   no-undo init false .
run str/gds-list.w ( input parParentProc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code).
ref-list = ''.
FOR EACH gds-list NO-LOCK by gds-list.order-num :
    run ver-gds in this-procedure ( gds-list.gds-code, output v-erase , output v-mess-err ) no-error .
    if v-erase = false  then do:
        find first ub.goods where ub.goods.artic     = gds-list.artic     and
                               ub.goods.prod-code = gds-list.prod-code and
                               ub.goods.prod-type = gds-list.prod-type no-lock.
            ref-list = string (recid(ub.goods)) .
            nn = nn + 1.
          if not can-find(first tt-gds-list where tt-gds-list.gds-code = gds-list.gds-code no-lock ) Then do:
              create tt-gds-list.
              BUFFER-COPY gds-list to tt-gds-list .
              assign tt-gds-list.nn = nn .
          end.

    end.
    else v-f = true .
END.
if v-f = true then run view-exept-gds ( substitute("Не все отмеченные позиции вошли в список !&1Просмотреть товары не вошедшие в список ?", {&new-line})) .
END PROCEDURE.

PROCEDURE check-goods :
/* -----------------------------------------------------------------------------------------------------------------------------------------------------
  Purpose:   проверка правильности задания товара вручную
---------------------------------------------------------------------------------------------------------------------------------------------------------- */
def buffer gds-b for ub.goods.
def buffer buf_ext-artic for ub.ext-artic.

ref-list = ''.
/*Вначале поиск по артикулу поставщика*/
if ub.ext-artic.ext-artic:sensitive in frame {&frame-name} = yes and
   input frame {&frame-name} ub.ext-artic.ext-artic <> ""        and
   input frame {&frame-name} ub.ext-artic.ext-artic <> "?"       and
   input frame {&frame-name} ub.ext-artic.ext-artic <> ?         then do:
   find first ub.ext-artic where ub.ext-artic.cli-type    = parcli-type
                          and ub.ext-artic.cli-code    = parcli-code
                          and ub.ext-artic.ext-artic   = input frame {&frame-name} ub.ext-artic.ext-artic
                          and ub.ext-artic.status_    <> {&deleted}
                          no-lock no-error.
   if available ub.ext-artic then do:
      /* Ищем другой товар с таким же внешним артикулом */
      find first buf_ext-artic where buf_ext-artic.cli-type  =  parcli-type
                                 and buf_ext-artic.cli-code  =  parcli-code
                                 and buf_ext-artic.ext-artic =  ub.ext-artic.ext-artic
                                 and buf_ext-artic.status_   <> {&deleted}
                                 and buf_ext-artic.gds-code  <> ub.ext-artic.gds-code
      no-lock no-error .

      if available ( buf_ext-artic ) then do:
        message "С внешним артикулом :" input frame {&frame-name} ub.ext-artic.ext-artic
                        "связано несколько товаров." skip (2)
                        "Укажите Производителя или выберите товар из справочника.".
        apply "entry" to ub.goods.prod-code in frame {&frame-name}.
        return.        /* без error - не будет вызова справочника */
      end.
      find first gds-b where gds-b.gds-code = ub.ext-artic.gds-code no-lock no-error .
      if not available gds-b then do:
        message "Не могу найти товар связанный с внешним артикулом " ub.ext-artic.ext-artic view-as alert-box information .
        apply "entry" to ub.goods.prod-code in frame {&frame-name}.
        return.        /* без error - не будет вызова справочника */
      end.
      display gds-b.artic     @ ub.goods.artic
              gds-b.prod-type @ ub.goods.prod-type
              gds-b.prod-code @ ub.goods.prod-code
              with frame {&frame-name}.
   end.
   else do:
      message "Неправильный внешний артикул!" view-as alert-box information.
      display "" @ ub.ext-artic.ext-artic with frame {&frame-name}.
      apply "entry" to ub.goods.prod-code in frame {&frame-name}.
      return .
   end.
end.
if input frame {&frame-name} ub.goods.artic = '' then return error.
find first ub.goods where ub.goods.artic  = input frame {&frame-name} ub.goods.artic no-lock no-error.
if not available ub.goods then do:
  message "Неправильный Артикул - такого товара нет.".
  apply "entry" to ub.goods.artic in frame {&frame-name}.
  return.        /* без error - не будет вызова справочника */
end.
find first gds-b where gds-b.artic  = input frame {&frame-name} ub.goods.artic
                   and recid (gds-b) <> recid (ub.goods)
                   and gds-b.stts = 0 no-lock no-error.
if input frame {&frame-name} ub.goods.prod-code <> 0 then do:
  find first ub.goods where ub.goods.prod-code   = input frame {&frame-name} ub.goods.prod-code
                     and  ub.goods.artic      = input frame {&frame-name} ub.goods.artic no-lock no-error.
  if not available ub.goods then do:
    message "Неправильный Код производителя - такого товара нет.".
    apply "entry" to ub.goods.prod-code in frame {&frame-name}.
    return.        /* без error - не будет вызова справочника */
  end.
  find first gds-b where gds-b.artic     = input frame {&frame-name} ub.goods.artic
                     and gds-b.prod-code = input frame {&frame-name} ub.goods.prod-code
                     and recid (gds-b) <> recid (ub.goods)
                     and gds-b.stts = 0 no-lock no-error.
end.
else do:
  if available gds-b then do:
    if available g-producer then
      find ub.goods where ub.goods.prod-type = g-producer.obj-type
                           and  ub.goods.prod-code = g-producer.obj-code
                           and  ub.goods.artic          = input frame {&frame-name} ub.goods.artic no-lock no-error.
    if not available g-producer or (available g-producer and not available ub.goods) then do:
      message "С артикулом :" input frame {&frame-name} ub.goods.artic
                      "несколько товаров." skip (2)
                      "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to ub.goods.prod-code in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
    end.
  end.
end.
if input frame {&frame-name} ub.goods.prod-code <> 0  and
   input frame {&frame-name} ub.goods.prod-type <> "" then do:
   find ub.goods where ub.goods.prod-type = input frame {&frame-name} ub.goods.prod-type and
                   ub.goods.prod-code = input frame {&frame-name} ub.goods.prod-code and
                   ub.goods.artic     = input frame {&frame-name} ub.goods.artic no-lock no-error.
   if not available ub.goods then do:
    message "Неправильный Тип производителя - такого товара нет.".
    apply "entry" to ub.goods.prod-type in frame {&frame-name}.
    return.        /* без error - не будет вызова справочника */
   end.
end.
else do:
  if available gds-b then do:
    if available g-producer then
      find ub.goods where ub.goods.prod-type = g-producer.obj-type and
                       ub.goods.prod-code = g-producer.obj-code and
                       ub.goods.artic     = input frame {&frame-name} ub.goods.artic no-lock no-error.
    if not available g-producer or (available g-producer and not available ub.goods) then do:
      message "С артикулом :" input frame {&frame-name} ub.goods.artic
                      "несколько товаров." skip (2)
                      "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to ub.goods.prod-type in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
    end.
  end.
end.

run ver-gds in this-procedure (ub.goods.gds-code, output v-erase, output v-mess-err) no-error .
if v-erase = true then do:
      run view-exept-gds ( substitute("Не все отмеченные позиции вошли в список !&1Просмотреть товары не вошедшие в список ?", {&new-line})) .
      apply "entry" to ub.goods.artic in frame {&frame-name}.
      return.
end.



ref-list = string (recid (ub.goods)).
create tt-gds-list.
BUFFER-COPY ub.goods to tt-gds-list.
       assign tt-gds-list.nn = 1.

END PROCEDURE.

procedure ver-gds :
 do
 on error undo, return error return-value
 :
define input  parameter  p-gds-code as integer   no-undo .
define output parameter  v-nabor    as logical   no-undo .
define output parameter  p-mess-err as character no-undo .

define variable  v-err as logical   no-undo .
v-nabor = false .
p-mess-err = "" .

if /* not ( g#stat     = {&inquiry} and
            g#type     = {&expense} and
            g#internal = false   ) */
  not ver-flor
  then do:
    run ver-gds-grp-nabor in this-procedure ( input p-gds-code, output v-nabor) .
    p-mess-err = "Нетоварная позиция код: " + string(p-gds-code) .
    run creat-tt (p-gds-code , (if v-nabor = true then p-mess-err else "") ) .
  end.


  run ver-assort-polit in this-procedure  (p-gds-code, output v-err ) no-error .
  if v-err = true then do:
     v-nabor = true .
     run creat-tt (p-gds-code , (if v-nabor = true then return-value  else "") ) .
  end.
end.
end procedure. /* ver-gds */


procedure ver-assort-polit :

  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-del   as logical   no-undo .

v-del = false .
if p-type-doc = "gds-matr"
   or p-type-doc = "inv"
   or p-type-doc = "price-list"
   or p-type-doc = "accor"
   or p-type-doc = "alc-type"
   or p-type-doc = "season"
   or p-type-doc = "order" + {&f-p}
   or p-type-doc = "temp"
   then return .


define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code as character no-undo .
 assign
  var-ok-assort-pol = true
  v-event-code = substring(p-type-doc,6,2)
 .

      { gbl/goassizt.i
        v-event-code
        p-gds-code
        v-cntxt-obj-type
        v-cntxt-obj-code
        true
        var-ok-assort-pol
        var-mess-assort-pol
      }
      if var-ok-assort-pol = false then do:
          v-del = true .
          return var-mess-assort-pol .
      end.
  end.

end procedure. /* ver-assort-polit */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME