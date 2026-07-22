block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rpp-1.p $
$Archive: rep/rpp-1.p $

Печать платежа  типа расход наличные

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03


*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_fin-doc for ub.fin-doc.
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input parameter p-from-forms as logical no-undo .
define input-output parameter p-format as integer no-undo .
/*1 - Landscape 0 -portrait*/

&SCOP f-l MonthNameRusGen

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rpp-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/rpp-1.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа расход безнал".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
define variable g#report-num  as integer no-undo .
define variable g#quest-print   as logical      no-undo.
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/frmlib.i }
{ gbl/paramls.i }
{ rep/rpp1xl.i  }

define variable Line as character no-undo .
define variable v-doc-date-f      as character no-undo .
define variable v-pay-date-f      as character no-undo .
define variable v-fact-date-f      as character no-undo .
define variable num-lines as integer no-undo .
define variable v-fill as character no-undo init "_".
define variable v-sum-doc as character no-undo extent 3.
define variable v-payer-name as character no-undo extent 5.
define variable v-payer-bank-name as character no-undo extent 3.
define variable v-receiver-name as character no-undo extent 5.
define variable v-receiver-bank-name as character no-undo extent 3.
define variable v-dops as character no-undo .
define variable v-naznach-pl as character no-undo extent 3.
define variable ii as integer no-undo .
define variable v-chernovik as character no-undo .

define variable v-receiver-bank-name-full     as character    no-undo.
define variable v-receiver-name-full          as character    no-undo.
define variable v-payer-bank-name-full        as character    no-undo.
define variable v-payer-name-full             as character    no-undo.
define variable v-naznach-pl-full             as character    no-undo.
define variable g#log as logical no-undo .

define buffer buf_currency for ub.currency.


