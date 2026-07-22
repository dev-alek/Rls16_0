block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-torg83.p $
$Archive: rep/r-torg83.p $

Акт о расхождении при приемке товара. ТОРГ-8.3 (Кедр-М)

Автор: Комаров Иван Сергеевич
Дата создания: 03/09/10
Author: Ivan Komarov
Creation date: 03/09/10

Автор1: Кочетков Михаил Юрьевич
Дата создания1: 04/13/06
*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-torg83.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-torg83.p $":U .
define variable vss-description as character no-undo initial "Акт о расхождении при приемке товара. ТОРГ-8.3 (Кедр-М)":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ gbl/paramls.i  }
do
on error undo, return error
:
define buffer t-doc             for ub.trn-doc .
define buffer buf_doc-line      for ub.doc-line .
define buffer buf_goods         for ub.goods .
define buffer buf_clients       for ub.clients .
define buffer buf_contract      for ub.contract .

define stream out-stream .
  define variable g#report-num as integer   no-undo .
  run get-report-num  in p-mainmenu-handle ( output g#report-num ) .

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in p-mainmenu-handle ( output g#quest-print ) .

  define variable g#log as logical   no-undo .
  DEFINE VARIABLE parParentProc     AS WIDGET-HandLE NO-UNDO.
  ASSIGN parParentProc =  p-mainmenu-handle .
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }

{ rep/r-tg83xl.i }

define variable v-par-type     as character no-undo .
define variable v-host-code    as integer   no-undo .
define variable v-curr-code    as integer   no-undo .
define variable v-attr-value   as character no-undo .
define variable v-attr-type    as character no-undo .
define variable qnty-i         as decimal   no-undo .
define variable qnty-n         as decimal   no-undo .
define variable v-doc-price    as decimal   no-undo .
define variable v-doc-sum      as decimal   no-undo .
define variable v-fact-price   as decimal   no-undo .
define variable v-fact-sum     as decimal   no-undo .
define variable v-sum-i        as decimal   no-undo .
define variable v-sum-n        as decimal   no-undo .
define variable all-qnty-i     as decimal   no-undo .
define variable all-qnty-n     as decimal   no-undo .
define variable all-sum-i      as decimal   no-undo .
define variable all-sum-n      as decimal   no-undo .
define variable all-sum        as decimal   no-undo .
define variable all-doc-qnty   as decimal   no-undo .
define variable all-fact-qnty  as decimal   no-undo .
define variable all-doc-sum    as decimal   no-undo .
define variable all-fact-sum   as decimal   no-undo .

define variable v-propis       as character no-undo .
define variable v-propis-cop   as character no-undo .
define variable v-itog         as decimal   no-undo .
define variable v-count        as integer   no-undo .

define variable v-nnakl        as character no-undo .
define variable v-dnakl        as character no-undo .
define variable v-ndog         as character no-undo .
define variable v-ddog         as character no-undo .
define variable v-Wrkr_name    as character no-undo .
define variable v-pass         as character no-undo .
define variable v-dover        as character no-undo .
define variable v-name-month   as character no-undo .
define variable v-docdate      as character no-undo .
define variable v-organization as character no-undo .

  find first t-doc no-lock where recid( t-doc ) = rec_id .

  { gbl/hostcode.i  t-doc.obj-type  t-doc.obj-code  v-host-code }

  run torgconf-read in this-procedure ( input "torg12", input v-host-code, input t-doc.obj-type, input t-doc.obj-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров печати формы."
      skip "Форма будет напечатана с параметрами по умолчанию."    skip return-value
      skip trim(error-status :get-message(1))    trim(error-status :get-message(2))    trim(error-status :get-message(3))
    view-as alert-box error.
  end.
  run torgconf-get-self-param in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров объекта документа."
      skip return-value    skip trim(error-status :get-message(1))
      trim(error-status :get-message(2))     trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  run torgconf-get-cli-param in this-procedure ( input t-doc.host-code, input t-doc.cli-type, input t-doc.cli-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров объекта клиента документа."
      skip return-value    skip trim(error-status :get-message(1))    trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  run torgconf-get-form-header in this-procedure (
          input no
        , input t-doc.doc-code
        , input "no"
        , input t-doc.doc-date
        , input t-doc.fact-date
        , input t-doc.doc-type
        , input t-doc.status_
        , input no
        , input no
    ).
  find first buf_clients
        where buf_clients.obj-type = {&cmp}
        and   buf_clients.obj-code = v-cntxt-host-code-obj
        no-lock
        .
    assign v-organization = buf_clients.obj-name .

    /*Сдал (должность)*/
     { str/tdat-val.i t-doc.doc-code {&trdcattr-t_pass-position} p-torgconf-t_pass-position v-attr-type no-error }
     if p-torgconf-t_pass-position > "" then assign v-pass = p-torgconf-t_pass-position .
    /*Сдал (расшифровка)*/
     { str/tdat-val.i t-doc.doc-code {&trdcattr-t_pass-fname} p-torgconf-t_pass-fname v-attr-type no-error }
     if p-torgconf-t_pass-fname > "" then assign v-pass = v-pass + ", " + p-torgconf-t_pass-fname .
    /*Кем, кому выдана доверенность*/
     { str/tdat-val.i t-doc.doc-code {&trdcattr-ndovwho} p-torgconf-ndovwho v-attr-type no-error }
    /*Дата доверенности*/
     { str/tdat-val.i t-doc.doc-code {&trdcattr-ddov} p-torgconf-date-warrant v-attr-type no-error }
    /*номер доверенности*/
     { str/tdat-val.i t-doc.doc-code {&trdcattr-ndov} p-torgconf-N-warrant v-attr-type no-error }
     if p-torgconf-ndovwho > ""
     or string(p-torgconf-date-warrant) ne "?"
     or p-torgconf-N-warrant > ""
     then assign v-dover = "Доверенность  " + p-torgconf-N-warrant
                            + " от " + string(p-torgconf-date-warrant) + "."
                              + " Выдана: " + p-torgconf-ndovwho
     .
    { str/tdat-val.i t-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
    if v-attr-value > "" then do :
          assign v-nnakl = v-attr-value .
        end .
        else do :
          assign v-nnakl = t-doc.doc-code .
        end.
    { str/tdat-val.i t-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
    if v-attr-value > "" then do :
            assign v-dnakl = string(date(v-attr-value), "99/99/9999") .
        end.
        else do :
            assign v-dnakl = v-torgconf-doc-date .
        end .
    run gbl/num-monr.p (input substring(v-torgconf-doc-date, 4, 2)
                      , output v-name-month
                      ).
    assign v-docdate = "от " + substring(v-torgconf-doc-date, 1, 2) + " " + v-name-month + " " + substring(v-torgconf-doc-date, 7, 4) + " года".

    { str/tdat-val.i t-doc.doc-code {&trdcattr-ndog} v-attr-value v-attr-type }
    if v-attr-value > "" then do :
        assign v-ndog = v-attr-value .
    end .
    else do :
      find first buf_contract no-lock
        where buf_Contract.host-code     = t-doc.host-code
          and buf_Contract.contract-code = t-doc.contract-code no-error.
          if available buf_contract then do :
             assign v-ndog = buf_contract.contract-prn-code .
          end .
    end .
    { str/tdat-val.i t-doc.doc-code {&trdcattr-ddog} v-attr-value v-attr-type }
    if v-attr-value > "" then do :
       assign v-ddog = string(date(v-attr-value), "99/99/9999") .
    end .
    else do :
      find first buf_contract no-lock
        where buf_Contract.host-code     = t-doc.host-code
          and buf_Contract.contract-code = t-doc.contract-code no-error .
          if available buf_contract then do :
             assign v-ddog = string(buf_contract.contract-date, "99/99/9999") .
          end .
    end .
    run rep/get-psn.p
    (input t-doc.wrkr
    ,output v-Wrkr_name
    ) .
  { gbl/working.i }
  { cmp/open-out.i stream out-stream " "  }
   run tg83xl-init in this-procedure .

  run for-each in this-procedure  .

  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-organization}
      , input v-organization
  ).
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-organization2}
      , input v-organization
  ).
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-object}
      , input v-torgconf-self-obj-name
  ).
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-cargoToValue}
      , input v-torgconf-cargo-from-value
  ).
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-supplier}
      , input v-torgconf-supplier + ' ' + v-torgconf-cli-phone
  ).

  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-docdate}
      , input v-docdate
  ).
  if v-Wrkr_name > "" and v-Wrkr_name ne "?" then do :
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-wrkrname}
      , input v-Wrkr_name
  ).
  end.
  if v-pass > "" and v-pass ne "?" then do :
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-pass}
      , input v-pass
  ).
  end.
  if v-dover > "" and v-dover ne "?" then do :
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-dover}
      , input v-dover
  ).
  end.
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-dnakl}
      , input v-dnakl
  ).
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-nnakl}
      , input v-nnakl
  ).
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-ddog}
      , input v-ddog
  ).
  run tg83xl-write-cell-data in this-procedure (
        input {&tg83xl-ndog}
      , input v-ndog
  ).
  run tg83xl-write-line-data in this-procedure (
        input ""
      , input "ИТОГО"
      , input ""
      , input all-doc-qnty
      , input ""
      , input all-doc-sum
      , input all-fact-qnty
      , input ""
      , input all-fact-sum
      , input all-qnty-i
      , input all-sum-i
      , input all-qnty-n
      , input all-sum-n
  ).
  run tg83xl-close in this-procedure .
  put stream out-stream unformatted
         {&new-line}
      + "Печатная форма предназначена только для вывода в Microsoft Excel."
      + {&new-line}
   .

  output stream out-stream close.

  { rep/q-print.i 4}
  { gbl/stopwork.i }

 end.
