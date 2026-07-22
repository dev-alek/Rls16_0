&scop FRAME-NAME     d-chs-gds
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно выбора товара

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

перед вызовом должен быть установлен g-cond - фильтр для справочника товаров,
"объект-факт-свободно"

Author2:  Исаков Андрей Валерьевич
Create: 6.08.99

Автор1: Суслов Алексей Юрьевич

*/

/* ***************************  Definitions  ************************** */

define input        parameter parparentproc as widget-handle no-undo .
define input        parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input        parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input        parameter p-list-mode  as character no-undo .
define input        parameter p-stat       as character no-undo .
define input        parameter f-title      as   character no-undo.
define input        parameter p-cond       as   character no-undo .
/*режим вызова справочника*/
define input        parameter parcli-type  like trn-doc.cli-type   no-undo.
define input        parameter parcli-code  like trn-doc.cli-code   no-undo.
define input        parameter parhost-code like trn-doc.host-code  no-undo.
define input        parameter parext-doc-type as character no-undo . /* расширеный тип документа */
define input-output parameter parartic     like doc-line.artic     no-undo.
define output       parameter ref-list as character no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Окно выбора товара" .
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u,f-title,p-cond,parcli-type,parcli-code,parhost-code,parartic)" }
{ cmp/str-glbl.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/usr-flt.i  }
{ ref/grp-attr.i }
{ gbl/getcntxt.i def }
{ cus/ord-outp.i def }

define variable conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as character no-undo.                  /* тип параметра конфигурации */
define buffer g-producer for ub.clients.
define variable v-erase as logical   no-undo .    /**/
define variable v-event-code as character no-undo .

/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-exit
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON r-goods
     IMAGE-UP FILE "btn-down-arrow"
     IMAGE-DOWN FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     SIZE 3 BY .88.

DEFINE BUTTON r-list
     IMAGE-UP FILE "btn-down-arrow"
     IMAGE-DOWN FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     SIZE 3 BY .88.

DEFINE BUTTON r-ext-artic
     IMAGE-UP FILE "btn-down-arrow"
     IMAGE-DOWN FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     SIZE 3 BY .88.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
  goods.artic AT ROW 1.5 COL 20 COLON-ALIGNED LABEL "&Артикул" VIEW-AS FILL-IN SIZE 17 BY 1
  r-goods AT ROW 1.5 COL 40 NO-LABEL
  r-list AT ROW 1.5 COL 43 NO-LABEL
  goods.prod-code AT ROW 2.5 COL 20 COLON-ALIGNED LABEL "&Производитель"
  goods.prod-type FORMAT "x(3)" AT ROW 2.5 COL 33 COLON-ALIGNED NO-LABEL VIEW-AS FILL-IN SIZE 4 BY 1
  ext-artic.ext-artic AT ROW 3.5 COL 20 COLON-ALIGNED LABEL "Внешний артикул" VIEW-AS FILL-IN SIZE 17 BY 1
  b-exit AT ROW 6 COL 12
  b-quit AT ROW 6 COL 26
  b-help AT ROW 6 COL 28
  SKIP(0.38)
  WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D SCROLLABLE KEEP-TAB-ORDER
         TITLE "Строка":L
         DEFAULT-BUTTON b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME {&frame-name}:SCROLLABLE = FALSE.

/* ************************  Control Triggers  ************************ */

ON CHOOSE OF b-quit IN FRAME {&frame-name} /* Отказ */ DO:
ref-list = "".
END.

on end-error, stop of frame {&frame-name} do:
apply "choose" to b-quit in frame {&frame-name}.
return no-apply.
end.

ON return, MOUSE-SELECT-DBLCLICK OF goods.artic, goods.prod-type, goods.prod-code, ext-artic.ext-artic /*cli-gds.cli-art*/ IN FRAME {&frame-name} DO:
apply "choose" to b-exit in frame {&frame-name}.
return no-apply.
END.