do
on error undo, return error return-value
:
   run get-report-num  in parParentProc(output g#report-num).
  run get-quest-print in parParentProc(output g#quest-print).
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    run rpp1xl-init in this-procedure .

 if p-format <> 0
 and p-format <> ?
 and p-append
 then do:
    assign
    p-format = ?
    .
   return.
 end.
  assign
  v-chernovik = if buf_fin-doc.status_ = {&fin-new}
                then "Ч Е Р Н О В И К"
                else (fill( {&space-char}, 15))
  .

  assign
  v-doc-date-f = string(buf_fin-doc.doc-date, "99.99.9999":U)
  v-pay-date-f = if buf_fin-doc.pay-date <> ?
                 then string(buf_fin-doc.pay-date, "99.99.9999":U)
                 else "":U
  v-fact-date-f = if buf_fin-doc.fact-date <> ?
                  then string(buf_fin-doc.pay-date, "99.99.9999":U)
                  else "":U
  .
  assign
  v-dops = Sum-in-Words-Invalut(buf_fin-doc.sum-doc, buf_fin-doc.curr-code)
  v-sum-doc[1] =  Break-n-line(v-dops, "76,76,76", output num-lines)
  .
  do ii = 3 to 1 by -1 :
    assign
    v-sum-doc[ii] = If num-lines >= ii
                      then entry(ii, v-sum-doc[1], {&delim-par})
                      else "":U
    v-sum-doc[ii] =  v-sum-doc[ii] +  fill({&space-char}, 76 - length(v-sum-doc[ii]))
    .
  end.
  assign
  v-sum-doc[1] = caps(substring(v-sum-doc[1], 1, 1)) + substring(v-sum-doc[1], 2)
  .
  assign
    v-payer-name-full = buf_fin-doc.payer-name
                        + ( if buf_fin-doc.payer-dop1 = "":U
                            then "":U
                            else ( {&comma-char}
                                    + {&space-char} ) )
                        + buf_Fin-doc.payer-dop1
    v-payer-name[1]   = Break-n-line( v-payer-name-full, "53,53,53,53,53":U, output num-lines)
  .


  do ii = 5 to 1 by -1 :
    assign
    v-payer-name[ii] = If num-lines >= ii
                      then entry(ii, v-payer-name[1], {&delim-par})
                      else "":U
    v-payer-name[ii] =  v-payer-name[ii] +  fill({&space-char}, 53 - length(v-payer-name[ii]))
    .
  end.

  assign
    v-payer-bank-name-full = (buf_fin-doc.payer-bank-name + {&comma-char} + {&space-char} + buf_fin-doc.payer-bank-city)
                                + ( if buf_fin-doc.payer-dop2 = "":U
                                    then "":U
                                    else ( {&comma-char}
                                            + {&space-char}))
                                + buf_fin-doc.payer-dop2
    v-payer-bank-name[1]   = Break-n-line( v-payer-bank-name-full, "53,53,53":U, output num-lines)
  .
  do ii = 3 to 1  by -1:
    assign
    v-payer-bank-name[ii] = If num-lines >= ii
                      then entry(ii, v-payer-bank-name[1], {&delim-par})
                      else "":U
    v-payer-bank-name[ii] =  v-payer-bank-name[ii] +  fill({&space-char}, 53 - length(v-payer-bank-name[ii]))
    .
  end.
  assign
    v-receiver-name-full = buf_fin-doc.receiver-name
                            + ( if buf_fin-doc.receiver-dop1 = "":U
                                then "":U
                                else ( {&comma-char}
                                        + {&space-char} ) )
                            + buf_Fin-doc.receiver-dop1
    v-receiver-name[1]   = Break-n-line( v-receiver-name-full
                                         , "53,53,53,53,53":U
                                         , output num-lines )
  .
  do ii = 5 to 1  by -1:
    assign
    v-receiver-name[ii] = If num-lines >= ii
                      then entry(ii, v-receiver-name[1], {&delim-par})
                      else "":U
    v-receiver-name[ii] =  v-receiver-name[ii] +  fill({&space-char}, 53 - length(v-receiver-name[ii]))
    .
  end.
  assign
    v-receiver-bank-name-full = (buf_fin-doc.receiver-bank-name + {&comma-char} + {&space-char} + buf_fin-doc.receiver-bank-city)
                                + ( if buf_fin-doc.receiver-dop2 = "":U
                                    then "":U
                                    else ( {&comma-char}
                                           + {&space-char} ) )
                                + buf_Fin-doc.receiver-dop2
    v-receiver-bank-name[1]   = Break-n-line( v-receiver-bank-name-full, "53,53,53":U, output num-lines)
  .
  do ii = 3 to 1  by -1:
    assign
    v-receiver-bank-name[ii] = If num-lines >= ii
                      then entry(ii, v-receiver-bank-name[1], {&delim-par})
                      else "":U
    v-receiver-bank-name[ii] =  v-receiver-bank-name[ii] +  fill({&space-char}, 53 - length(v-receiver-bank-name[ii]))
    .
  end.
  assign
    v-naznach-pl-full = replace( buf_fin-doc.naznach-plat, "@", "":U )
    v-naznach-pl[1]   = Break-n-line( v-naznach-pl-full, "76,76,76":U, output num-lines)
  .

  do ii = 3 to 1  by -1:
    assign
    v-naznach-pl[ii] = If num-lines >= ii
                      then entry(ii, v-naznach-pl[1], {&delim-par})
                      else "":U
    v-naznach-pl[ii] =  v-naznach-pl[ii] +  fill({&space-char}, 76 - length(v-naznach-pl[ii]))
    .
  end.

  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input p-append /*p-append*/
                                              ).

    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_payDate}            , input v-pay-date-f                                                ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_factDate}           , input v-fact-date-f                                               ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_docDate}            , input v-doc-date-f                                                ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-vidPlat}              , input buf_fin-doc.vid-plat                                        ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-prnDocCode}           , input "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ N " + buf_fin-doc.prn-doc-code         ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-statPl}               , input buf_fin-doc.stat-pl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-sumDocPropis}         , input v-dops                                                      ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerInn}             , input "{&abbr_inn_allshift} " + buf_fin-doc.payer-inn                              ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerKpp}             , input "{&abbr_kpp_allshift} " + buf_fin-doc.payer-kpp                              ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-sumDoc}               , input trim( Sum-delim-with-defis(buf_fin-doc.sum-doc, 13) )       ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerName}            , input v-payer-name-full                                           ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerRSchet}          , input payer-r-schet                                               ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerBankName}        , input v-payer-bank-name-full                                      ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerBik}             , input buf_Fin-doc.payer-bik                                       ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerCSchet}          , input buf_fin-doc.payer-c-schet                                   ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-receiverBankName}     , input v-receiver-bank-name-full                                   ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-receiverBik}          , input buf_fin-doc.receiver-bik                                    ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-receiverCSchet}       , input buf_fin-doc.receiver-c-schet                                ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-receiverRSchet}       , input buf_fin-doc.receiver-r-schet                                ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-receiverInn}          , input "{&abbr_inn_allshift} " + buf_fin-doc.receiver-inn                           ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-receiverKpp}          , input "{&abbr_kpp_allshift} " + buf_fin-doc.receiver-kpp                           ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-receiverName}         , input v-receiver-name-full                                        ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-vidOpl}               , input buf_fin-doc.vid-opl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-srokPl}               , input buf_fin-doc.srok-pl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-naznPlat}             , input buf_fin-doc.nazn-pl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-ocherPl}              , input buf_fin-doc.ocher-pl                                        ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-kodPoluchat}          , input buf_fin-doc.f22                                             ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-rezPole}              , input buf_fin-doc.f23                                             ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_f104}               , input buf_fin-doc.f104                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_f105}               , input buf_fin-doc.f105                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_f106}               , input buf_fin-doc.f106                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_f107}               , input buf_fin-doc.f107                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_f108}               , input buf_fin-doc.f108                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_f109}               , input buf_fin-doc.f109                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-h_f110}               , input buf_fin-doc.f110                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-naznachPl}            , input v-naznach-pl-full                                           ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerSign1}           , input buf_fin-doc.payer-sign1                                     ).
    run rpp1xl-write-cell-data in this-procedure ( input {&rpp1xl-payerSign2}           , input buf_fin-doc.payer-sign2                                     ).

