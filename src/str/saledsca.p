block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: saledsca.p $
$Archive: str/saledsca.p $

Печать приложения к продаже - акт по скидкам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define output parameter p-frame-width as integer no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: saledsca.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/saledsca.p $":U .
def var vss-description as character no-undo init "Печать приложения к продаже - акт по скидкам".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }

DEFINE VARIABLE Line                as character                    no-undo .

define variable v-ov-base           as decimal no-undo .
define variable v-ov-rubl           as decimal no-undo .
define variable v-num as integer no-undo .
define variable v-str as character no-undo extent 7.
define variable ii as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-r-b-abbr as character no-undo .
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log as logical no-undo .



define buffer buf_inkas for ub.inkas .
define buffer buf_shop for ub.shop.
define buffer buf_clients for ub.clients.


do
on error undo, return error
:
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  find first buf_inkas no-lock where
              buf_inkas.inkas-code = p-inkas-code no-error .
  if NOT available buf_inkas then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неправильный выбор кассового отчета."
    view-as alert-box WARNING .
    return error .
  end.
  { gbl/r-b-abbr.i
   buf_inkas.host-code
   v-r-b-abbr }
  find first buf_shop no-lock where
            buf_shop.obj-code = buf_inkas.obj-code no-error .
  if not available buf_shop then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден объект для кассового отчета." p-inkas-code
    view-as alert-box WARNING .
    return error .
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = {&shop}
        AND buf_clients.obj-code = buf_shop.obj-code no-error .
  run calculate-discnt in this-procedure (
                                           input v-curr-r-b
                                         , input buf_inkas.inkas-code
                                         , output v-ov-base
                                         , output v-ov-rubl) no-error .
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при подсчете скидок по переоценкн для кассового отчета." p-inkas-code skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box WARNING .
    undo, return error .
  end.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  assign
  v-str[1] = "Приложение к реализации, прошедшей"
  v-str[2] = substitute("через кассу  №&1 за &2"
                        , buf_inkas.inkas-code
                        , string(buf_inkas.doc-date, "99/99/9999")
                        )
  v-str[3] = "":U
  v-str[4] = "":U
  v-str[5] = '"У Т В Е Р Ж Д А Ю"'
  v-str[6] = "":U
  v-str[7] = substitute("Директор маг. &1 &2"
                        , (if available buf_clients
                           then buf_clients.obj-name
                           else ("№ " + string(Buf_shop.obj-code))
                           )
                        ,  buf_shop.director).

  .
  do ii = 1 to 7:
    assign
    v-num = length(v-str[ii])
    .
    PUT  STREAM PrnLibStream unformatted
    fill( {&space-char} , {&A4_cW0} - v-num)
    v-str[ii]
    skip.

  end .
  PUT  STREAM PrnLibStream unformatted skip(2).
  assign
  v-str[1] = "А К Т"
  v-str[2] = "":U
  v-str[3] = "":U
  v-str[4] = substitute("Скидки по дисконту      &1 &2"
                        , string(round(buf_inkas.discnt, 2)
                        , "->>>,>>>,>>>,>>9.99")
                        , v-r-b-abbr
                        )
  v-str[5] = substitute("Скидки по переоценкам   &1 &2"
                        , string(
                                  round(if v-curr-r-b = {&r-b-base}
                                  then (v-ov-base - buf_inkas.discnt)
                                  else (v-ov-rubl - buf_inkas.discnt), 2)
                                 , "->>>,>>>,>>>,>>9.99")
                        , v-r-b-abbr
                           )
  v-str[6] = "":U
  v-str[7] = substitute("ИТОГО скидки:           &1 &2"
                        ,  string(
                                  round(if v-curr-r-b = {&r-b-base}
                                  then v-ov-base
                                  else v-ov-rubl, 2)
                                  , "->>>,>>>,>>>,>>9.99")
                        , v-r-b-abbr
                        )
  .
  do ii = 1 to 7:
    assign
    v-num = length(v-str[ii])
    .
    PUT  STREAM PrnLibStream unformatted
    fill({&space-char} , integer(truncate(({&A4_cW0} - v-num) / 2, 0)))
    v-str[ii]
    fill({&space-char} , integer(truncate(({&A4_cW0} - v-num) / 2, 0)))
    skip
    .
  end.
  PUT  STREAM PrnLibStream unformatted skip(2)
  .
  assign
  v-str[1] = substitute("Директор магазина                                        &1"
                        , buf_shop.director)
  .
  do ii = 1 to 1:
    PUT  STREAM PrnLibStream unformatted
    v-str[ii]
    skip
    .
  end.
  PUT  STREAM PrnLibStream unformatted
  skip(2)
  fill("_":U, {&A4_cW0}) skip.
  output  STREAM PrnLibStream CLOSE.
  run get-report-num  in parParentProc(output g#report-num).
  run get-quest-print in parParentProc(output g#quest-print).
  { rep/q-print.i 8 }

end. /*doe*/




procedure calculate-discnt :
define input parameter p-curr-r-b as character no-undo .
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define output parameter p-ov-base as decimal no-undo .
define output parameter p-ov-rubl as decimal no-undo .

define variable v-b-code like ub.bar-code.b-code no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-doc-num         like ub.price-doc.doc-num     no-undo.
define variable v-price-sale      like ub.price-list.price-sale no-undo.
define variable v-price-base      like ub.price-list.price-sale no-undo.
define variable v-price-rubl      like ub.price-list.price-sale no-undo.
define variable v-road-tax        like ub.price-list.road-tax   no-undo.
define variable v-excise          like ub.price-list.excise     no-undo.


define buffer buf_trn for ub.trn-doc.
define buffer buf_ret for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.

  do
  on error undo, return error
  :
    find first buf_trn no-lock where
              buf_trn.doc-code = p-inkas-code no-error .
    if not available buf_trn then do:
      undo, return error substitute("Не найдена расходная часть для кассового отчета &1", p-inkas-code).
    end.
    find first buf_ret no-lock where
            buf_ret.doc-code = buf_trn.out-code no-error .
    run waitfram-show in this-procedure ("Ждите..." ).
    for each buf_doc-line no-lock where
             buf_doc-line.doc-code = buf_trn.doc-code:
      { gbl/gds-code.i buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code v-gds-code }
      for each buf_gds-dtl no-lock where
              buf_gds-dtl.doc-code = buf_trn.doc-code
         AND buf_gds-dtl.artic = buf_doc-line.artic
         AND buf_gds-dtl.prod-type = buf_doc-line.prod-type
         AND buf_gds-dtl.prod-code = buf_doc-line.prod-code   :
        /*
        { gbl/gdsbcode.i v-gds-code buf_gds-dtl.prt-code v-b-code no-error}
        { gbl/bcodeprc.i buf_trn.obj-type buf_trn.obj-code v-b-code 0 buf_trn.fact-order v-doc-num v-price-sale v-road-tax v-excise }

        if p-curr-r-b = {&r-b-base} then do:
          assign
          v-price-base = v-price-sale
          v-price-rubl = v-price-sale * buf_trn.base-rate / buf_trn.base-scale
          .
        end.
        else do:
          assign
          v-price-base = v-price-sale / buf_trn.base-rate * buf_trn.base-scale
          v-price-rubl = v-price-sale
          .
        end.

        assign
        p-ov-base = p-ov-base + v-price-base * buf_gds-dtl.fact-qnty - buf_gds-dtl.price-base * buf_gds-dtl.fact-qnty
        p-ov-rubl = p-ov-rubl + v-price-rubl * buf_gds-dtl.fact-qnty - buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty
        .
        */
        assign
        p-ov-base = p-ov-base + buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-base
        p-ov-rubl = p-ov-rubl + buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-rubl
        .
      end. /*for each buf_gds-dtl*/
    end. /*for each doc-line*/
    if available buf_ret then do:
      for each buf_doc-line no-lock where
              buf_doc-line.doc-code = buf_ret.doc-code:
        { gbl/gds-code.i buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code v-gds-code }
        for each buf_gds-dtl no-lock where
                buf_gds-dtl.doc-code = buf_ret.doc-code
          AND buf_gds-dtl.artic = buf_doc-line.artic
          AND buf_gds-dtl.prod-type = buf_doc-line.prod-type
          AND buf_gds-dtl.prod-code = buf_doc-line.prod-code   :
          /*
          { gbl/gdsbcode.i v-gds-code buf_gds-dtl.prt-code v-b-code no-error}
          { gbl/bcodeprc.i buf_trn.obj-type buf_trn.obj-code v-b-code 0 buf_trn.fact-order v-doc-num v-price-sale v-road-tax v-excise }

          if p-curr-r-b = {&r-b-base} then do:
            assign
            v-price-base = v-price-sale
            v-price-rubl = v-price-sale * buf_ret.base-rate / buf_trn.base-scale
            .
          end.
          else do:
            assign
            v-price-base = v-price-sale / buf_ret.base-rate * buf_trn.base-scale
            v-price-rubl = v-price-sale
            .
          end.
          assign
          p-ov-base = p-ov-base - (v-price-base * buf_gds-dtl.fact-qnty - buf_gds-dtl.price-base * buf_gds-dtl.fact-qnty)
          p-ov-rubl = p-ov-rubl - (v-price-rubl * buf_gds-dtl.fact-qnty - buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty)
          .
          */
          assign
          p-ov-base = p-ov-base + buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-base
          p-ov-rubl = p-ov-rubl + buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-rubl
          .
        end. /*for each buf_gds-dtl*/
      end. /*for each doc-line*/
    end. /*if available buf_ret*/
    run waitfram-hide in this-procedure .
  end.

end procedure. /* calculate-discnt */