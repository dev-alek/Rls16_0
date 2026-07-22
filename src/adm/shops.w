&Scop FRAME-NAME  d-shop
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник магазинов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/05
Author: Bakhtadze Natalya
Creation date: 09/13/05

Author:  Андрей Исаков
Created:  22.01.98

*/

define input        parameter parparentproc     as widget-handle no-undo .
define input        parameter bttns             as character     no-undo . /* список включенных кнопок */
define input-output parameter p-rid-list        as character     no-undo .
define input        parameter p-only-cur-db-num as logical       no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник магазинов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/thbjattr.i }
{ adm/shattrg.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ ref/xobjgrp.i  }
{ ref/aobjgrp.i  }
{ ref/pricegrp.i }

define variable mark-num as integer no-undo.
define variable attr-option as character no-undo .
define variable cli-attr-option as character no-undo .
define variable v-is-deploy as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-grp as character no-undo .
define variable v-exist-price-grp as logical   no-undo .
define buffer X_cli-host for ub.clients.
define buffer X_shop for ub.shop.
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

DEFINE BUTTON B-dis-rule
     LABEL "&Скидки"
     SIZE 10 BY 1.

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-rights
     LABEL "Пр&ава ":L
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


DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup       LABEL "&Просмотр"
       MENU-ITEM m_update          LABEL "Изменение"
       MENU-ITEM m_copy         LABEL "&Копирование"
       rule
       MENU-ITEM m_price-grp    LABEL "Группа ценообразования"
       .

DEFINE MENU MENU-B-cli-attr
       MENU-ITEM m_lookup-cli       LABEL "&Просмотр"
       MENU-ITEM m_update-cli        LABEL "Изменение"
       .
DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "код"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE QUERY br-shops FOR X_shop, X_clients, X_cli-host SCROLLING.

