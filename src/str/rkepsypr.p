block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rkepsypr.p $
$Archive: str/rkepsypr.p $

СИнхронизация цен товаров в IBS TH с товарами на кассе R-keeper

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
define variable vss-workfile    as character no-undo init "$Workfile: rkepsypr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsypr.p $":U .
define variable vss-description as character no-undo init "Синхронизация цен товаров в IBS TH с товарами на кассе R-keeper".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable store-type like ub.clients.obj-type no-undo .
define variable store-code like ub.clients.obj-code no-undo .
{ str/doc-code.i }
{ gbl/getcntxt.i def }
{ trg/check-bc.i }
{ str/alt-calc.i func }
{ str/alt-calc.i proc }
{ str/alt-calc.i "ver-modificator-price-is-null" }
{ str/alt-calc.i "exp-prt" }
{ ref/fbrglib.i }

define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

define variable v-price-doc-recid            as recid          no-undo .
define variable v-price-list-recid            as recid          no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ii0 AS INTEGER NO-UNDO.
define variable ii-ok as integer no-undo .
define variable main-code like ub.bar-code.b-code no-undo .
define variable v-update as logical no-undo .
define variable v-stop-state as logical no-undo .

define buffer buf_price-doc for ub.price-doc.
define buffer buf_price-list for ub.price-list.
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu .
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cd-doc-line for ub.cd-doc-line.

&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При синхронизации данных произошли ошибки!!!'" ~
                    "'rkepsyn.txt'" ~}   ~
                    return

_main:
do transaction
on error undo, return error return-value
:
  assign
  ii0    = num-entries(p-rid-list)
  .
  { gbl/getcntxt.i get }
  run prcreate-new-price-doc in this-procedure (
        input g#db-num
      , input p-curr-obj-type
      , input p-curr-obj-code
      ,?,?,?,?
      , output v-price-doc-recid
  ) no-error.
  if error-status:error
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Не удалось создать документ переоценки для синхронизации цен на кассе R-KEEPER и в IBS TH &1&2"
                            , p-curr-obj-type
                            , p-curr-obj-code
                          )).
    assign
    v-view-log = yes.
    {&view-log}.
  end.
  find first buf_price-doc exclusive-lock
        where recid( buf_price-doc ) = v-price-doc-recid
  .
  assign
  buf_price-doc.PS = "@ Импорт R-KEEPER"
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Для для синхронизации цен товаров на кассе R-KEEPER и в IBS TH создана переоценка &1&2 &3"
                          , p-curr-obj-type
                          , p-curr-obj-type
                          , buf_price-doc.doc-num
                        )).

  _ii:
  DO ii = 1 TO ii0
  on error undo _ii, next _ii
  :
    { str/rkepsyn.i
    &goods-lock = "no-lock"
    }
    { gbl/gdsbcode.i buf_goods.gds-code ? main-code }
    find last buf_cd-doc-line NO-LOCK WHERE
             buf_cd-doc-line.obj-type = buf_cd-plu.obj-type
         and buf_cd-doc-line.obj-code = buf_cd-plu.obj-code
         and buf_cd-doc-line.pos-type = buf_cd-plu.pos-type
         and buf_cd-doc-line.doc-type = {&overvalue}
         and buf_cd-doc-line.plu-type = '':U
         and buf_cd-doc-line.plu-code = buf_cd-plu.plu-code use-index pi.
    if not available buf_cd-doc-line
    or buf_cd-doc-line.deckey_one = 0.0
    then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                               " - товар с кодом &5 - не найдена или нулевая цена на кассе - синхронизация по цене НЕВОЗМОЖНА"
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
    run prcreate-new-price-list in this-procedure (
          input v-price-doc-recid
        , input buf_goods.gds-code
        , input buf_cd-doc-line.deckey_one
        , output v-update
    ) no-error.
    if error-status:error
    then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                               " - товар с кодом &5 - не удалось создать строку документа переоценки для главного кода товара &5"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , {&new-line}
                              , main-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
    end.
    if main-code <> buf_cd-plu.b-code then do:
      /*надо создать на неосновные и призрачные*/
      run cre-pr-list in this-procedure (
                                        input  buf_cd-plu.b-code  /* price-list.b-code*/
                                       ,input buf_price-doc.doc-num
                                       ,output v-price-list-recid ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                                " - товар с кодом &5 - не удалось создать строку документа переоценки для кода &5"
                                , buf_cd-plu.plu-code
                                , buf_cd-plu.key#_one
                                , buf_cd-plu.charkey_one
                                , {&new-line}
                                , main-code
                              )).
        assign
        v-view-log = yes.
        undo _ii, next _ii.
      end.
      find first buf_price-list where
                recid(buf_price-list) = v-price-doc-recid .
      assign
      buf_price-list.price-sale = buf_cd-doc-line.deckey_one
      .
    end.
    ii-ok = ii-ok + 1.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Обработано &1 блюд, из них упешно создано строк переоценки &2"
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
  end. /*do ii*/
  run hide-counter in p-log-handle .
  /*закроем переоценку*/
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Переоценка для синхронизации цен товаров на кассе R-KEEPER и в IBS TH &1&2 &3&4" +
                          "закрываем на факт"
                          , p-curr-obj-type
                          , p-curr-obj-type
                          , buf_price-doc.doc-num
                          , {&new-line}

                        )).



  run str/pr-stat.p (
                  input parparentproc
                 ,input p-log-handle
                 ,input "close-act":U /*p-mode*/
                 ,input buf_price-doc.doc-num
                 ,input ?
                 ,input true
                 ,input false
                 ) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                            " - товар с кодом &5 - не удалось создать строку документа переоценки для кода &5"
                            , buf_cd-plu.plu-code
                            , buf_cd-plu.key#_one
                            , buf_cd-plu.charkey_one
                            , {&new-line}
                            , main-code
                          )).
    v-view-log = yes.
    undo _main, leave _main.
  end.
  ii-ok = 0.
  DO ii = 1 TO ii0:
    FIND FIRST buf_cd-plu EXClUSIVE-lock WHERE
            RECID(buf_cd-plu) = INTEGER(ENTRY(ii, p-rid-list)) NO-ERROR.
     if available buf_cd-plu then do:
        find first buf_price-list no-lock where buf_price-list.doc-num = buf_price-doc.doc-num no-error .
        if available buf_price-list then do:
          buf_cd-plu.logkey_two = no.
          ii-ok = ii-ok + 1.
        end.
     end.
  end.
END. /*_main*/

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "!!!Из &1 товаров успешно по цене синхронизировано &2: номер переоценки &3"
                        , ii0
                        , ii-ok
                        , buf_price-doc.doc-num
                      )).