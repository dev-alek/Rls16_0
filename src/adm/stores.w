&Scop FRAME-NAME d-store
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник складов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/05
Author: Bakhtadze Natalya
Creation date: 09/13/05

Author:  Андрей Исаков
Created:  22.01.98

*/
define input parameter parparentproc   as widget-handle no-undo .
define input        parameter bttns    as character no-undo . /* список включенных кнопок */
define input-output parameter p-rid-list as character no-undo .
define input        parameter p-only-cur-db-num as logical       no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник складов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ adm/shattrg.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ ref/xobjgrp.i  }
{ ref/aobjgrp.i  }
{ cmp/mrk-strf.i }
{ ref/pricegrp.i }

define variable mark-num as integer no-undo.
define variable attr-option as character no-undo .
define variable cli-attr-option as character no-undo .
define variable v-is-deploy as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer X_cli-host for ub.clients.
define variable v-grp as character no-undo .
define variable v-exist-price-grp as logical   no-undo .
define buffer X_store for ub.store.
define buffer X_clients for ub.clients.

/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-mark
     LABEL " * ":L
     SIZE 3 BY 1.

DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просм"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-right
     LABEL "&Права":L
     SIZE 10 BY 1.

DEFINE BUTTON b-price
     LABEL "&Цены":L
     SIZE 10 BY 1.

DEFINE BUTTON b-attr
     LABEL "Параметры":L
     SIZE 10 BY 1.

DEFINE BUTTON b-cli-attr
     LABEL "Атрибуты":L
     SIZE 10 BY 1.

DEFINE BUTTON B-grp
     LABEL "&Группа"
     SIZE 10 BY 1.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "код"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.


DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup       LABEL "&Просмотр"
       MENU-ITEM m_update       LABEL "Изменение"
       MENU-ITEM m_copy         LABEL "&Копирование"
       rule
       MENU-ITEM m_price-grp    LABEL "Группа ценообразования"
       .
DEFINE MENU MENU-B-cli-attr
       MENU-ITEM m_lookup-cli       LABEL "&Просмотр"
       MENU-ITEM m_update-cli        LABEL "Изменение"
       .

DEFINE QUERY br-stores FOR X_store, X_clients, X_cli-host SCROLLING.

