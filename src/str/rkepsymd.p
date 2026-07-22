block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rkepsymd.p $
$Archive: str/rkepsymd.p $

Синхронизация признака модификатор и нулевая цена для товаров в IBS TH с товарами на кассе R-keeper

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/09/05
Author: Bakhtadze Natalya
Creation date: 02/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-rid-list as character no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkepsymd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsymd.p $":U .
define variable vss-description as character no-undo init "Синхронизация признака модификатор и нулевая цена  для товаров в IBS TH с товарами на кассе R-keeper".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-rid as recid no-undo .
define variable v-stop-state as logical no-undo .


DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ii0 AS INTEGER NO-UNDO.
define variable ii-ok as integer no-undo .
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu .
define buffer buf_cd-doc-line for ub.cd-doc-line.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.


{ cmp/gds-list.i gds-list def " " }
{ str/libbcrcn.i }
{ str/r-keepth.i }
{ ref/fbrglib.i }

&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При синхронизации данных произошли ошибки!!!'" ~
                    "'rkepsyn.txt'" ~}   ~
                    return

do
on error undo, return error
:

FOR EACH gds-list:
  DELETE gds-list.
END.
assign
ii0 = num-entries(p-rid-list)
.

{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }

_ii:
DO ii = 1 TO ii0:
  { str/rkepsyn.i
  &goods-lock = "no-lock"
  }
  find first buf_fbr-gds-obj exclusive-lock where
            buf_fbr-gds-obj.gds-code = buf_goods.gds-code
        AND buf_fbr-gds-obj.obj-type = p-curr-obj-type
        AND buf_fbr-gds-obj.obj-code = p-curr-obj-code no-wait no-error.
  if locked buf_fbr-gds-obj then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                              " - атрибуты РЕСТОРАН для товара с кодом &5 - запись ЗАНЯТА"
                            , buf_cd-plu.plu-code
                            , buf_cd-plu.key#_one
                            , buf_cd-plu.charkey_one
                            , {&new-line}
                            , buf_cd-plu.b-code
                          )).
    assign
    v-view-log = yes.
    next _ii.
  end.
  if available buf_Fbr-gds-obj then do:
    assign
    v-rid = recid(buf_Fbr-gds-obj)
    .
  end.


  find last buf_cd-doc-line NO-LOCK WHERE
            buf_cd-doc-line.obj-type = buf_cd-plu.obj-type
        and buf_cd-doc-line.obj-code = buf_cd-plu.obj-code
        and buf_cd-doc-line.pos-type = buf_cd-plu.pos-type
        and buf_cd-doc-line.doc-type = {&overvalue}
        and buf_cd-doc-line.plu-type = '':U
        and buf_cd-doc-line.plu-code = buf_cd-plu.plu-code use-index pi.
  if not available buf_cd-doc-line
  and buf_cd-plu.charkey_two <> "M":U
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Блюдо меню на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                              " - товар с кодом &5 - не найдена цена на кассе - синхронизация по атрибутам РЕСТОРАН НЕВОЗМОЖНА"
                            , buf_cd-plu.plu-code
                            , buf_cd-plu.key#_one
                            , buf_cd-plu.charkey_one
                            , {&new-line}
                            , buf_cd-plu.b-code
                          )).
    assign
    v-view-log = yes.
    next _ii.
  end.
  if not available buf_fbr-gds-obj
  or not buf_fbr-gds-obj.is-modificator
  or not buf_fbr-gds-obj.is-null-price then do:
    /*запишем атрибут РЕСТОРАН*/
    run ref/fgdsobj1.p (
                    input-output    v-rid
                    ,input (if available buf_fbr-gds-obj then {&update} else {&add-def})
                    ,input yes /*p-silent*/
                    ,input buf_goods.gds-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input (if available buf_fbr-gds-obj
                          then buf_fbr-gds-obj.fbr-grp-code
                          else 0)
                    ,input (if available buf_fbr-gds-obj
                          then buf_fbr-gds-obj.fbr-obj-type
                          else "":U)
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.fbr-obj-code
                            else 0)
                    ,input yes
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-menu
                            else no)
                    ,input (if  buf_cd-plu.charkey_two = "M":U
                            then yes
                            else no)
                    ,input (if buf_cd-plu.charkey_two = "M":U
                            then yes
                            else (if available buf_cd-doc-line
                                and buf_cd-doc-line.deckey_one <> 0.0
                                then no
                                else yes
                                )
                          )
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-season
                            else no)
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-semi-finished
                            else no)
                    ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                            " - не удалось синхронизировать с товар с кодом &5 по признакам МОДИФИКАТОр и НУЛЕВАЯ ЦЕНА:&4&6 &7"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , {&new-line}
                              , buf_cd-plu.b-code
                              , error-status:get-message(1)
                              , return-value
                            )).
      assign
      v-view-log = yes.
      next _ii.

    end.
  end. /*if avail buf_fbr-gds-obj*/
  buf_cd-plu.logkey_three = no.
  ii-ok = ii-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Обработано &1 блюд, из них упешно &2"
                                    , ii
                                    , ii-ok
                                    )) no-error.
  run get-stop-state in p-log-handle(output v-stop-state).
  if v-stop-state then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Процесс прерван пользователем"
                          )).
    assign
    v-view-log = yes.
    LEAVE _II.
  end.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "!!!Из &1 товаров успешно по названию синхронизировано &2"
                        , ii0
                        , ii-ok
                      )).


end. /*doe*/