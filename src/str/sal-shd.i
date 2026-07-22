/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с продажей  автоматом - при апгрейд или по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/31/09
Author: Bakhtadze Natalya
Creation date: 08/31/09

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" <> "" &then
&scop parparentproc {1}
&else
&scop parparentproc this-procedure
&endif

&if "{2}" <> "" &then
&scop log-handle {2}
&else
&scop log-handle this-procedure
&endif


procedure proc-step-100 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .
define input parameter p-finalize         as logical no-undo .

DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
DEFINE VARIABLE conf-attr AS character NO-UNDO.
DEFINE VARIABLE conf-par AS character NO-UNDO.
DEFINE VARIABLE par-type AS character NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-is-wth as character no-undo .
define variable is-wth as logical   no-undo .

/*в продажу закачивать чеки только по фильтру - если задан*/
define variable sale-filter as logical no-undo .
/*использовать смены на кассе для данного объекта*/
define variable cas-shft    as logical no-undo init no.
/*откуда были взяты курсы валют из спула или BO*/
define variable cas-curs    as logical no-undo init no.
/*откуда брать цены в накладную - из чека или из прайс-листа*/
define variable prcl-spl    as logical no-undo init no.
/*алгоритм размазывания чеков по типма кассового платежа*/
define variable pay-gds-algo as character no-undo.
/*код дорожного налога*/
define variable rdtaxcd     as INTEGER                  no-undo.
/*код акциза*/
define variable exctaxcd    as INTEGER                  no-undo.
/*фактор дор налога*/
define variable factorrt    as decimal no-undo.
/*код стеклопосуды*/
define variable btltaxcd    as INTEGER                  no-undo.
define variable p-day-only  as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

define buffer buf_inkas for ub.inkas.
DEFINE BUFFER buf_shop FOR ub.shop.
define buffer buf_trn-doc for ub.trn-doc.


  do
  on error undo, return error return-value
  :
   { gbl/conf-rd.i
      "'is-wth':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-wth
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    or v-is-wth <> 'yes':u
    then do:
      assign
      is-wth = no
      .
    end.
    else do:
      is-wth = yes.
    end.

    FIND FIRST buf_shop NO-LOCK WHERE
              buf_shop.obj-code = p-curr-obj-code .
    run gbl/tpsi-obj.p ( input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,output v-is-tpsi-obj) no-error .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  {&attr-autosale}
        ,input  "":U /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      run write-to-log in {&log-handle} (
            input substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-curr-obj-type
              , p-curr-obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )).
       undo, return.
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-curr-obj-type
          and thbjattr_thbj-attr.obj-code = p-curr-obj-code
          and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when {&attr-autosale_autocomp} then do:
          auto-comp = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_autofbr} then do:
          autofbr = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_one-curs} then do:
          one-curs = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_restdish} then do:
          restdish = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_restingr} then do:
          restingr = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_resttpsi} then do:
          resttpsi = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_prcl-spl} then do:
          prcl-spl = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_pay-gds-algo} then do:
          pay-gds-algo = thbjattr_thbj-attr.property-value-character.
        end.
        when {&attr-autosale_sale-filter} then do:
          sale-filter = thbjattr_thbj-attr.property-value-logical.
        end.
      end case.
      assign
      restdish = restdish and autofbr
      restingr = restingr and autofbr
      resttpsi = resttpsi and v-is-tpsi-obj
      .
    end.
    run adm/shattri.p (
        input "get":U
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  {&attr-get-chk}
        ,input  "":U /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      run write-to-log in {&log-handle} (
            input substitute("Ошибка при получении опций закачик чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-curr-obj-type
              , p-curr-obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )).
       undo, return.
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-curr-obj-type
          and thbjattr_thbj-attr.obj-code = p-curr-obj-code
          and thbjattr_thbj-attr.upper-prop-code = {&attr-get-chk}
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when {&attr-get-chk_cas-shft} then do:
          assign
          cas-shft = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-get-chk_cas-curs} then do:
          assign
          cas-curs = thbjattr_thbj-attr.property-value-logical.
        end.
      end case.
    end.
    assign
    rdtaxcd  = integer({&road-tax-code})
    exctaxcd = integer({&excise-tax-code})
    btltaxcd = integer({&road-tax-code}).

    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = {&g___new},
      first buf_trn-doc where
           buf_trn-doc.doc-code = buf_inkas.inkas-code:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      if buf_trn-doc.flag_ <> no then NEXT _inkas.
      assign
      v-parameter =     string(if p-finalize then 3 else 2) /*p-auto*/
                                                        + {&delim-par} +
                        buf_inkas.inkas-code            + {&delim-par} +
                        string(sale-filter)             + {&delim-par} +
                        v-curr-r-b                      + {&delim-par} +
                        string(is-wth)                  + {&delim-par} +
                        string(cas-shft)                + {&delim-par} +
                        string(one-curs)                + {&delim-par} +
                        string(cas-curs)                + {&delim-par} +
                        string(prcl-spl)                + {&delim-par} +
                        pay-gds-algo                    + {&delim-par} +
                        string(rdtaxcd)                 + {&delim-par} +
                        string(exctaxcd)                + {&delim-par} +
                        string(factorrt)                + {&delim-par} +
                        string(btltaxcd)                + {&delim-par} +
                        string(buf_shop.day-only)
      .
      run str/saleincl.p (
                      input {&parparentproc}
                     ,input this-procedure
                     ,input {&log-handle}
                     ,input v-parameter
                     )  no-error.
      if error-status:error
      and return-value <> "error"
      then do:
        run write-to-log in {&log-handle} (
              input substitute( "!!!Ошибка при закачке чеков в документ продажи &1 в &2&3&4" +
                                "&5 &6"
                              , buf_inkas.inkas-code
                              , p-curr-obj-type
                              , p-curr-obj-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              )            ).
         next _inkas.
      end.
    end. /*for each buf_inkas where*/
  end.