/*-------------------------------------------------*/
procedure for-each :
  do on error undo, return error return-value :
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_goods.gds-name
          :
            run print-line in this-procedure .
 end.
  end.
end procedure. /* for-each */
/*-------------------------------------------------*/
procedure print-line :
  do on error undo, return error return-value :
        if (buf_doc-line.fact-qnty - buf_doc-line.doc-qnty < 0 ) then
          assign qnty-n = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty   qnty-i = 0 .
        else
          assign qnty-i = buf_doc-line.fact-qnty - buf_doc-line.doc-qnty  qnty-n = 0 .
          assign
              v-count       = v-count + 1
              v-doc-price   = buf_doc-line.price-cli / buf_doc-line.cli-base-rate
              v-doc-sum     = buf_doc-line.price-cli * buf_doc-line.doc-qnty / buf_doc-line.cli-base-rate
              v-fact-price  = buf_doc-line.price-cli / buf_doc-line.cli-base-rate
              v-fact-sum    = buf_doc-line.price-cli * buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
              v-sum-i       = buf_doc-line.price-cli * qnty-i / buf_doc-line.cli-base-rate
              v-sum-n       = buf_doc-line.price-cli * qnty-n / buf_doc-line.cli-base-rate
            .
            run tg83xl-write-line-data in this-procedure (
                  input v-count
                , input buf_goods.gds-name
                , input buf_goods.unit-base
                , input buf_doc-line.doc-qnty
                , input v-doc-price
                , input v-doc-sum
                , input buf_doc-line.fact-qnty
                , input v-fact-price
                , input v-fact-sum
                , input qnty-i
                , input v-sum-i
                , input qnty-n
                , input v-sum-n
            ).
            assign
              all-doc-qnty  = all-doc-qnty  + buf_doc-line.doc-qnty
              all-doc-sum   = all-doc-sum   + v-doc-sum
              all-fact-qnty = all-fact-qnty + buf_doc-line.fact-qnty
              all-fact-sum  = all-fact-sum  + v-fact-sum
              all-qnty-i    = all-qnty-i    + qnty-i
              all-sum-i     = all-sum-i     + buf_doc-line.price-cli * qnty-i / buf_doc-line.cli-base-rate
              all-qnty-n    = all-qnty-n    + qnty-n
              all-sum-n     = all-sum-n     + buf_doc-line.price-cli * qnty-n / buf_doc-line.cli-base-rate
            .
  end.
end procedure. /* print-line */