PUT  STREAM PrnLibStream unformatted
v-chernovik    "                                                              -----------"  skip
"                                                                             | 0401060 |"  skip
{&space-char} {&space-char} center-field(v-pay-date-f, 22, 22, v-fill)
/*"  ______________________"*/
                fill({&space-char}, 12) center-field(v-fact-date-f, 22, 22, v-fill) fill({&space-char}, 19)
                        /*" ______________________                          "*/
                                                                             "-----------"  skip
"   Поступ. в банк плат.              Списано со сч. плат.                               "  skip
"                                                                                        "  skip
"                                          " center-field(v-doc-date-f, 12, 12, {&space-char})
                                /*"           "*/ fill({&space-char}, 7)
                                   center-field(buf_fin-doc.vid-plat, 13, 13, {&space-char})
                                            /*"                "*/
                                                                      "      -----"  skip
"  ПЛАТЕЖНОЕ ПОРУЧЕНИЕ N " center-field(buf_fin-doc.prn-doc-code, 16,16, {&space-char})
                       /*"         " */
                                "  ------------       -------------      |"

                                                                                   center-field(buf_fin-doc.stat-pl, 3,3, {&space-char})
                                                                                 /*"   " */
                                                                                       "|"  skip
"                                              Дата            Вид платежа       -----"  skip
"                                                                                        "  skip
"  Сумма    |" v-sum-doc[1]
          /*"                                                                           " */
                                                                                            skip
"  прописью |" v-sum-doc[2]
          /*"                                                                           " */
                                                                                            skip