end procedure. /* proc-step-100 */



procedure proc-step-200 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .
define input parameter p-finalize         as logical no-undo .

DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
/*уводить чужой весовой товар в отриц остатки*/
define variable neg-tpsi-weight as logical no-undo .
/*уводить чужой товар в отриц остатки по отметке оператора*/
define variable neg-tpsi-oper as logical no-undo .
/*уводить чужой товар в отриц остатки если недостает меньше чем*/
define variable neg-tpsi-qnty as decimal no-undo .
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


DEFINE BUFFER buf_shop FOR ub.shop.
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.


  do
  on error undo, return error
  :

   FIND FIRST buf_shop NO-LOCK WHERE
             buf_shop.obj-code = p-curr-obj-code.
   run gbl/tpsi-obj.p (
                  input p-curr-obj-type
                , input p-curr-obj-code
                , output v-is-tpsi-obj) no-error .
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-curr-obj-type
      ,input  p-curr-obj-code
      ,input  {&attr-autosale}
      ,input  "":U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
    run write-to-log in {&log-handle} (
          input substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , p-curr-obj-type
            , p-curr-obj-code
            , {&new-line}
            , error-status:get-message(1)
            , return-value )).
      undo, return.
  end.
  for each  thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-curr-obj-type
        and thbjattr_thbj-attr.obj-code = p-curr-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    case thbjattr_thbj-attr.prop-code:
      when {&attr-autosale_autofbr} then do:
        autofbr = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-autosale_one-curs} then do:
        one-curs = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-autosale_restdish} then do:
        restdish = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-autosale_restingr} then do:
        restingr = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-autosale_resttpsi} then do:
        resttpsi = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-autosale_neg-tpsi-weight} then do:
        neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-autosale_neg-tpsi-qnty} then do:
        neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
      end.
      when {&attr-autosale_neg-tpsi-oper} then do:
        neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
      end.
    end case.
    assign
    restdish = restdish and autofbr
    restingr = restingr and autofbr
    resttpsi = resttpsi and v-is-tpsi-obj
    .
  end.
    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = {&g___new},
        first buf_trn-doc where
              buf_trn-doc.doc-code = buf_inkas.inkas-code:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      /*по требованию филипповой*/
      /*if buf_trn-doc.flag_ <> yes then next _inkas.*/
      assign
      v-parameter =   v-curr-r-b                       + {&delim-par} +
                      buf_inkas.inkas-code             + {&delim-par} +
                      string(if p-finalize then 3 else 2) /*p-auto*/
                                                       + {&delim-par} +
                      string(autofbr)                  + {&delim-par} +
                      string(buf_shop.is-catering)     + {&delim-par} +
                      string(v-is-tpsi-obj)            + {&delim-par} +
                      string(restdish)                 + {&delim-par} +
                      string(restingr)                 + {&delim-par} +
                      string(resttpsi)                 + {&delim-par} +
                      string(neg-tpsi-weight)          + {&delim-par} +
                      string(neg-tpsi-qnty)            + {&delim-par} +
                      string(neg-tpsi-oper)
      .