DEFINE BROWSE br-stores QUERY br-stores NO-LOCK DISPLAY
mark-string(recid(X_store), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_store.obj-code COLUMN-LABEL "Код " FORMAT ">>>>9"
X_clients.obj-name COLUMN-LABEL "Название " FORMAT "x(80)" width 25
X_cli-host.obj-name COLUMN-LABEL "Фирма" FORMAT "x(80)" width 25
(if X_clients.stts = 0 then " " else "+") format "x(1)" column-label "Удал"
X_clients.db-num format ">>>>9" width 6
X_store.shift-on COLUMN-LABEL "Смены":L format " + / - "
X_clients.grp-name COLUMN-LABEL "Группа" FORMAT "x(80)" width 25
price-grp ( buffer X_clients ) @ v-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(80)" width 25
WITH SIZE 98 BY 19 separators.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-store
b-quit AT ROW 1 COL 1
b-mark AT ROW 1 COL 11
b-sel AT ROW 1 COL 14
b-add AT ROW 1 COL 24
b-lkp AT ROW 1 COL 34
b-chg AT ROW 1 COL 44
b-del AT ROW 1 COL 54
b-attr AT ROW 1 COL 64
b-right AT ROW 1 COL 74
b-print AT ROW 1 COL 89
b-hist AT ROW 1 col 92
b-help AT ROW 1 COL 95
b-cli-attr AT ROW 2 COL 64
b-price AT ROW 2 COL 74
sch-code AT ROW 2 COL 25
mark-num at row 2 col 14 colon-aligned no-label view-as fill-in size 3 by 1.5 fgcolor 4
b-grp at row 2 col 84
br-stores AT ROW 3.25 COL 1
SPACE(0.74) SKIP(0.66)
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE "   Склады" .

ASSIGN
       FRAME d-store:SCROLLABLE       = FALSE
       br-stores:NUM-LOCKED-COLUMNS IN FRAME d-store = 1.

/* ************************  Control Triggers  ************************ */

on go of frame d-store do:
  p-rid-list = v-rid-list.
end.


ON CHOOSE OF b-attr IN FRAME {&frame-name}  /* просмотр и изменение параметров */
DO:
define variable v-param as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
if not available X_store then return no-apply.
if attr-option = '':U then do:
   run gbl/pop-up.p ( input self:handle
                     ,input no) no-error.
end.
if attr-option = '':U then return no-apply.
if attr-option = {&update}
or attr-option = {&add-copy} then do:
  if v-cntxt-db-num <> 0 then do:
    { gbl/objdbnum.i {&stock} X_store.obj-code v-db-num }
    if v-db-num <> v-cntxt-db-num then do:
      message
      "Нельзя менять ПАРАМЕТРЫ в чужой УБД"
      view-as alert-box error .
      return no-apply.
    end.
  end.
end.
run proc-b-attr in this-procedure (
                                    input attr-option
                                   ,{&stock}
                                   ,X_store.obj-code) no-error .
if error-status:error then do:
  assign
  attr-option = "":u.
  return no-apply.
end.
attr-option = "":u.
END.

ON CHOOSE OF b-cli-attr IN FRAME {&frame-name}  /* просмотр и изменение атрибутов*/
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 define variable v-db-num as integer no-undo .
 define variable ri as recid no-undo .
  if not available X_store then do:
    return no-apply.
  end.
  ri = recid(X_store).
  if cli-attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if cli-attr-option = "":U then do:
      return no-apply.
  end.
  if cli-attr-option = {&update}
  then do:
    if v-cntxt-db-num > 0 then do:
      { gbl/objdbnum.i {&stock} X_store.obj-code v-db-num }
      if v-db-num <> v-cntxt-db-num then do:
        message
        "Нельзя менять АТРИБУТЫ в чужой УБД"
        view-as alert-box error .
        return no-apply.
      end.
    end.
  end.
  run ref/ca-attrr.p (
                    input parparentproc
                   ,input (if lookup("b-add", bttns) > 0
                          AND cli-attr-option = {&update}
                          then {&update}
                          else {&lookup})
                   ,input {&stock}
                   ,input X_store.obj-code
                   ,input yes /*p-update-on-exit*/
                   ,output v-updated
                   ,output v-is-error
                   ) no-error.
  if error-status:error
  or v-is-error then do:
    message
    "Ошибка при вызове списка атрибутов клиента" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
    assign
    cli-attr-option = "":U
    .
    undo, return no-apply.
  end.
  cli-attr-option = "":U.
END.

ON CHOOSE OF MENU-ITEM m_lookup
DO:
  assign
  attr-option = {&lookup}.
  APPLY "CHOOSE" to b-attr  in frame {&frame-name}.
END.

ON CHOOSE OF MENU-ITEM m_update
DO:
  assign
  attr-option = {&update}.
  APPLY "CHOOSE" to b-attr  in frame {&frame-name}.
END.

ON CHOOSE OF MENU-ITEM m_lookup-cli
DO:
  assign
  cli-attr-option = {&lookup}.
  APPLY "CHOOSE" to b-cli-attr  in frame {&frame-name}.
END.

ON CHOOSE OF MENU-ITEM m_update-cli
DO:
  assign
  cli-attr-option = {&update}.
  APPLY "CHOOSE" to b-cli-attr  in frame {&frame-name}.
END.
ON CHOOSE OF MENU-ITEM m_copy
DO:
  assign
  attr-option = {&add-copy}.
  APPLY "CHOOSE" to b-attr  in frame {&frame-name}.
END.

ON CHOOSE OF MENU-ITEM m_price-grp
DO:
  run ref/c-tppr.p
   ( input parParentProc,
     input x_clients.obj-type ,
     input x_clients.obj-code ).
  v-exist-price-grp = true .
  run metod-gop-obj-all (input v-cntxt-db-num) .
  v-grp:visible in browse br-stores = true  .
  run enable_UI.
END.

ON CHOOSE OF b-add IN FRAME d-store /* Добав */
DO:
  define variable ri as recid no-undo.
  define buffer buf_store for ub.store.
  define buffer buf_clients for ub.clients.
  run adm/storei.w ( input parparentproc
                    ,input v-cntxt-host-code-obj
                    ,input 0
                    ,input {&add-def}
                    ,input-output ri).
  if ri <> ? then do:
      find buf_clients where
         recid (buf_clients) = ri no-lock.
      find buf_store where
          buf_store.obj-code = buf_clients.obj-code no-lock.
      ri = recid (buf_store).
      run enable_UI.
      reposition br-stores to recid ri no-error.
      apply "ENTRY" to br-stores.
  end.
  return no-apply.
END.

ON CHOOSE OF b-chg IN FRAME d-store /* Измен */
DO:
  define variable ri as recid no-undo.
  if available X_store then do:
      ri = recid (X_clients).
      run adm/storei.w ( input parparentproc
                        ,input v-cntxt-host-code-obj
                        ,input X_store.obj-code
                        ,input {&update}
                        ,input-output ri).
      display
      X_clients.obj-name
      X_clients.grp-name
      X_store.shift-on
      with browse br-stores.
  end.
END.

ON CHOOSE OF b-del IN FRAME d-store /* Удалить */
DO:
  define variable ri as recid no-undo.
  if available X_store then do:
    ri = recid(X_store).
    run ref/clients2.p ( input parparentproc
                        ,input recid(X_clients)
                        ,input ? /*p-stts*/
                        ,input no /*p-silent*/
                        ,input yes /*отсюда можно удалить и {&shop}*/
                        ,input '':U /*p-mode2*/
                        ,input '':U /*p-source-type*/
                        ,input '':U /*p-source-ref*/
                        ) no-error .
    if error-status:error then do:
      return no-apply.
    end.
    run Openbr in this-procedure .
    reposition br-stores to recid ri no-error.
    apply "ENTRY" to br-stores.
    apply "value-changed" to br-stores.
  end.
END.

ON CHOOSE OF b-lkp IN FRAME d-store /* Просм */
DO:
  define variable ri as recid no-undo.
  if available X_store then do:
      ri = recid (X_clients).
      run adm/storei.w ( input parparentproc
                        ,input v-cntxt-host-code-obj
                        ,input X_store.obj-code
                        ,input {&lookup}
                        ,input-output ri).
      apply "entry" to browse br-stores.
  end.
END.

ON CHOOSE OF b-price IN FRAME {&frame-name} /* Цены */
DO:
  if not available X_store then return no-apply.
  define variable v-rec-list as character no-undo .
  run str/pdfobj.w
        ( input parparentproc ,
          input "all" ,
          input {&stock} ,
          input X_store.obj-code ,
          input ? ,
          input ? ,
          input "b-add,b-del,b-chg" ,
          input-output v-rec-list
          ) .
END.

ON CHOOSE OF b-quit IN FRAME d-store /* Выход */
DO:

END.

{ gbl/app_help.i
 &frame-name="d-store"
 &browse-name="br-stores"
 }

ON CHOOSE OF B-hist IN FRAME d-store /* История */
DO:
  define variable v-loc-rid-list as character no-undo .
     run ref/cclihist.w (
                      input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , "one":U /*p-mode*/
                    , input {&stock} /*p-obj-type*/
                    , input X_store.obj-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-loc-rid-list  ) no-error .

END.


ON CHOOSE OF b-print IN FRAME d-store /* {&print} */
DO:
  run rep/stor-prt.p (input parparentproc) .
END.

ON CHOOSE OF b-sel IN FRAME d-store /* {&choose} */
DO:
  define variable v-ind         as integer   no-undo .
  define variable v-num-entries as integer   no-undo .

  define buffer buf_store   for ub.store .
  define buffer buf_clients for ub.clients .


  if v-rid-list = ""
  or b-mark:sensitive = no
  then do:
    v-rid-list = string (recid (X_store)).
  end.

  assign
    v-num-entries = num-entries( v-rid-list )
  .
  do v-ind = 1 to v-num-entries
  :
    find first buf_store no-lock
      where recid( buf_store ) = integer( entry( v-ind, v-rid-list ) )
    .
    find first buf_clients no-lock
      where buf_clients.obj-type = {&stock}
        and buf_clients.obj-code = buf_store.obj-code
      no-error
    .
    if available buf_clients
      and buf_clients.stts <> 0
    then do:
      entry(v-ind, v-rid-list) = '':U.
      v-rid-list  = replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
      message substitute( "Склад &1 удален и не может быть выбран.", buf_store.obj-code ).
      return no-apply.
    end.
  end.
END.

ON CHOOSE OF b-right IN FRAME d-store /* Права */
DO:
  if available X_store
  then do:
    run adm/obj-usr.w
      (input  parparentproc
      ,input  v-cntxt-db-num
      ,input  {&stock}
      ,input  X_store.obj-code
      ).
  end.
END.

on return, MOUSE-SELECT-DBLCLICK of br-stores in frame {&frame-name} do:
  if b-sel:sensitive then
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else apply "choose" to b-sel in frame {&frame-name}.
  else if b-chg:sensitive then apply "choose" to b-chg in frame {&frame-name}.
end.

on choose of b-mark in frame {&frame-name} do:
define variable glog as logical no-undo .
  if available X_clients then do:
    if X_clients.stts <> 0 then do:
      message
      "Данный объект удален и не может быть выбран."
      view-as alert-box error
      .
      return no-apply.
    end.
  end.
  else return no-apply.
  { gbl/markstrn.i X_store v-rid-list }
  glog = br-stores:refresh() in frame {&frame-name}.
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
    glog = br-stores:select-next-row ().
    apply "iteration-changed" to br-stores in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then hide mark-num in frame {&frame-name}.
  else disp num-entries (v-rid-list) @ mark-num with frame {&frame-name}.
  apply "entry" to br-stores in frame {&frame-name}.
end.

ON RETURN OF sch-code IN FRAME {&frame-name}
DO:
define buffer buf_store for ub.store.
assign
sch-code.
  find first buf_store no-lock where
            buf_store.obj-code = sch-code no-error .
  if available buf_store then do:
    reposition br-stores to recid recid(buf_store) no-error .
    apply "ENTRY" to br-stores.
  end.
END.

ON CHOOSE OF B-grp IN FRAME {&frame-name}  /* Группа */
DO:
define variable lns-cnt as integer no-undo .
define variable g-grp as character no-undo .
define variable v-gds-rec as recid no-undo.
define variable ri as recid no-undo .
define variable glog as logical no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_cli-grp for ub.cli-grp.
define buffer buf_store for ub.store.
if not available X_clients then return no-apply.
ri = recid(X_store).
glog = yes.
message
"Выберите группу, в которую нужно" skip
"переместить склад(-ы)."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then   do:
  apply "entry" to br-stores in frame {&frame-name}.
  return no-apply.
end.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                 , input {&g#term} + ",b-sel"
                 , input-output g-grp ) .
if g-grp = "" then  do:
  apply "ENTRY" to br-stores.
  return no-apply.
end.
else do transaction:
    FIND buf_cli-grp where recid( buf_cli-grp ) = integer( g-grp ) .
    if v-rid-list = "" then
    v-rid-list = string( recid( X_store ) ) .
    lns-cnt = 1.
    DO WHILE lns-cnt <= num-entries( v-rid-list ) :
      v-gds-rec = integer( entry( lns-cnt, v-rid-list ) ) .
      if lns-cnt = 1 then ri = v-gds-rec.
      for each buf_store share-lock where recid(buf_store) = v-gds-rec,
              first buf_clients share-lock where
                  buf_clients.obj-type = {&stock}
              and buf_clients.obj-code = buf_store.obj-code
      on error  undo , next
      on stop   undo , next
      on endkey undo , next
      :
        buf_clients.grp-code = buf_cli-grp.node-code.
        lns-cnt = lns-cnt + 1.
      end.
    end.
    if lns-cnt < num-entries(v-rid-list) + 1 then do:
      message
      substitute("Удалось сменить групп для &1 складов", lns-cnt - 1)
      view-as alert-box error.
    end.
    v-rid-list = "".
    mark-num = 0.
    hide mark-num in frame {&frame-name}.
end. /*end transaction*/
run Openbr in this-procedure .
reposition br-stores to recid ri no-error.
apply "ENTRY" to br-stores.
apply "value-changed" to br-stores.
END.



/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/brwrefre.i " v-doc-rec = recid(X_store).  ~
  run OpenBR in this-procedure.   REPOSITION br-stores to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-stores. " }

{ gbl/brwrepos.i
  &line-num=5
  &browse-name=br-stores
}


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if lookup('s-deploy', bttns) > 0 then do:
  assign
  v-is-deploy = yes.
 end.
 { gbl/getcntxt.i get }
  v-exist-price-grp = false  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME d-store.
END PROCEDURE.

PROCEDURE enable_UI :
v-grp:VISIBLE IN BROWSe br-stores = v-exist-price-grp.
assign
B-attr:POPUP-MENU IN FRAME {&frame-name}       = MENU MENU-B-attr:HANDLE
b-attr:MENU-MOUSE in frame {&frame-name} = 1
B-cli-attr:POPUP-MENU IN FRAME {&frame-name}       = MENU MENU-B-cli-attr:HANDLE
b-cli-attr:MENU-MOUSE in frame {&frame-name} = 1
X_clients.obj-name:resizable  in browse br-stores = true
X_cli-host.obj-name:resizable in browse br-stores = true
X_clients.grp-name:resizable  in browse br-stores = true
v-grp:resizable  in browse br-stores = true
.
v-rid-list = p-rid-list.
hide mark-num in frame {&frame-name}.
ENABLE
br-stores
b-quit
b-lkp
b-print when not v-is-deploy
b-right
b-help
b-price
b-add WHEN v-cntxt-db-num = 0 and can-do (bttns, "b-add")
b-chg WHEN v-cntxt-db-num = 0  and can-do (bttns, "b-add")
b-del WHEN v-cntxt-db-num = 0  and can-do (bttns, "b-add")
b-grp WHEN v-cntxt-db-num = 0  and can-do (bttns, "b-add")
b-mark when can-do (bttns, "b-mark")
b-sel when can-do (bttns, "b-sel")
b-hist when not v-is-deploy
b-attr when not v-is-deploy
b-cli-attr when not v-is-deploy
sch-code
WITH FRAME {&frame-name}.
run openbr in this-procedure .
if v-rid-list <> '':U then do:
  reposition br-stores to recid(integer(entry(1, v-rid-list))) no-error.
end.
apply "ENTRY" to br-stores.
apply "VALUE-CHANGED" to br-stores.
END PROCEDURE.

procedure Openbr :
if p-only-cur-db-num  = yes then do:
  OPEN QUERY br-stores
  FOR EACH X_store NO-LOCK,
  EACH X_clients WHERE
       X_clients.obj-code = X_store.obj-code
   and X_clients.obj-type = {&stock}
   and X_clients.db-num   = v-cntxt-db-num NO-LOCK,
   each X_cli-host where
        X_cli-host.obj-code = X_store.host-code
   and X_cli-host.obj-type = {&cmp} no-lock BY X_store.obj-code.
end.
else do:
  OPEN QUERY br-stores
  FOR EACH X_store NO-LOCK,
  EACH X_clients WHERE
       X_clients.obj-code = X_store.obj-code
   and X_clients.obj-type = {&stock} NO-LOCK,
   each X_cli-host where
        X_cli-host.obj-code = X_store.host-code
   and X_cli-host.obj-type = {&cmp} no-lock BY X_store.obj-code.
end.
end procedure. /* Openbr */