&scop after-run ~
if ref-list = '' then do: ~
  apply "entry" to goods.artic in frame {&frame-name}. ~
  return no-apply. ~
end. ~
if  ref-list <> 'cb_create_gds-list_from-chs-gds' then do: ~
  find goods where recid (goods) = integer (entry (1, ref-list)) no-lock. ~
  assign  parartic     = goods.artic. ~
  disp goods.prod-type goods.prod-code goods.artic with frame {&frame-name}. ~
end. ~
apply "go" to frame {&frame-name}.

ON CHOOSE OF b-exit IN FRAME {&frame-name} DO:
run check-goods no-error.
if error-status:error then RUN run-ref.
{&after-run}
END.

ON CHOOSE OF r-goods IN FRAME {&frame-name} DO:
RUN run-ref.
{&after-run}
END.

ON CHOOSE OF r-list IN FRAME {&frame-name} DO:
RUN run-list.
{&after-run}
END.

ON ctrl-cursor-down OF goods.artic, goods.prod-type, goods.prod-code IN FRAME {&frame-name} DO:
   RUN run-ref.
   {&after-run}
END.
ON alt-cursor-down OF goods.artic, goods.prod-type, goods.prod-code IN FRAME {&frame-name} DO:
   RUN run-list.
   {&after-run}
END.


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, return
   ON END-KEY UNDO MAIN-BLOCK, return:
{ gbl/getcntxt.i get }
frame {&frame-name}:title = f-title + " -  " + {&add-def}.
empty temp-table temp-err.
ENABLE
  goods.artic
  goods.prod-code
  goods.prod-type
  ext-artic.ext-artic
  r-goods
  r-list
/*  r-ext-artic*/
  b-exit
  b-quit
  b-help
WITH FRAME {&frame-name}.
find first clients where clients.obj-type = parcli-type and
                         clients.obj-code = parcli-code no-lock no-error.
if available clients then enable ext-artic.ext-artic with frame {&frame-name}.
                     else ext-artic.ext-artic:visible in frame {&frame-name} = no.
disp parartic     @ goods.artic
with frame {&frame-name}.
if input frame {&frame-name} goods.prod-type = "" or
   input frame {&frame-name} goods.prod-type = ?  or
   input frame {&frame-name} goods.prod-type = "?"
   then
   disp {&cmp} @ goods.prod-type with frame {&frame-name}.
WAIT-FOR GO OF FRAME {&FRAME-NAME} focus goods.artic.
END.

RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE run-ref:
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .
if can-find (clients where clients.obj-type = input frame {&frame-name} goods.prod-type
                                 and clients.obj-code = input frame {&frame-name} goods.prod-code no-lock) then do:
  /* товар не найден, но производитель задан правильно - вызываем справочник по производителю */
  find g-producer where
       g-producer.obj-type = input frame {&frame-name} goods.prod-type
   and g-producer.obj-code = input frame {&frame-name} goods.prod-code no-lock.
  v-list = "производитель".
end.
else
v-list = {&all}.
v-stat = {&current}.
run ref/gds-ref.p
  ( input parparentproc
    ,input "b-sel,b-mark,b-add"
    ,input v-stat
    ,input v-list
    ,input p-cond
  ,input ?
  ,input ?
  ,input (if available g-producer then g-producer.obj-type else ?)
  ,input (if available g-producer then g-producer.obj-code else ?)
  ,input p-curr-obj-type
  ,input p-curr-obj-code
  ,input ?
  ,output ref-list).

define variable new-ref-list as character no-undo init "" .
define variable i as integer   no-undo .
define variable v-erase-ass as logical   no-undo .

repeat i = 1 to num-entries (ref-list) :
  find first goods where recid (goods) = integer (entry (i, ref-list)) no-lock  .
    run ver-gds (goods.gds-code, output v-erase) .
    run creat-tt (goods.gds-code , (if v-erase = true then return-value else "") ) .
    run ver-assort-polit (INPUT goods.gds-code, output v-erase-ass)  .
    run creat-tt (goods.gds-code , (if v-erase-ass = true then return-value else "")) .
    if v-erase = false and v-erase-ass = false then do:
       new-ref-list = new-ref-list + min (",", new-ref-list) + string (recid (goods)).
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