&scop my-message substitute("Обработка продажи &1............"                          ~
                            , buf_inkas.inkas-code)

{&display-message}.
      run str/salersrv.p (
                      input {&parparentproc}
                     ,input this-procedure
                     ,input {&log-handle}
                     ,input v-parameter
                     )  no-error.
      if error-status:error
      and return-value <> "error"
      then do:
        run write-to-log in {&log-handle} (
              input substitute( "!!!Ошибка при резервировании в документе продажи &1 в &2&3&4" +
                                "&5 &6"
                              , buf_inkas.inkas-code
                              , p-curr-obj-type
                              , p-curr-obj-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              )            ).
         next _inkas.
      end.
    end. /*for each buf_inkas*/
  end. /*doe*/

end procedure. /* proc-step-200 */

procedure proc-step-300 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .

DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
/*уводить чужой весовой товар в отриц остатки*/
define variable neg-tpsi-weight as logical no-undo .
/*уводить чужой товар в отриц остатки по отметке оператора*/
define variable neg-tpsi-oper as logical no-undo .
/*уводить чужой товар в отриц остатки если недостает меньше чем*/
define variable neg-tpsi-qnty as decimal no-undo .
/*закрывать приход по техпроливу*/
define variable close-in-rfsl as integer no-undo .
/*список алгоритмов для размазывания chk-gds-pay*/
define variable pay-gds-algo as character no-undo .
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

DEFINE BUFFER buf_shop FOR ub.shop.
define buffer buf_inkas for ub.inkas.

  do
  on error undo, return error
  :
    find first buf_shop no-lock where buf_shop.obj-code = p-curr-obj-code.
    run gbl/tpsi-obj.p (
                   input p-curr-obj-type
                 , input p-curr-obj-code
                 , output v-is-tpsi-obj) no-error .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  {&attr-autosale}
        ,input  "":U /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      run write-to-log in {&log-handle} (
            input substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-curr-obj-type
              , p-curr-obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )).
       undo, return.
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-curr-obj-type
          and thbjattr_thbj-attr.obj-code = p-curr-obj-code
          and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when {&attr-autosale_autocomp} then do:
          auto-comp = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_autofbr} then do:
          autofbr = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_one-curs} then do:
          one-curs = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_restdish} then do:
          restdish = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_restingr} then do:
          restingr = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_resttpsi} then do:
          resttpsi = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_neg-tpsi-weight} then do:
          neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_neg-tpsi-oper} then do:
          neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_neg-tpsi-qnty} then do:
          neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
        end.
        when {&attr-autosale_close-in-rfsl} then do:
          close-in-rfsl = thbjattr_thbj-attr.property-value-integer.
        end.
        when {&attr-autosale_pay-gds-algo} then do:
          pay-gds-algo = thbjattr_thbj-attr.property-value-character.
        end.
      end case.
    end.
    assign
    restdish = restdish and autofbr
    restingr = restingr and autofbr
    resttpsi = resttpsi and v-is-tpsi-obj
    neg-tpsi-weight = neg-tpsi-weight and v-is-tpsi-obj
    neg-tpsi-oper = neg-tpsi-oper and v-is-tpsi-obj
    .
    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = {&doc-froze}:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      assign
      v-parameter =   v-curr-r-b                       + {&delim-par} +
                      buf_inkas.inkas-code             + {&delim-par} +
                      string(2) /*p-auto*/             + {&delim-par} +
                      string(YES) /*auto-close*/       + {&delim-par} +
                      string(no) /*b-mail-pressed*/    + {&delim-par} +
                      string(auto-comp)                + {&delim-par} +
                      string(autofbr)                  + {&delim-par} +
                      string(one-curs)                 + {&delim-par} +
                      string(buf_shop.is-catering)     + {&delim-par} +
                      string(v-is-tpsi-obj)            + {&delim-par} +
                      string(restdish)                 + {&delim-par} +
                      string(restingr)                 + {&delim-par} +
                      string(resttpsi)                 + {&delim-par} +
                      string(neg-tpsi-weight)          + {&delim-par} +
                      string(neg-tpsi-qnty)            + {&delim-par} +
                      string(neg-tpsi-oper)            + {&delim-par} +
                      string(close-in-rfsl)            + {&delim-par} +
                      pay-gds-algo

      .
