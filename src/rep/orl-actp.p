block-level on error undo, throw.
/*

$Revision: 099a383cf864, 290, rls $
$Author: PGridchina $
$Date: Tue Dec 01 19:11:24 2015 +0300 $
$Workfile: orl-actp.p $
$Archive: rep/orl-actp.p $

Акт приемки-передачи нефтепродуктов (весовой учёт)

Автор: Булгаков Андрей Николаевич
Дата создания: 05/24/05
Author: Andrew Bulgakoff
Creation date: 05/24/05

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-rec_id      as recid         no-undo.

&scop f-l       Word-Sum,Total-Word,RedLine,Roubles,Copecks
&scop comm-pars buf_doc-line.doc-code buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code
&scop def       def cli-qnty

define variable vss-revision    as character no-undo initial "$Revision: 099a383cf864, 290, rls $":U.
define variable vss-author      as character no-undo initial "$Author: PGridchina $":U.
define variable vss-date        as character no-undo initial "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: orl-actp.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/orl-actp.p $":U.
define variable vss-description as character no-undo initial "Акт приемки-передачи нефтепродуктов":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i          }
{ rep/p-fmt.i           }
{ rep/r-c-sale.i        }
{ str/trdcalib.i        }
{ str/lib-trn.i         }
{ str/invlnsum.i {&def} }
{ gbl/std-func.i {&f-l} }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ str/getctxtp.i def    }
{ str/getctxtp.i get    }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable g#quest-print as logical   no-undo.
define variable g#log         as logical   no-undo.
define variable base-part     as character no-undo.

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }

find first buf_rep_currency no-lock where
           buf_rep_currency.curr-code = base-code
           no-error .
  if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
        base-part = buf_rep_currency.part-abbr
      .
    end.
    else do:
      assign
        base-type = "б.в."
        base-part = ""
      .
    end.
run get-report-num  in parparentproc ( output g#report-num ).
run get-quest-print in parparentproc ( output g#quest-print ) .

&scop left-margin          14
&scop right-margin        130
&scop max-width           119
&scop tab-stop1            54
&scop max-width-from-tab1  76
&scop tab-stop2            70
&scop max-width-from-tab2  60
&scop tab-stop3            90
&scop tab-stop4           110

&glob P-S   15
&glob P-X  120 /* длина линии */
&glob P-X0 117 /* длина внутренней линии = длина линии - 2 */
&glob P-X1  58 /* длина внутренней линии от начала 2-й колонки до начала 6-й */
&glob P-X2  18 /* длина внутренней линии от начала 6-й колонки до конца */
&glob P-E    {&P-S} + 118
&glob P-C2-S {&P-S} + 25
&glob P-C3-S {&P-S} + 41
&glob P-C4-S {&P-S} + 52
&glob P-C5-S {&P-S} + 68
&glob P-C6-S {&P-S} + 84
&glob P-C7-S {&P-S} + 99