DEFINE BROWSE br-shops QUERY br-shops NO-LOCK DISPLAY
mark-string(recid(X_shop), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_shop.obj-code COLUMN-LABEL "Код " FORMAT ">>>>>>>>9"
X_clients.obj-name COLUMN-LABEL "Название " FORMAT "x(80)" width 25
X_cli-host.obj-name COLUMN-LABEL "Фирма" FORMAT "x(80)" width 25
(if X_clients.stts = 0 then " " else "+") format "x(1)" column-label "Удал"
X_clients.db-num FORMAT ">>>>>>>>9"
X_shop.shift-on COLUMN-LABEL "Смены":L format " + / - "
X_clients.grp-name COLUMN-LABEL "Группа" format "X(80)" width 25
price-grp ( buffer X_clients ) @ v-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(80)" width 25
WITH SIZE 98 BY 19 separators.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-shop
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-lkp AT ROW 1 COL 34
     b-chg AT ROW 1 COL 44
     b-del AT ROW 1 COL 54
     b-attr AT ROW 1 COL 64
     b-rights AT ROW 1 COL 74
     b-print AT ROW 1 COL 89
     b-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     mark-num at row 2 col 14 colon-aligned no-label view-as fill-in size 3 by 1 fgcolor 4
     sch-code AT ROW 2 COL 25
     b-cli-attr AT ROW 2 COL 54
     b-price AT ROW 2 COL 64
     b-dis-rule AT ROW 2 COL 74
     b-grp AT ROW 2 COL 84
     br-shops AT ROW 3.25 COL 1
     SPACE(0.74) SKIP(0.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "   Магазины" .

ASSIGN
       FRAME d-shop:SCROLLABLE       = FALSE
       br-shops:NUM-LOCKED-COLUMNS IN FRAME d-shop = 1.

/* ************************  Control Triggers  ************************ */

ON CHOOSE OF b-add IN FRAME d-shop /* Добав */
DO:
  define variable ri as recid no-undo.
  define buffer buf_shop for ub.shop.
  define buffer buf_clients for ub.clients.
  run adm/shopi.w ( input parparentproc
                   ,input v-cntxt-host-code-obj
                   ,input 0
                   ,input {&add-def}
                   ,input-output ri).
  if ri <> ? then do:
      find buf_clients where
           recid (buf_clients) = ri no-lock.
      find buf_shop where
          buf_shop.obj-code = buf_clients.obj-code no-lock.
      ri = recid (buf_shop).
      run enable_UI.
      reposition br-shops to recid ri no-error.
      apply "ENTRY" to br-shops.
  end.
  return no-apply.
END.

ON CHOOSE OF b-chg IN FRAME d-shop /* Измен */
DO:
  define variable ri as recid no-undo.
  if available X_shop then do:
      ri = recid (X_clients).
      run adm/shopi.w ( input parparentproc
                       ,input  X_shop.host-code
                       ,input X_shop.obj-code, {&update}, input-output ri).
      display
      X_clients.obj-name
      X_clients.grp-name
      X_shop.shift-on
      with browse br-shops.
  end.
END.

ON CHOOSE OF b-del IN FRAME d-shop /* Удалить */
DO:
  define variable  ri as recid no-undo.
  if available X_shop then do:
    ri = recid(X_shop).
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
    reposition br-shops to recid ri no-error.
    apply "ENTRY" to br-shops.
    apply "value-changed" to br-shops.
  end.
END.

ON CHOOSE OF b-lkp IN FRAME d-shop /* Просм */
DO:
  define variable ri as recid no-undo.
  if available X_shop then do:
      ri = recid (X_clients).
      run adm/shopi.w ( input parparentproc
                       ,input  v-cntxt-host-code-obj
                       ,input X_shop.obj-code
                       ,input {&lookup}
                       ,input-output ri).
      apply "entry" to browse br-shops.
  end.
END.

ON CHOOSE OF b-quit IN FRAME d-shop /* Выход */
DO:

END.

{ gbl/app_help.i
  &frame-name="d-shop"
  &browse-name="br-shops"
  }


ON CHOOSE OF B-hist IN FRAME d-shop /* История */
DO:
  define variable v-loc-rid-list as character no-undo .
  if not available X_shop then return no-apply.
     run ref/cclihist.w (
                      input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , input "one":U /*p-mode*/
                    , input {&shop} /*p-obj-type*/
                    , input X_shop.obj-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-loc-rid-list  ) no-error .

END.

ON CHOOSE OF b-dis-rule IN FRAME d-shop /* {&print} */
DO:
define variable v-sts as integer no-undo .
define variable v-loc-rid-list as character no-undo .
if not available X_shop then return no-apply.
assign
v-sts = integer({&used-status-int}).
run ref/dis-ruls.w (
              input parparentproc
            , input 0 /*p-host-code*/
            , input {&shop}
            , input X_shop.obj-code
            , input "b-add":U
            , input {&g___object}
            , input 0       /*p-upper-rule-num*/
            , input ?       /*p-time-templ-rl-root*/
            , input 0 /*p-r-b-code*/
            , input-output v-sts
            , input-output v-loc-rid-list ) no-error .
END.

ON CHOOSE OF b-attr IN FRAME d-shop /* просмотр и изменение параметров */
DO:
define variable v-param as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
if not available X_shop then return no-apply.
if attr-option = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if attr-option = '':U then return no-apply.
if attr-option = {&update}
or attr-option = {&add-copy}
then do:
  if v-cntxt-db-num <> 0
  then do:
    { gbl/objdbnum.i {&shop} X_shop.obj-code v-db-num }
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
                                   ,input {&shop}
                                   ,input X_shop.obj-code) no-error .
if error-status:error then do:
  assign
  attr-option = "":u.
  return no-apply.
end.
attr-option = "":u.
END.

ON CHOOSE OF b-cli-attr IN FRAME d-shop  /* просмотр и изменение атрибутов*/
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 define variable v-db-num as integer no-undo .
 define variable ri as recid no-undo .
  if not available X_shop then do:
    return no-apply.
  end.
  ri = recid(X_shop).
  if cli-attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if cli-attr-option = "":U then do:
      return no-apply.
  end.
  if cli-attr-option = {&update}
  or cli-attr-option = {&add-copy} then do:
    if v-cntxt-db-num > 0 then do:
      { gbl/objdbnum.i {&shop} X_shop.obj-code v-db-num }
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
                   ,input {&shop}
                   ,input X_shop.obj-code
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


ON CHOOSE OF b-price IN FRAME d-shop /* Цены */
DO:
  if not available X_shop then return no-apply.
  define variable v-rec-list as character no-undo .
  run str/pdfobj.w
        ( input parparentproc ,
          input "all" ,
          input {&shop} ,
          input X_shop.obj-code ,
          input ? ,
          input ? ,
          input "b-add,b-del,b-chg" ,
          input-output v-rec-list
          ) .
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
  v-grp:visible in browse br-shops = true  .
  run enable_UI.

END.


ON CHOOSE OF b-print IN FRAME d-shop /* {&print} */
DO:
  run rep/shop-prt.p ( input parparentproc) .
END.

ON CHOOSE OF b-sel IN FRAME d-shop /* {&choose} */
DO:
  define variable v-ind         as integer   no-undo .
  define variable v-num-entries as integer   no-undo .

  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .

  if v-rid-list = "":U
  or b-mark:sensitive = no
  then do:
    v-rid-list = string (recid (X_shop)).
  end.

  assign
    v-num-entries = num-entries( v-rid-list )
  .
  do v-ind = 1 to v-num-entries
  :
    find first buf_shop no-lock
      where recid( buf_shop ) = integer( entry( v-ind, v-rid-list ) )
    .
    find first buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.obj-code = buf_shop.obj-code
      no-error
    .
    if available buf_clients
      and buf_clients.stts <> 0
    then do:
      entry(v-ind, v-rid-list) = '':U.
      v-rid-list  = replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
      message substitute( "Магазин &1 удален и не может быть выбран.", buf_shop.obj-code ).
      return no-apply.
    end.
  end.
END.

on go of frame d-shop do:
  p-rid-list = v-rid-list.
end.

ON CHOOSE OF b-rights IN FRAME d-shop /* Права */
DO:
  if available X_shop then do:
    run adm/obj-usr.w
      (input  parparentproc
      ,input  v-cntxt-db-num
      ,input  {&shop}
      ,input  X_shop.obj-code
      ).
  end.
END.

on return, MOUSE-SELECT-DBLCLICK of br-shops in frame {&frame-name} do:
  if b-sel:sensitive then
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else apply "choose" to b-sel in frame {&frame-name}.
  else if b-chg:sensitive then apply "choose" to b-chg in frame {&frame-name}.
end.

on choose of b-mark in frame {&frame-name} do:
define variable glog as logical no-undo .
  if available X_clients then do:
    if X_clients.stts <> 0 then do:
      message "Данный объект удален и не может быть выбран."
      view-as alert-box
      .
      return no-apply.
    end.
  end.
  else return no-apply.
  { gbl/markstrn.i X_shop v-rid-list }
  glog = br-shops:refresh() in frame {&frame-name}.
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
    glog = br-shops:select-next-row ().
    apply "iteration-changed" to br-shops in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then hide mark-num in frame {&frame-name}.
  else
  display
  num-entries (v-rid-list) @ mark-num with frame {&frame-name}.
  apply "entry" to br-shops in frame {&frame-name}.
end.

ON RETURN OF sch-code IN FRAME {&frame-name}
DO:
define buffer buf_shop for ub.shop.
assign
sch-code.
  find first buf_shop no-lock where
            buf_shop.obj-code = sch-code no-error .
  if available buf_shop then do:
    reposition br-shops to recid recid(buf_shop) no-error .
    apply "ENTRY" to br-shops.
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
define buffer buf_shop for ub.shop.
if not available X_clients then return no-apply.
ri = recid(X_shop).
glog = yes.
message
"Выберите группу, в которую нужно" skip
"переместить магазин(-ы)."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then   do:
  apply "entry" to br-shops in frame {&frame-name}.
  return no-apply.
end.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                 , input {&g#term} + ",b-sel"
                 , input-output g-grp ) .
if g-grp = "" then  do:
  apply "ENTRY" to br-shops.
  return no-apply.
end.
else do transaction:
    FIND buf_cli-grp where recid( buf_cli-grp ) = integer( g-grp ) .
    if v-rid-list = "" then
    v-rid-list = string( recid( X_shop) ) .
    lns-cnt = 1.
    DO WHILE lns-cnt <= num-entries( v-rid-list ) :
      v-gds-rec = integer( entry( lns-cnt, v-rid-list ) ) .
      if lns-cnt = 1 then ri = v-gds-rec.
      for each buf_shop share-lock where recid(buf_shop) = v-gds-rec,
              first buf_clients where
                  buf_clients.obj-type = {&shop}
              and buf_clients.obj-code = buf_shop.obj-code
      on error  undo , next
      on stop   undo , next
      on endkey undo , next
      :
        buf_clients.grp-code = buf_cli-grp.node-code.
        lns-cnt = lns-cnt + 1.
      end.
    END .
    if lns-cnt < num-entries(v-rid-list) + 1 then do:
      message
      substitute("Удалось сменить группу для &1 магазинов", lns-cnt - 1)
      view-as alert-box error.
    end.
    v-rid-list = "".
    mark-num = 0.
    hide mark-num in frame {&frame-name}.
end. /*end transaction*/
run Openbr in this-procedure .
reposition br-shops to recid ri no-error.
apply "ENTRY" to br-shops.
apply "value-changed" to br-shops.
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

{ gbl/brwrefre.i " v-doc-rec = recid(X_shop).  ~
  run OpenBR in this-procedure.   REPOSITION br-shops to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-shops. " }

{ gbl/brwrepos.i
  &line-num=5
  &browse-name=br-shops
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
  HIDE FRAME d-shop.
END PROCEDURE.

PROCEDURE enable_UI :

v-grp:VISIBLE IN BROWSe br-shops = v-exist-price-grp .
ASSIGN
B-attr:POPUP-MENU IN FRAME {&frame-name}       = MENU MENU-B-attr:HANDLE
b-attr:MENU-MOUSE in frame {&frame-name} = 1
B-cli-attr:POPUP-MENU IN FRAME {&frame-name}       = MENU MENU-B-cli-attr:HANDLE
b-cli-attr:MENU-MOUSE in frame {&frame-name} = 1
X_clients.obj-name:resizable  in browse br-shops = true
X_cli-host.obj-name:resizable in browse br-shops = true
X_clients.grp-name:resizable  in browse br-shops = true
v-grp:resizable  in browse br-shops = true
.
hide mark-num in frame {&frame-name}.
v-rid-list = p-rid-list.
ENABLE
br-shops
b-quit
b-lkp
b-print when not v-is-deploy
b-rights
b-help
b-price
b-add WHEN v-cntxt-db-num = 0 and can-do (bttns, "b-add")
b-chg WHEN v-cntxt-db-num = 0 and can-do (bttns, "b-add")
b-del WHEN v-cntxt-db-num = 0 and can-do (bttns, "b-add")
b-grp WHEN v-cntxt-db-num = 0 and can-do (bttns, "b-add")
b-mark when can-do (bttns, "b-mark")
b-sel when can-do (bttns, "b-sel")
b-dis-rule when not v-is-deploy
b-hist when not v-is-deploy
b-attr when not v-is-deploy
b-cli-attr when not v-is-deploy
sch-code
WITH FRAME {&frame-name} .
run openbr in this-procedure .
if v-rid-list <> '':U then do:
  reposition br-shops to recid(integer(entry(1, v-rid-list))) no-error.
  apply "ENTRY" to br-shops.
  apply "VALUE-CHANGED" to br-shops.
end.
END PROCEDURE.

procedure openbr :
  if p-only-cur-db-num  = yes then do:
    OPEN QUERY br-shops
    FOR EACH X_shop NO-LOCK,
    EACH X_clients WHERE
         X_clients.obj-code = X_shop.obj-code
     and X_clients.obj-type = {&shop}
     and X_clients.db-num   = v-cntxt-db-num NO-LOCK,
     each X_cli-host where
          X_cli-host.obj-code = X_shop.host-code
     and X_cli-host.obj-type = {&cmp} no-lock
    BY X_shop.obj-code.

  end.
  else do:
    OPEN QUERY br-shops
    FOR EACH X_shop NO-LOCK,
    EACH X_clients WHERE
         X_clients.obj-code = X_shop.obj-code
     and X_clients.obj-type = {&shop} NO-LOCK,
     each X_cli-host where
          X_cli-host.obj-code = X_shop.host-code
     and X_cli-host.obj-type = {&cmp} no-lock
    BY X_shop.obj-code.

  end.
end procedure. /* openbr */