string(if v-sum-doc[3] <> "":U
then ("           |" + v-sum-doc[3] + {&new-line})
else "":U)
"  --------------------------------------------------------------------------------------"  skip
.
PUT  STREAM PrnLibStream unformatted
"  {&abbr_inn_allshift} " string(buf_fin-doc.payer-inn, "X(24)")
    /*"              "*/
                    "|{&abbr_kpp_allshift} " string(buf_fin-doc.payer-kpp, "X(20)")
                      /*"           "*/
                                   "|Сумма   |" {&space-char} trim(Sum-delim-with-defis(buf_fin-doc.sum-doc, 13))
                                           /*"                                           " */
                                                                                            skip
"  -----------------------------------------------------|        |                       "  skip
.
PUT  STREAM PrnLibStream unformatted
{&space-char} {&space-char} v-payer-name[1]
/*"                                                       "*/
                                                       "|        |                       "  skip
{&space-char} {&space-char} v-payer-name[2]
/*"                                                       "*/
                                                       "|        |                       "  skip
{&space-char} {&space-char} v-payer-name[3]
/*"                                                       "*/
                                                       "|--------+-----------------------"  skip
{&space-char} {&space-char} v-payer-name[4]
/*"                                                       "*/
                                                       "|Сч. N   |" {&space-char} buf_fin-doc.payer-r-schet
                                                                /*"                       " */
                                                                                            skip
{&space-char} {&space-char} v-payer-name[5]
/*"                                                       "*/
                                                       "|        |                       "  skip
"  Плательщик                                           |        |                       "  skip
"  -----------------------------------------------------+--------|                       "  skip
.
PUT  STREAM PrnLibStream unformatted
{&space-char} {&space-char} v-payer-bank-name[1]
/*"                                                       "*/
                                                       "|БИК     |" {&space-char} buf_Fin-doc.payer-bik
                                                                   /*"                       " */
                                                                                            skip
{&space-char} {&space-char} v-payer-bank-name[2]
/*"                                                      "*/
                                                       "|--------|                       "  skip
{&space-char} {&space-char} v-payer-bank-name[3]
/*"                                                      "*/
                                                       "|Сч. N   |" {&space-char} buf_fin-doc.payer-c-schet
                                                                   /*"                       "*/
                                                                                            skip
"  Банк плательщика                                     |        |                       "  skip
"  -----------------------------------------------------+--------+-----------------------"  skip
{&space-char} {&space-char} v-receiver-bank-name[1]
/*"                                                     "*/
                                                       "|БИК     |" {&space-char} buf_fin-doc.receiver-bik
                                                               /*"                       " */
                                                                                             skip
{&space-char} {&space-char} v-receiver-bank-name[2]
/*"                                                     "*/
                                                        "|--------|                       "  skip
{&space-char} {&space-char} v-receiver-bank-name[3]
/*"                                                      "*/

                                                        "|Сч. N   |" {&space-char} buf_fin-doc.receiver-c-schet
                                                                 /*"                       " */
                                                                                            skip
"  Банк получателя                                      |        |                       "  skip
"  -----------------------------------------------------+--------|                       "  skip
"  {&abbr_inn_allshift} " string(buf_fin-doc.receiver-inn, "X(24)")
    /*"                         "*/
                              "|{&abbr_kpp_allshift} " string(buf_fin-doc.receiver-kpp, "X(20)")
                                 /*"                    "*/
                                                       "|Сч. N   |" {&space-char} buf_fin-doc.receiver-r-schet
                                                                /*"                       "*/
                                                                                            skip