END PROCEDURE.

PROCEDURE run-list:
define variable v-f as logical   no-undo init false .
define variable v-erase-ass as logical   no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .


{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
run str/gds-list.w (
                     input parparentproc
                   , input v-host-code
                   , input p-curr-obj-type
                   , input p-curr-obj-code).
ref-list = ''.
v-f = false  .
FOR EACH gds-list NO-LOCK:
    run ver-gds (gds-list.gds-code, output v-erase) .
    run creat-tt (gds-list.gds-code , (if v-erase = true then return-value  else "")) .
    find first goods where goods.artic     = gds-list.artic     and
                           goods.prod-code = gds-list.prod-code and
                           goods.prod-type = gds-list.prod-type
                           no-lock.
    run ver-assort-polit (gds-list.gds-code, output v-erase-ass)  .
    run creat-tt (gds-list.gds-code , (if v-erase-ass = true then return-value else "")) .
    if v-erase = false and v-erase-ass = false  then do:
       if this-procedure:instantiating-procedure:get-signature("cb_create_gds-list_from-chs-gds") <> "" then do:
         run cb_create_gds-list_from-chs-gds in (this-procedure:instantiating-procedure) ( input (buffer gds-list:handle)).
         ref-list = "cb_create_gds-list_from-chs-gds":U.
       end.
       else do:
         ref-list = ref-list + min (",", ref-list) + string (recid (goods)).
       end.
    end.
    else do:
      v-f = true .
      DELETE gds-list.
    end.
END.


if v-f = true then do:
  run view-exept-gds ( substitute("Не все отмеченные позиции вошли в список !&1Просмотреть товары не вошедшие в список ?", {&new-line})) .
end.

END PROCEDURE.

PROCEDURE check-goods :
/* -----------------------------------------------------------------------------------------------------------------------------------------------------
  Purpose:   проверка правильности задания товара вручную
---------------------------------------------------------------------------------------------------------------------------------------------------------- */
def buffer gds-b for goods.
def buffer buf_ext-artic for ub.ext-artic.


ref-list = ''.
/*Вначале поиск по артикулу поставщика*/
if ext-artic.ext-artic:sensitive in frame {&frame-name} = yes and
   input frame {&frame-name} ext-artic.ext-artic <> ""        and
   input frame {&frame-name} ext-artic.ext-artic <> "?"       and
   input frame {&frame-name} ext-artic.ext-artic <> ?         then do:
   find first ext-artic where ext-artic.cli-type    = parcli-type
                          and ext-artic.cli-code    = parcli-code
                          and ext-artic.ext-artic   = input frame {&frame-name} ext-artic.ext-artic
                          and ext-artic.status_    <> {&deleted}
                          no-lock no-error.
   if available ext-artic then do:
      /* Ищем другой товар с таким же внешним артикулом */
      find first buf_ext-artic where buf_ext-artic.cli-type  =  parcli-type
                                 and buf_ext-artic.cli-code  =  parcli-code
                                 and buf_ext-artic.ext-artic =  ext-artic.ext-artic
                                 and buf_ext-artic.status_   <> {&deleted}
                                 and buf_ext-artic.gds-code  <> ext-artic.gds-code
      no-lock no-error .

      if available ( buf_ext-artic ) then do:
        message "С внешним артикулом :" input frame {&frame-name} ext-artic.ext-artic
                        "связано несколько товаров." skip (2)
                        "Укажите Производителя или выберите товар из справочника.".
        apply "entry" to goods.prod-code in frame {&frame-name}.
        return.        /* без error - не будет вызова справочника */
      end.
      find first gds-b where gds-b.gds-code = ext-artic.gds-code no-lock no-error .
      if not available gds-b then do:
        message "Не могу найти товар связанный с внешним артикулом " ext-artic.ext-artic view-as alert-box information .
        apply "entry" to goods.prod-code in frame {&frame-name}.
        return.        /* без error - не будет вызова справочника */
      end.
      display gds-b.artic     @ goods.artic
              gds-b.prod-type @ goods.prod-type
              gds-b.prod-code @ goods.prod-code
              with frame {&frame-name}.
   end.
   else do:
      message "Неправильный внешний артикул!" view-as alert-box information.
      display "" @ ext-artic.ext-artic with frame {&frame-name}.
      apply "entry" to goods.prod-code in frame {&frame-name}.
      return .
   end.
end.
if input frame {&frame-name} goods.artic = '' then return error.
find first goods where goods.artic  = input frame {&frame-name} goods.artic no-lock no-error.
if not available goods then do:
  message "Неправильный Артикул - такого товара нет.".
  apply "entry" to goods.artic in frame {&frame-name}.
  return.        /* без error - не будет вызова справочника */
end.
find first gds-b where gds-b.artic  = input frame {&frame-name} goods.artic
                   and recid (gds-b) <> recid (goods)
                   and gds-b.stts = 0 no-lock no-error.
if input frame {&frame-name} goods.prod-code <> 0 then do:
  find first goods where goods.prod-code   = input frame {&frame-name} goods.prod-code
                     and  goods.artic      = input frame {&frame-name} goods.artic no-lock no-error.
  if not available goods then do:
    message "Неправильный Код производителя - такого товара нет.".
    apply "entry" to goods.prod-code in frame {&frame-name}.
    return.        /* без error - не будет вызова справочника */
  end.
  find first gds-b where gds-b.artic     = input frame {&frame-name} goods.artic
                     and gds-b.prod-code = input frame {&frame-name} goods.prod-code
                     and recid (gds-b) <> recid (goods)
                     and gds-b.stts = 0 no-lock no-error.
end.
else do:
  if available gds-b then do:
    if available g-producer then
      find goods where goods.prod-type = g-producer.obj-type
                           and  goods.prod-code = g-producer.obj-code
                           and  goods.artic          = input frame {&frame-name} goods.artic no-lock no-error.
    if not available g-producer or (available g-producer and not available goods) then do:
      message "С артикулом :" input frame {&frame-name} goods.artic
                      "несколько товаров." skip (2)
                      "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to goods.prod-code in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
    end.
  end.
end.
if input frame {&frame-name} goods.prod-code <> 0  and
   input frame {&frame-name} goods.prod-type <> "" then do:
   find goods where goods.prod-type = input frame {&frame-name} goods.prod-type and
                   goods.prod-code = input frame {&frame-name} goods.prod-code and
                   goods.artic     = input frame {&frame-name} goods.artic no-lock no-error.
   if not available goods then do:
    message "Неправильный Тип производителя - такого товара нет.".
    apply "entry" to goods.prod-type in frame {&frame-name}.
    return.        /* без error - не будет вызова справочника */
   end.
end.
else do:
  if available gds-b then do:
    if available g-producer then
      find goods where goods.prod-type = g-producer.obj-type and
                       goods.prod-code = g-producer.obj-code and
                       goods.artic     = input frame {&frame-name} goods.artic no-lock no-error.
    if not available g-producer or (available g-producer and not available goods) then do:
      message "С артикулом :" input frame {&frame-name} goods.artic
                      "несколько товаров." skip (2)
                      "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to goods.prod-type in frame {&frame-name}.
      return.        /* без error - не будет вызова справочника */
    end.
  end.
end.

run ver-gds ( goods.gds-code, output v-erase) no-error .
if v-erase = true then do:
      message "Это не товарная позиция - имеет атрибут НАБОР !!!"
      view-as alert-box error .
      apply "entry" to goods.artic in frame {&frame-name}.
      return.
end.

run ver-assort-polit (goods.gds-code, output v-erase).
if v-erase = true then do:
      message return-value view-as alert-box error .
      apply "entry" to goods.artic in frame {&frame-name}.
      return.
end.

ref-list = string (recid (goods)).
END PROCEDURE.


procedure ver-gds :
 do
 on error undo, return error return-value
 :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-nabor   as logical   no-undo .
v-nabor = false .
  if not ( p-list-mode begins {&is-flor} ) then do:
    run ver-gds-grp-nabor( input p-gds-code, output v-nabor) .
  end.
  else do:
    if  p-stat <> {&inquiry} then run ver-gds-grp-nabor( input p-gds-code, output v-nabor) .
  end.

   if v-nabor then return "Это не товарная позиция - имеет атрибут НАБОР !!!" .
end.
end procedure. /* ver-gds */


procedure ver-assort-polit :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-del   as logical   no-undo .

define variable v-ok as logical   no-undo .
define variable v-mess as character no-undo .

  do
  on error undo, return error return-value
  :
v-del = false .
if lookup (parext-doc-type ,
          {&TDEDT_Inv}              + "," +
          {&TDEDT_Corr_Acc_Price}   + "," +
          {&TDEDT_Chg_Purch_Code} + ","  +
          {&TDEDT_Corr_Minus_Parts} + ","  +
          {&TDEDT_Peresort}         + "," +
          {&TDEDT_Spi_Vnesh}        + "," +
          {&TDEDT_Spi_Prvo}         + "," +
          {&TDEDT_Ras_Vnesh_Kass}   + "," +
          {&TDEDT_Vozvrat_Vnesh}    + "," +
          {&TDEDT_Ras_Vnesh_VP} + "," +
          {&TDEDT_Vozvrat_Perem}  + "," +
          {&TDEDT_Ras_Object} + "," +
          {&TDEDT_Pri_Object} ) > 0  then return .

if parext-doc-type = ? then return .

if p-stat = {&inquiry} and
   parext-doc-type = {&TDEDT_Ras_Vnesh} and
   ( p-list-mode begins {&is-flor} )
   then return .

    if p-curr-obj-type = {&shop} or p-curr-obj-type = {&stock} then do:

     v-event-code = substitute("&1-" , parext-doc-type ) .
     if parcli-type = {&shop} or parcli-type = {&stock} then do:
     define variable v-c-host-code as integer   no-undo .
     { gbl/hostcode.i
        parcli-type
        parcli-code
        v-c-host-code
        }
    if parhost-code <> v-c-host-code then v-event-code = substitute("mf_&1-" , parext-doc-type ) .
       else v-event-code = substitute("&1-" , parext-doc-type ) .
    end.
      { gbl/goassizt.i
        v-event-code
        p-gds-code
        p-curr-obj-type
        p-curr-obj-code
        true
        v-ok
        v-mess
      }

      if v-ok = false then do:
        v-del = true .
        return v-mess .
      end.
    end.

  if parext-doc-type <> {&TDEDT_Pri_Vnesh} and
     parext-doc-type <> {&TDEDT_Pri_Perem} and
    ( parcli-type = {&shop} or parcli-type = {&stock}) then do:

     define variable v-ot-host-code as integer   no-undo .
     { gbl/hostcode.i
       parcli-type
       parcli-code
       v-ot-host-code
     }

    if parhost-code <> v-ot-host-code
       then v-event-code = substitute("cli_mf_&1-" , parext-doc-type ) .
       else v-event-code = substitute("cli_&1-" , parext-doc-type ) .
    { gbl/goassizt.i
      v-event-code
      p-gds-code
      parcli-type
      parcli-code
      true
      v-ok
      v-mess
    }
    if v-ok = false then do:
       v-del = true .
       return v-mess .
    end.
  end.


  end.
end procedure. /* ver-assort-polit */

&UNDEFINE FRAME-NAME