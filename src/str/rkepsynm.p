block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rkepsynm.p $
$Archive: str/rkepsynm.p $

СИнхронизация названий товаров в IBS TH с товарами на кассе R-keeper

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
define variable vss-workfile    as character no-undo init "$Workfile: rkepsynm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsynm.p $":U .
define variable vss-description as character no-undo init "Синхронизация названий товаров в IBS TH с товарами на кассе R-keeper".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable is-jwlr as logical no-undo.
define variable is-bttl as logical no-undo.
define variable is-ptrl as logical no-undo.
define variable custvalue      as char no-undo.
define variable custtype       as char no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-gds-rec as recid no-undo .
define variable v-nbc as integer no-undo .
define variable v-stop-state as logical no-undo .


DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ii0 AS INTEGER NO-UNDO.
define variable ii-ok as integer no-undo .
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu .
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_gds-obj for ub.gds-obj.


{ cmp/gds-list.i gds-list def " " }
{ str/libbcrcn.i }
{ str/r-keepth.i }
{ str/tt-tax.i "new shared" tt-tax full }
{ ref/fbrglib.i }

&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При синхронизации данных произошли ошибки!!!'" ~
                    "'rkepsyn.txt'" ~}   ~
                    return

do
on error undo, return error return-value
:

FOR EACH gds-list:
  DELETE gds-list.
END.

assign
ii0 = num-entries(p-rid-list)
.


{ gbl/conf-rd.i
"'is-jwlr'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
assign
is-jwlr = (dops = "yes":U) no-error
.

{ gbl/conf-rd.i
"'is-bttl'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
assign
is-bttl = (dops = "yes":U) no-error
.
{ gbl/conf-rd.i
"'is-ptrl'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
assign
is-ptrl = (dops = "yes":U) no-error
.

{ gbl/conf-rd.i
 "'is-custm'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 custvalue
 custtype
 no-error
 }

{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }

_ii:
DO ii = 1 TO ii0:
   { str/rkepsyn.i
   &goods-lock = "exclusive-lock"
   }
   if locked buf_goods then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                               " - товар с кодом &5 - запись ЗАНЯТА"
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
   if buf_goods.unit-base <> buf_bar-code.unit-cli then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                               " - товар с кодом &5 - привязан бар-код с НЕОСНОВНОЙ ЕДИНИЦЕЙ ИЗМЕРЕНИЯ - синхронизация по названию НЕВОЗМОЖНА"
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

   find first buf_gds-prt no-lock where
            buf_gds-prt.upper-code = buf_goods.prt-root no-error.
  if buf_gds-prt.node-name <> {&empty-scale} then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                               " - товар с кодом &5 - НЕПУСТАЯ ШКАЛА - синхронизация по названию НЕВОЗМОЖНА"
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
  if buf_goods.gds-type = {&gds-office} then dO:
      FIND FIRST buf_gds-obj no-lock where
                buf_gds-obj.gds-code = buf_goods.gds-code
            AND buf_gds-obj.obj-type = p-curr-obj-type
            AND buf_gds-obj.obj-code = p-curr-obj-code no-error .
    end.

  assign
  v-gds-rec = recid(buf_goods).
  if buf_goods.chk-name <> buf_cd-plu.charkey_one then do:
      run ref/goods01.p (
      input parparentproc
    , input {&update}
    , input no /*par-copymode */
    , input 0 /*par-alt-bc-mode as integer нужно ли вводить ДОП БК вместе с товаром*/
    , input no /*par-manual as logical мз карточки товара - yes*/
    , input yes /*par-silence as logical  ругаемся вслух или ?*/
    , input no /* import */
    , input no /*par-file as logical идет импоррт из файла - из карточки товара*/
    , input no /*par-single-record as logical надо сохранить только одну запись - потом выход в справ*/
    , input v-host-code /*par-host-code like ub.sysconf.host-code */
    , input p-curr-obj-type /*par-obj-type like ub.clients.obj-type */
    , input p-curr-obj-code /*par-obj-code like ub.clients.obj-code */
    , input (buf_goods.gds-type = {&gds-office}) /*товар - yes услуга no*/
    , input ? /*par-copy-rec as recid recid записи с которой копируем*/
    , input buf_goods.gds-code
    , input buf_goods.artic
    , input buf_goods.prod-type
    , input buf_goods.prod-code
    , input buf_gds-prt.node-code
    , input buf_goods.grp-code
    , input buf_goods.gds-name
    , input "":U /*par-saved-name like ub.goods.gds-name no-undo */
    , input buf_goods.engl-name
    , input buf_goods.label-name
    , input buf_cd-plu.charkey_one
    , input buf_goods.alpha1
    , input buf_goods.unit-base
    , input buf_goods.unit-cli
    , input buf_goods.max-rate
    , input buf_goods.min-rate
    , input buf_goods.cli-base-rate
    , input buf_goods.qnty-cart
    , input buf_goods.ms-cart    /* todo base!!!!*/
    , input buf_goods.wt-cart    /**/
    , input buf_goods.ms-cart
    , input buf_goods.wt-cart
    , input buf_goods.calc-method
    , input buf_goods.increase-pc
    , input buf_goods.negative-rest
    , input (if buf_goods.gds-type = {&gds-office} and available buf_gds-obj
            then buf_gds-obj.price-base
            else 0)
    , input (if buf_goods.gds-type = {&gds-office} and available buf_gds-obj
            then  buf_gds-obj.price-rubl
            else 0)
    , input buf_goods.okdp
    , input buf_goods.destin
    , input buf_goods.attrib
    , input buf_goods.user-rule
    , input buf_goods.sert
    , input buf_goods.struct
    , input buf_goods.deadline
    , input buf_goods.cond-keep-code
    , input buf_goods.sort
    , input buf_goods.proof
    , input buf_goods.normal-wastage
    , input buf_goods.normal-waste
    , input buf_goods.tnved
    , input buf_goods.nationality
    , input buf_goods.unit-cst
    , input buf_goods.cst-base-rate
    , input buf_goods.fbr-grp-code
    , input buf_goods.PS
    , input no /*unq-artc*/
    , input is-jwlr
    , input is-bttl
    , input is-ptrl
    , input custvalue
    , input no /*par-dif-nam1 нам неважно*/
    , input no /*par-dif-nam2 нам неважно */
    , input no /*par-ArtDis нам неважно */
    , input 0 /*par-BarDis нам неважно */
    , input-output v-gds-rec
    , output v-nbc
                      ) no-error .

    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                            " - не удалось синхронизировать с товар с кодом &5 по названию:&4&6 &7"
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
  end. /*if buf_goods.gds-name <> */
  buf_cd-plu.logkey_one = no.
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