define variable v-operator          as   character                          no-undo.
define variable v-expl-name         as   character                          no-undo.
define variable v-store-man         as   character                          no-undo.
define variable v-main-boss         as   character                          no-undo.
define variable v-main-buh          as   character                          no-undo.
define variable temp-string         as   character                          no-undo.
define variable v-sum-string        as   character                          no-undo.
define variable temp-position       as   integer                            no-undo.
define variable single-line         as   character                          no-undo.
define variable v-is-petrol         as   logical                            no-undo initial no.
define variable v-is-pieces         as   logical                            no-undo initial no.
define variable v-have-petrol       as   logical                            no-undo initial no.
define variable v-have-rvs-before   as   logical                            no-undo initial no.
define variable v-have-rvs-after    as   logical                            no-undo initial no.
define variable v-ship-org          like ub.doc-line-attr.attr-value        no-undo.
define variable v-autoent-obj-code  like ub.doc-line-attr.attr-value        no-undo.
define variable v-autoent-obj-type  like ub.doc-line-attr.attr-value        no-undo.
define variable v-dids              like ub.doc-line-attr.attr-value        no-undo.
define variable v-nids              like ub.doc-line-attr.attr-value        no-undo.
define variable v-attr-type         as   character                          no-undo.
define variable v-car-num           like ub.doc-line-attr.attr-value        no-undo.
define variable v-car-vol           like ub.doc-line-attr.attr-value        no-undo.
define variable v-item-pour         like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-density      like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-temp         like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-vol          like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-water        like ub.doc-line-attr.attr-value        no-undo.
define variable v-tank-weight       like ub.doc-line-attr.attr-value        no-undo.
define variable v-time-pour         like ub.doc-line-attr.attr-value        no-undo.
define variable v-time-income       like ub.doc-line-attr.attr-value        no-undo.
define variable v-type-inp-vat      like ub.doc-line-attr.attr-value        no-undo.
define variable v-delta-mass        as   decimal                            no-undo.
define variable v-delta-volume      as   decimal                            no-undo.
define variable v-tank-vol-dec      like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-tank-temp-dec     like ub.rvs-line.state-temperature      no-undo.
define variable v-tank-density-dec  like ub.rvs-line.state-density          no-undo.
define variable v-tank-weight-dec   like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable v-tank-water-dec    like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-fact-qnty         as   decimal                            no-undo.
define variable v-fact-qnty-kg      as   decimal                            no-undo.
define variable v-price             as   decimal                            no-undo.
define variable v-price-kg          as   decimal                            no-undo.
define variable v-sum-price         as   decimal                            no-undo.
define variable v-VAT-pc            as   decimal                            no-undo.
define variable v-SLT-pc            as   decimal                            no-undo.
define variable v-host-code         as   integer                            no-undo.
define variable v-fio               like ub.doc-line-attr.attr-value        no-undo.
define variable before_qnty         like ub.rvs-line.state-measure-qnty     no-undo.
define variable before_temperature  like ub.rvs-line.state-temperature      no-undo.
define variable before_density      like ub.rvs-line.state-density          no-undo.
define variable before_cli-qnty     like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable after_qnty          like ub.rvs-line.state-measure-qnty     no-undo.
define variable after_temperature   like ub.rvs-line.state-temperature      no-undo.
define variable after_density       like ub.rvs-line.state-density          no-undo.
define variable after_cli-qnty      like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable doc-line_1st-run    as   logical                            no-undo .

define buffer buf_trn-doc         for ub.trn-doc.
define buffer buf_doc-line        for ub.doc-line.
define buffer bf_inv-line         for ub.inv-line.
define buffer buf_goods           for ub.goods.
define buffer buf_clients         for ub.clients.
define buffer buf_clients_ship    for ub.clients.
define buffer buf_doc-line-attr   for ub.doc-line-attr.
define buffer buf_doc-attr        for ub.doc-attr.
define buffer buf_rvs-doc_before  for ub.rvs-doc.
define buffer buf_rvs-doc_after   for ub.rvs-doc.
define buffer buf_rvs-line_before for ub.rvs-line.
define buffer buf_rvs-line_after  for ub.rvs-line.
define buffer buf_host_clients    for ub.clients.
define buffer buf_obj_clients     for ub.clients.
define buffer buf_shop            for ub.shop.
define buffer buf_store           for ub.store.
define buffer buf_firm            for ub.firm.
define buffer buf_sysconf         for ub.sysconf.

define stream out-stream.