"  -----------------------------------------------------|        |                       "  skip
{&space-char} {&space-char} v-receiver-name[1]
/*"                                                     "*/
                                                       "|--------+-----------------------"  skip
{&space-char} {&space-char} v-receiver-name[2]
/*"                                                     "*/
                                                       "|Вид оп. |" CeNter-field(buf_FIN-DOC.VID-OPL, 6, 6, {&space-char})
                                                                 /*"      "*/
                                                                           "|Срок плат. |"
                                                                                          CeNter-field(buf_FIN-DOC.srok-pl, 4, 4, {&space-char})
                                                                                       /*"    "*/
                                                                                             skip
{&space-char} {&space-char} v-receiver-name[3]
/*"                                                     "*/
                                                        "|--------|      |-----------|    "  skip
{&space-char} {&space-char} v-receiver-name[4]
/*"                                                    "*/
                                                        "|Наз. пл.|" CeNter-field(buf_FIN-DOC.nazn-pl, 6, 6, {&space-char})
                                                                /*"      "*/
                                                                         "|Очер. плат.|"
                                                                                       CeNter-field(buf_FIN-DOC.ocher-pl, 6, 6, {&space-char})
                                                                                     /*"    "*/
                                                                                            skip
{&space-char} {&space-char} v-receiver-name[5]
/*"                                                    "*/
                                                       "|--------|      |-----------|    "  skip
"  Получатель                                           |Код     |"
                                                                    CeNter-field(buf_FIN-DOC.f22, 6, 6, {&space-char})
                                                                /*"      "*/
                                                                          "|Рез. поле  |"
                                                                                       buf_FIN-DOC.f23
                                                                                     /*"    "*/
                                                                                            skip
"  --------------------------------------------------------------------------------------"  skip
.
PUT  STREAM PrnLibStream unformatted
{&space-char} {&space-char} CeNter-field(buf_FIN-DOC.f104, 13, 13, {&space-char})
/*"           "*/
          "|"
             CeNter-field(buf_FIN-DOC.f105, 16, 16, {&space-char})
           /*"             "*/
                          "|"  CeNter-field(buf_FIN-DOC.f106, 8, 8, {&space-char})
                           /*"    "*/
                                "|" CeNter-field(buf_FIN-DOC.f107, 14, 14, {&space-char})
                                /*"           "*/
                                          "|" CeNter-field(buf_FIN-DOC.f108, 14, 14, {&space-char})
                                         /*"           "*/
                                                      "|" CeNter-field(buf_FIN-DOC.f109, 12, 12, {&space-char})
                                                     /*"          "*/
                                                                 "|" buf_FIN-DOC.f110
                                                                /*"  " */
                                                                                            skip
"  --------------------------------------------------------------------------------------"  skip
{&space-char} {&space-char} v-naznach-pl[1]
/*"                                                                                        "*/
                                                                                            skip
{&space-char} {&space-char} v-naznach-pl[2]
/*"                                                                                        "*/
                                                                                            skip
{&space-char} {&space-char} v-naznach-pl[3]
/*"                                                                                        "*/
                                                                                            skip
"  Назначение платежа                                                                    "  skip
"  --------------------------------------------------------------------------------------"  skip
"                               Подписи                                Отметки банка     "  skip
"                    "
                 CeNter-field(buf_FIN-DOC.payer-sign1, 50, 50, {&space-char})
                    /*"                                                "*/
                                                                        "                  "  skip
"                    _____________________________________________                         "  skip
"      М.П.          "
                 CeNter-field(buf_FIN-DOC.payer-sign2, 50, 50, {&space-char})
                  /*"                                               "*/
                                                                        "                  "  skip
"                    _____________________________________________                         "  skip
.




  if p-append and not p-is-last then Page stream PrnLibStream .
  output  STREAM PrnLibStream CLOSE.
  assign
  p-format = 0
  .
    run rpp1xl-close in this-procedure .
    if p-from-forms then do:
      { rep/q-print.i 0 }
    end.
    else do:
    if not p-append
    then do:
        os-delete
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
        os-rename
            value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
        run prn-lib-prn-file in this-procedure (
              input parParentProc
            , input 0
        ).
        os-delete
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
        os-delete
            value( v-rpp1xl-cell-file-name )
        .
    end.
    end.
end.