&scop my-message substitute("Обработка продажи &1........."                          ~
                            , buf_inkas.inkas-code)
{&display-message}.

      run str/saleclos.p (
                      input {&parparentproc}
                     ,input this-procedure
                     ,input {&log-handle}
                     ,input v-parameter
                     )  no-error.
      if error-status:error
      and return-value <> "error"
      then do:
        run write-to-log in {&log-handle} (
              input substitute( "!!!Ошибка при закрытии на факт документа продажи &1 в &2&3&4" +
                                "&5 &6"
                              , buf_inkas.inkas-code
                              , p-curr-obj-type
                              , p-curr-obj-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              )            ).
         next _inkas.
      end.
    end. /*for each buf_Inkas*/
  end. /*doe*/

end procedure. /* proc-step-300 */


procedure proc-step-400 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .

define variable v-parameter as character no-undo .

define buffer buf_inkas for ub.inkas.
define buffer buf_chk-doc for ub.chk-doc.

  do
  on error undo, return error
  :
    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = {&g___new}:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      find first buf_chk-doc no-lock where
                buf_chk-doc.obj-type = p-curr-obj-type
            AND buf_chk-doc.obj-code = p-curr-obj-code
            AND buf_chk-doc.out-code = buf_inkas.inkas-code no-error.
      if not available buf_chk-doc then do:
        assign
        v-parameter = string(2)                 + {&delim-par} + /*p-auto*/
                      p-curr-obj-type           + {&delim-par} +
                      string(p-curr-obj-code)   + {&delim-par} +
                      string(no)                + {&delim-par} +  /*forced*/
                      buf_inkas.inkas-code
        .
        run str/del-sale.p (
                        input {&parparentproc}
                      ,input this-procedure
                      ,input {&log-handle}
                      ,input v-parameter
                      )  no-error.
        if error-status:error
        and return-value <> "error"
        then do:
          run write-to-log in {&log-handle} (
                input substitute( "!!!Ошибка при удалении пустой (без чеков) продажи &1 в &2&3&4" +
                                  "&5 &6"
                                , buf_inkas.inkas-code
                                , p-curr-obj-type
                                , p-curr-obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
          next _inkas.
        end. /*error-status*/
      end. /*if not available buf_chk-doc then do:*/
    end. /*for each buf_inkas*/
  end. /*doe*/
end procedure. /* proc-step-400 */

procedure get-db-num:
  
  define output parameter pDbNum as integer no-undo.
  
  pDbNum = g#db-num.

end.

procedure get-userid:

  define output parameter pUserId as character no-undo.

  assign
    pUserId  = g#userid
    .
  
end.

/* $Workfile$ e n d */