do on error undo, return error :
  if session :set-wait-state( "COMPILER":U ) then do: end.


  assign single-line = fill( "-", {&max-width} ).

  find first buf_trn-doc      no-lock where recid( buf_trn-doc ) = p-rec_id.
  find first buf_host_clients no-lock where
             buf_host_clients.obj-type = {&cmp} and
             buf_host_clients.obj-code = buf_trn-doc.host-code.
  find first buf_firm         no-lock where buf_firm.firm-code = buf_host_clients.obj-code.
  { gbl/hostcode.i buf_trn-doc.obj-type
               buf_trn-doc.obj-code
               v-host-code          }
  find first buf_sysconf      no-lock where buf_sysconf.host-code = v-host-code.
  assign v-main-boss = buf_firm.director
         v-main-buh  = buf_sysconf.snr-accnt.
  find first buf_obj_clients  no-lock where
             buf_obj_clients.obj-type = buf_trn-doc.obj-type and
             buf_obj_clients.obj-code = buf_trn-doc.obj-code no-error.

  case buf_obj_clients.obj-type :
    when {&shop}  then do:
      find first buf_shop     no-lock where buf_shop.obj-code  = buf_obj_clients.obj-code.
      assign v-expl-name = buf_shop.director
             v-store-man = buf_shop.store-man.
    end.
    when {&stock} then do:
      find first buf_store    no-lock where buf_store.obj-code = buf_obj_clients.obj-code.
        assign v-expl-name = buf_store.store-boss
               v-store-man = buf_store.store-man.
    end.
  end case. /* buf_obj_clients.obj-type */

  find first buf_clients      no-lock where
             buf_clients.obj-type = {&prs}           and
             buf_clients.obj-code = buf_trn-doc.wrkr no-error. /* Оператор */
  assign v-operator = ( if available buf_clients then buf_clients.obj-name else "":U ).
  find first buf_clients      no-lock where
             buf_clients.obj-type = buf_trn-doc.obj-type and
             buf_clients.obj-code = buf_trn-doc.obj-code.      /* Поставщик */
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dids} v-dids v-attr-type }
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-nids v-attr-type }

  { cmp/open-out.i stream out-stream " " {&CS_PS} }

  for each buf_doc-line no-lock where
           buf_doc-line.doc-code = buf_trn-doc.doc-code :
    find first bf_inv-line no-lock where
               bf_inv-line.doc-code  = buf_doc-line.doc-code  and
               bf_inv-line.artic     = buf_doc-line.artic     and
               bf_inv-line.prod-type = buf_doc-line.prod-type and
               bf_inv-line.prod-code = buf_doc-line.prod-code no-error.
    { str/is-petrl.i buf_doc-line.artic
                     buf_doc-line.prod-type
                     buf_doc-line.prod-code
                     v-is-petrol
                     v-is-pieces            no-error }
    if v-is-petrol <> yes then do: next. end.
    assign v-have-petrol = yes.

    { rep/act-ptrl.i init-attr }
    find first buf_goods no-lock where
               buf_goods.artic     = buf_doc-line.artic     and
               buf_goods.prod-type = buf_doc-line.prod-type and
               buf_goods.prod-code = buf_doc-line.prod-code.
    for each buf_doc-line-attr no-lock where
             buf_doc-line-attr.doc-code = buf_trn-doc.doc-code and
             buf_doc-line-attr.gds-code = buf_goods.gds-code   :
      case buf_doc-line-attr.attr-code :
        { rep/act-ptrl.i when car-vol          }
        { rep/act-ptrl.i when tank-density     }
        { rep/act-ptrl.i when tank-temp        }
        { rep/act-ptrl.i when tank-vol         }
        { rep/act-ptrl.i when tank-water       }
        { rep/act-ptrl.i when tank-weight      }
        { rep/act-ptrl.i when time-pour        }
        { rep/act-ptrl.i when type-inp-vat     }
      end case. /* buf_doc-line-attr.attr-code */
    end. /* for each buf_doc-line-attr */

    for each buf_doc-attr no-lock where
             buf_doc-attr.doc-code = buf_trn-doc.doc-code:
      case buf_doc-attr.attr-code :
        { rep/act-ptrl.i when-doc-attr trdcattr-autoent }
        { rep/act-ptrl.i when-doc-attr trdcattr-car-num }
        { rep/act-ptrl.i when-doc-attr trdcattr-time-income }
        { rep/act-ptrl.i when-doc-attr trdcattr-ptb-item-pour }
      end case. /* buf_doc-attr.attr-code */
    end. /* for each buf_doc-attr */

    { rep/act-ptrl.i dec tank-vol     }
    { rep/act-ptrl.i dec tank-temp    }
    { rep/act-ptrl.i dec tank-density }
    { rep/act-ptrl.i dec tank-weight  }
    { rep/act-ptrl.i dec tank-water   }

    find first buf_clients_ship no-lock where
               buf_clients_ship.obj-type =          v-autoent-obj-type   and
               buf_clients_ship.obj-code = integer( v-autoent-obj-code ) no-error.
    assign v-ship-org = ( if available buf_clients then buf_clients.obj-name else "":U ).
    run r-c-sale in this-procedure (  input buf_doc-line.doc-code
                                   ,  input buf_doc-line.artic
                                   ,  input buf_doc-line.prod-type
                                   ,  input buf_doc-line.prod-code
                                   , output v-fact-qnty
                                   , output v-VAT-pc
                                   , output v-SLT-pc
                                   , output v-sum-price            ).
    assign v-price        = ( if v-fact-qnty = 0 then 0 else v-sum-price / v-fact-qnty    )
           v-fact-qnty-kg = { str/invlnsum.i exe cli-qnty {&comm-pars} }
           v-price-kg     = ( if v-fact-qnty = 0 then 0 else v-sum-price / v-fact-qnty-kg ).

    put stream out-stream unformatted
        skip( 1 ) "А К Т"                     at center-field( {&left-margin}, {&right-margin}, 5 ) format "x(5)":U skip
        "приемки-передачи нефтепродуктов " + caps( trim( buf_host_clients.obj-name ) )
                                              at center-field( {&left-margin}, {&right-margin}, 32 + length( trim( buf_host_clients.obj-name ) ) )
        skip "предпринимателю " + v-expl-name at center-field( {&left-margin}, {&right-margin}, 16 + length( v-expl-name ) ).

    if buf_trn-doc.fact-date <> ? then do:
      assign temp-string = '" '  + string( day(   buf_trn-doc.fact-date ) )
                         + ' " ' + entry(  month( buf_trn-doc.fact-date ), {&month-list-for-date} )
                         + " "   + string( year(  buf_trn-doc.fact-date ), "9999" ) + " г.".
      assign temp-position = center-field( {&left-margin}, {&right-margin}, length( temp-string ) )
             temp-string   = fill( " ":U, temp-position ) + temp-string.
    end.
    else do:
      assign temp-string = "":U.
    end.

    put stream out-stream
        skip
        temp-string                             format "x({&right-margin})":U
        skip( 2 ) space( {&left-margin} )
        "ТТН N " string( buf_trn-doc.doc-code ) + " от " + string( buf_trn-doc.doc-date )
                                                format "x({&max-width-from-tab1})":U at {&tab-stop1}
        skip      space( {&left-margin} )
        "Основание: накладная поставщика" string( "N " + v-nids + " от " + v-dids )
                                                format "x({&max-width-from-tab1})":U at {&tab-stop1}
        skip      space( {&left-margin} )
        "Гос.N автоцистерны "         v-car-num format "x({&max-width-from-tab1})":U at {&tab-stop1}
        skip      space( {&left-margin} )
        "Объем по паспорту в литрах " v-car-vol format "x({&max-width-from-tab1})":U at {&tab-stop1}
        skip      space( {&left-margin} )
        "Поставщик " buf_trn-doc.cli-name       format "x({&max-width-from-tab1})":U at {&tab-stop1}
        skip      space( {&left-margin} )
        ( if not ( buf_trn-doc.PS begins "@" ) then buf_trn-doc.PS else "":U )
                                                format "x({&max-width-from-tab1})":U
        skip      space( {&left-margin} )
        "Нефтепродукт " buf_goods.gds-name      format "x({&max-width-from-tab1})":U at {&tab-stop1}.

    put stream out-stream
      skip( 2 ) single-line       format "x({&max-width})":U at {&P-S}
      skip      ":"               format "x(1)":U            at {&P-S}
                ":"               format "x(1)":U            at {&P-C2-S}
                "Нефтепродукт"    format "x(12)":U           at center-field( {&P-C2-S}, {&P-C6-S}, 12 )
                ":"               format "x(1)":U            at {&P-C6-S}
                ":"               format "x(1)":U            at {&P-C7-S}
                ":"               format "x(1)":U            at {&P-E}
      skip      ":"               format "x(1)":U            at {&P-S}
                ":"               format "x(1)":U            at {&P-C2-S}
                single-line       format "x({&P-X1})":U
                ":"               format "x(1)":U            at {&P-C6-S}
                "Цена"                                       at center-field( {&P-C6-S}, {&P-C7-S}, 4 )
                ":"               format "x(1)":U            at {&P-C7-S}
                "Сумма"                                      at center-field( {&P-C7-S}, {&P-E}, 5 )
                ":"               format "x(1)":U            at {&P-E}
      skip      ":"               format "x(1)":U            at {&P-S}
                ":"               format "x(1)":U            at {&P-C2-S}
                "Объем,"          format "x(6)":U            at center-field( {&P-C2-S}, {&P-C3-S},  6 )
                ":"               format "x(1)":U            at {&P-C3-S}
                "t,"              format "x(2)":U            at center-field( {&P-C3-S}, {&P-C4-S},  2 )
                ":"               format "x(1)":U            at {&P-C4-S}
                "Плотность,"      format "x(10)":U           at center-field( {&P-C4-S}, {&P-C5-S}, 10 )
                ":"               format "x(1)":U            at {&P-C5-S}
                "Масса,"          format "x(6)":U            at center-field( {&P-C5-S}, {&P-C6-S},  6 )
                ":"               format "x(1)":U            at {&P-C6-S}
                "по объекту"      format "x(10)":U           at center-field( {&P-C6-S}, {&P-C7-S}, 10 )
                ":"               format "x(1)":U            at {&P-C7-S}
                "по объекту"      format "x(10)":U           at center-field( {&P-C7-S}, {&P-E}, 10 )
                ":"               format "x(1)":U            at {&P-E}
      skip      ":"               format "x(1)":U            at {&P-S}
                ":"               format "x(1)":U            at {&P-C2-S}
                "л"               format "x(1)":U            at center-field( {&P-C2-S}, {&P-C3-S}, 1 )
                ":"               format "x(1)":U            at {&P-C3-S}
                "град.C"          format "x(6)":U            at center-field( {&P-C3-S}, {&P-C4-S}, 6 )
                ":"               format "x(1)":U            at {&P-C4-S}
                "г/см.куб"        format "x(8)":U            at center-field( {&P-C4-S}, {&P-C5-S}, 8 )
                ":"               format "x(1)":U            at {&P-C5-S}
                "кг"              format "x(2)":U            at center-field( {&P-C5-S}, {&P-C6-S}, 2 )
                ":"               format "x(1)":U            at {&P-C6-S}
                "за л"            format "x(4)":U            at center-field( {&P-C6-S}, {&P-C7-S}, 4 )
                ":"               format "x(1)":U            at {&P-C7-S}
                "({&abbr_rub})":U format "x(5)":U            at center-field( {&P-C7-S}, {&P-E}, 5 )
                ":"               format "x(1)":U            at {&P-E}
      skip      ":"               format "x(1)":U            at {&P-S}
                single-line       format "x({&P-X0})":U
                ":"               format "x(1)":U.

    put stream out-stream
      skip ":"                                       format "x(1)":U             at {&P-S}
           "По ТТН"                                  format "x(6)":U             at {&P-S} + 2
           ":"                                       format "x(1)":U             at {&P-C2-S}
        buf_doc-line.doc-qnty                        format "zz,zz9.999":U       at right-field( {&P-C3-S} - 1, 10 )
           ":"                                       format "x(1)":U             at {&P-C3-S}
        buf_doc-line.temperature                     format "->>9.99":U          at right-field( {&P-C4-S} - 1,  7 )
           ":"                                       format "x(1)":U             at {&P-C4-S}
        buf_doc-line.doc-density                     format "9.9999999999":U     at right-field( {&P-C5-S} - 1, 12 )
           ":"                                       format "x(1)":U             at {&P-C5-S}
        buf_doc-line.cli-qnty                        format "zz,zzz,zz9.999":U   at right-field( {&P-C6-S}, 14 )
           ":"                                       format "x(1)":U             at {&P-C6-S}
           v-price                                   format "z,zzz,zz9.99":U     at right-field( {&P-C7-S}, 12 )
           ":"                                       format "x(1)":U             at {&P-C7-S}
           v-sum-price                               format "z,zzz,zzz,zz9.99":U at right-field( {&P-E}, 16 )
           ":"                                       format "x(1)":U             at {&P-E}
      skip ":"                                       format "x(1)":U             at {&P-S}
           single-line                               format "x({&P-X0})":U
           ":"                                       format "x(1)":U
      skip ":"                                       format "x(1)":U             at {&P-S}
           single-line                               format "x({&P-X0})":U
           ":"                                       format "x(1)":U
      skip ":"                                       format "x(1)":U             at {&P-S}
           "По замеру в"                             format "x(11)":U            at {&P-S} + 2
           ":"                                       format "x(1)":U             at {&P-C2-S}
           ":"                                       format "x(1)":U             at {&P-C3-S}
           ":"                                       format "x(1)":U             at {&P-C4-S}
           ":"                                       format "x(1)":U             at {&P-C5-S}
           ":"                                       format "x(1)":U             at {&P-C6-S}
           ":"                                       format "x(1)":U             at {&P-C7-S}
           ":"                                       format "x(1)":U             at {&P-E}
      skip ":"                                       format "x(1)":U             at {&P-S}
           "автоцистерне"                            format "x(12)":U            at {&P-S} + 2
           ":"                                       format "x(1)":U             at {&P-C2-S}.
    if v-tank-vol-dec     <> ? then do:
      put stream out-stream v-tank-vol-dec     format "zz,zz9.999":U     at right-field( {&P-C3-S} - 1, 10 ).
    end.
    put stream out-stream ":" format "x(1)":U at {&P-C3-S}.
    if v-tank-temp-dec    <> ? then do:
      put stream out-stream v-tank-temp-dec    format "->>9.99":U        at right-field( {&P-C4-S} - 1,  7 ).
    end.
    put stream out-stream ":" format "x(1)":U at {&P-C4-S}.
    if v-tank-density-dec <> ? then do:
      put stream out-stream v-tank-density-dec format "9.9999999999":U   at right-field( {&P-C5-S} - 1, 12 ).
    end.
    put stream out-stream ":" format "x(1)":U at {&P-C5-S}.
    if v-tank-weight-dec  <> ? then do:
      put stream out-stream v-tank-weight-dec  format "zz,zzz,zz9.999":U at right-field( {&P-C6-S}, 14 ).
    end.
    put stream out-stream
           ":"                      format "x(1)":U       at {&P-C6-S}
           ":"                      format "x(1)":U       at {&P-C7-S}
           ":"                      format "x(1)":U       at {&P-E}
      skip ":"                      format "x(1)":U       at {&P-S}
           single-line              format "x({&P-X0})":U
           ":"                      format "x(1)":U.
    { rep/act-ptrl.i rvs-line     before }
    put stream out-stream
      skip ":"                      format "x(1)":U       at {&P-S}
           single-line              format "x({&P-X0})":U
           ":"                      format "x(1)":U
      skip ":"                      format "x(1)":U       at {&P-S}
           "По замеру в резервуаре" format "x(22)":U      at {&P-S} + 2
           ":"                      format "x(1)":U       at {&P-C2-S}
           ":"                      format "x(1)":U       at {&P-C3-S}
           ":"                      format "x(1)":U       at {&P-C4-S}
           ":"                      format "x(1)":U       at {&P-C5-S}
           ":"                      format "x(1)":U       at {&P-C6-S}
           ":"                      format "x(1)":U       at {&P-C7-S}
           ":"                      format "x(1)":U       at {&P-E}
      skip ":"                      format "x(1)":U       at {&P-S}
           "ДО слива"               format "x(8)":U       at {&P-S} + 2
           ":"                      format "x(1)":U       at {&P-C2-S}.
    { rep/act-ptrl.i print-field before measure-qnty     "zz,zz9.999"     "{&P-C3-S}" 1 10 }
    { rep/act-ptrl.i print-field before temperature      "->>9.99"        "{&P-C4-S}" 1  7 }
    { rep/act-ptrl.i print-field before density          "9.9999999999"   "{&P-C5-S}" 1 12 }
    { rep/act-ptrl.i print-field before measure-cli-qnty "zz,zzz,zz9.999" "{&P-C6-S}" 0 14 }
    put stream out-stream
           ":"                   format "x(1)":U       at {&P-C7-S}
           ":"                   format "x(1)":U       at {&P-E}
      skip ":"                   format "x(1)":U       at {&P-S}
           single-line           format "x({&P-X0})":U
           ":"                   format "x(1)":U.
    { rep/act-ptrl.i rvs-line-end before }
    { rep/act-ptrl.i rvs-line     after  }
    put stream out-stream
      skip ":"                   format "x(1)":U       at {&P-S}
        "По замеру в резервуаре" format "x(22)":U      at {&P-S} + 2
           ":"                   format "x(1)":U       at {&P-C2-S}
           ":"                   format "x(1)":U       at {&P-C3-S}
           ":"                   format "x(1)":U       at {&P-C4-S}
           ":"                   format "x(1)":U       at {&P-C5-S}
           ":"                   format "x(1)":U       at {&P-C6-S}
           ":"                   format "x(1)":U       at {&P-C7-S}
           ":"                   format "x(1)":U       at {&P-E}
      skip ":"                   format "x(1)":U       at {&P-S}
           "ПОСЛЕ слива"         format "x(11)":U      at {&P-S} + 2
           ":"                   format "x(1)":U       at {&P-C2-S}.
    { rep/act-ptrl.i print-field after measure-qnty     "zz,zz9.999"     "{&P-C3-S}" 1 10 }
    { rep/act-ptrl.i print-field after temperature      "->>9.99"        "{&P-C4-S}" 1  7 }
    { rep/act-ptrl.i print-field after density          "9.9999999999"   "{&P-C5-S}" 1 12 }
    { rep/act-ptrl.i print-field after measure-cli-qnty "zz,zzz,zz9.999" "{&P-C6-S}" 0 14 }
    put stream out-stream
           ":"         format "x(1)":U            at {&P-C7-S}
           ":"         format "x(1)":U            at {&P-E}
      skip single-line format "x({&max-width})":U at {&P-S}.
    { rep/act-ptrl.i rvs-line-end after  }

    put stream out-stream
      skip( 2 ) space( {&left-margin} ) "Объем принятого нефтепродукта "
      buf_doc-line.fact-qnty format "zzz,zzz,zz9.999":U at right-field( {&tab-stop3}, 15 ) " литров"
      skip      space( {&left-margin} ) "Масса принятого нефтепродукта "
      ( if available bf_inv-line then bf_inv-line.wast-cli-qnty else ? )
                             format "zzz,zzz,zz9.999":U at right-field( {&tab-stop3}, 15 ) " кг".

    assign v-sum-string = Total-Word( v-sum-price, Roubles( v-sum-price ), Copecks( v-sum-price ) )
           temp-string  = " {&abbr_rub}.".

    put stream out-stream
      skip( 1 ) space( {&left-margin} ) "ИТОГО по акту передано на сумму     " +
      caps( ( if trim( v-sum-string ) begins trim( temp-string ) then string( "0 " + v-sum-string ) else v-sum-string ) )
                                                        format "x(126)":U.
    put stream out-stream
      skip( 1 ) space( {&left-margin} ) "От владельца : "
                                        "От агента : "    at 80
      v-store-man                     format "x(20)":U
      skip( 1 ) space( {&left-margin} ) "Руководитель предприятия:                                             / "
      string( v-main-boss  + " /" )   format "x(40)":U
      skip( 1 ) space( {&left-margin} ) "Главный бухгалтер:                                                    / "
      string( v-main-buh  + " /" )    format "x(40)":U.
    page stream out-stream.
  end. /* for each buf_doc-line */

  output stream out-stream close.

  if v-have-petrol = yes then do: /* А если нет ни одного топливного товара - молча вывалиться */
    { rep/q-print.i 4 }
  end.
end. /* do on error */