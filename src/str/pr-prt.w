&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общий экран изменения цен

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06


*/

define temp-table tt-chs-parts no-undo like ub.parts.
define input  parameter parmode               as   character              no-undo. /*режим "goods", "part", "parts" */
define input  parameter pargds-code           like ub.goods.gds-code      no-undo. /*товар*/
define input  parameter parcli-type           like ub.trn-doc.cli-type    no-undo. /*контрагент*/
define input  parameter parcli-code           like ub.trn-doc.cli-code    no-undo.
define input  parameter parobj-type           like ub.clients.obj-type    no-undo. /* партия */
define input  parameter parobj-code           like ub.clients.obj-code    no-undo.
define input  parameter parin-code            like ub.parts.in-code       no-undo.
define input  parameter parout-code           like ub.parts.out-code      no-undo.
define input  parameter parpart-code          like ub.parts.part-code     no-undo.
define input  parameter parbase-rate          like ub.trn-doc.base-rate   no-undo.
define input  parameter parbase-scale         like ub.trn-doc.base-scale  no-undo.
define input  parameter parexch-code          like ub.trn-doc.exch-code   no-undo.
define input  parameter parexch-rate          like ub.trn-doc.exch-rate   no-undo.
define input  parameter parexch-scale         like ub.trn-doc.exch-scale  no-undo.
define input  parameter paris-slt             as   logical                no-undo. /*предпологался ли налог с продаж*/
define input  parameter paris-road-tax        as   logical                no-undo. /*допустима ли стеклопосуда*/
define input  parameter parcontract-code      like ub.trn-doc.contract-code no-undo.
define input  parameter table for tt-chs-parts.
define output parameter parprice-base         like ub.parts.price-base    no-undo. /*компоненты цены, суммы и процентные ставки*/
define output parameter parsum-base           as   decimal                no-undo.
define output parameter parprice-rubl         like ub.parts.price-rubl    no-undo.
define output parameter parsum-rubl           as   decimal                no-undo.
define input-output parameter parcli-base-rate      like ub.parts.cli-base-rate no-undo.
define input-output parameter parvat-type           like ub.parts.vat-type      no-undo.
define input-output parameter parslt-type           like ub.parts.slt-type      no-undo.
define output parameter parprice-cli          like ub.parts.price-rubl    no-undo.
define output parameter parsum-cli            as   decimal                no-undo.
define output parameter parvat-pc             like ub.parts.vat-pc        no-undo.
define output parameter parvat-base           as   decimal                no-undo.
define output parameter parsum-vat-base       as   decimal                no-undo.
define output parameter parvat-rubl           as   decimal                no-undo.
define output parameter parsum-vat-rubl       as   decimal                no-undo.
define output parameter parvat-cli            as   decimal                no-undo.
define output parameter parsum-vat-cli        as   decimal                no-undo.
define output parameter parslt-pc             like ub.parts.vat-pc        no-undo.
define output parameter parslt-base           as   decimal                no-undo.
define output parameter parsum-slt-base       as   decimal                no-undo.
define output parameter parslt-rubl           as   decimal                no-undo.
define output parameter parsum-slt-rubl       as   decimal                no-undo.
define output parameter parslt-cli            as   decimal                no-undo.
define output parameter parsum-slt-cli        as   decimal                no-undo.
define output parameter parroad-tax-base      like ub.parts.road-tax-base no-undo.
define output parameter parsum-road-tax-base  as   decimal                no-undo.
define output parameter parroad-tax-rubl      like ub.parts.road-tax-rubl no-undo.
define output parameter parsum-road-tax-rubl  as   decimal                no-undo.
define output parameter parroad-tax-cli       as   decimal                no-undo.
define output parameter parsum-road-tax-cli   as   decimal                no-undo.
define output parameter partransport-base     like ub.parts.road-tax-base no-undo.
define output parameter parsum-transport-base as   decimal                no-undo.
define output parameter partransport-rubl     like ub.parts.road-tax-rubl no-undo.
define output parameter parsum-transport-rubl as   decimal                no-undo.
define output parameter parother-base         like ub.parts.road-tax-base no-undo.
define output parameter parsum-other-base     as   decimal                no-undo.
define output parameter parother-rubl         like ub.parts.road-tax-rubl no-undo.
define output parameter parsum-other-rubl     as   decimal                no-undo.
define output parameter parpurch-code         like ub.parts.purch-code    no-undo.
define output parameter paris-ok as logical initial no no-undo.
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Общий экран изменения цен".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/showinf.i   }
{ cmp/library.i   }
{ str/clcprtsl.i  }
{ trg/partslib.i  }
{ str/lib-trn.i   }
{ gbl/tax-name.i  }
define buffer bf_goods           for ub.goods.
define buffer bf-cur-obj_clients for ub.clients.
define buffer bf-supp_clients    for ub.clients.
define buffer bf_gds-obj         for ub.gds-obj.
define buffer bf_parts-attr      for ub.parts-attr.
define buffer bf_parts           for ub.parts.
define buffer bf_tt-allsum-line  for tt-allsum-line.
define buffer bf_clients         for ub.clients.
define buffer bf-host_clients    for ub.clients.
define buffer bf-sysconf         for ub.sysconf.

define variable varrate-correct      as logical no-undo.
define variable varrate-exch-correct as logical no-undo.

DEFINE BUFFER tt-chs-parts-another FOR tt-chs-parts.

&scoped-define rate-correct run rate-correct (output varrate-correct) no-error. ~
                            if error-status:error then do: ~
                              message "Ошибка при вызове процедуры rate-correct." skip ~
                                      return-value ~
                                      error-status:get-message(1) ~
                                      error-status:get-message(2) ~
                              view-as alert-box error. ~
                              return no-apply. ~
                            end. ~
                            if varrate-correct = no then do: ~
                              message "Курс в партии не согласован с {&abbr_rublevoy} и валютной ценой." skip ~
                                      "{&abbr_rublevaya_firstshift} цена: "         varprice-rubl skip ~
                                      "Цена в базовой валюте: " varprice-base skip ~
                                      "Курс базовой валюты: "   varbase-rate  skip ~
                                      "Шкала базовой валюты: "  varbase-scale      ~
                              view-as alert-box information. ~
                              if b-calc-rate:sensitive then do: ~
                                apply "entry" to b-calc-rate.~
                              end. ~
                              else do: ~
                                if b-calc-exch-rate:sensitive then do: ~
                                  apply "entry" to b-calc-exch-rate. ~
                                end. ~
                                else do: ~
                                  apply "entry" to varprice-cli.~
                                end. ~
                              end. ~
                              return no-apply. ~
                            end.
&scoped-define rate-exch-correct run rate-exch-correct (output varrate-exch-correct) no-error. ~
                                 if error-status:error then do: ~
                                   message "Ошибка при вызове процедуры rate-exch-correct." skip ~
                                           return-value ~
                                           error-status:get-message(1) ~
                                           error-status:get-message(2) ~
                                   view-as alert-box error. ~
                                   return no-apply. ~
                                 end. ~
                                 if varrate-exch-correct = no then do: ~
                                   message "Курс в партии не согласован с {&abbr_rublevoy} и ценой в валюте поставщика (договора)." skip ~
                                           "{&abbr_rublevaya_firstshift} цена: "            varprice-rubl    skip ~
                                           "Цена в валюте поставщика: " varprice-cli     skip ~
                                           "Единица поставщика: "       varcli-base-rate skip ~
                                           "Курс валюты поставщика: "   varexch-rate     skip ~
                                           "Шкала валюты поставщика: "  varexch-scale ~
                                   view-as alert-box information. ~
                                   if b-calc-exch-rate:sensitive then do: ~
                                     apply "entry" to b-calc-exch-rate.~
                                   end. ~
                                   else do: ~
                                     apply "entry" to varprice-cli. ~
                                   end. ~
                                   return no-apply. ~
                                 end.

{ str/in-vatp.i def }
define variable varroad-tax-base  like ub.doc-line.road-tax  no-undo.
define variable varroad-tax-rubl  like ub.doc-line.road-tax  no-undo.
define variable varroad-tax-cli   like ub.doc-line.road-tax  no-undo.
define variable vartransport-base like ub.doc-line.road-tax  no-undo.
define variable vartransport-rubl like ub.doc-line.road-tax  no-undo.
define variable vartransport-cli  like ub.doc-line.road-tax  no-undo.
define variable varother-base     like ub.doc-line.road-tax  no-undo.
define variable varother-rubl     like ub.doc-line.road-tax  no-undo.
define variable varother-cli      like ub.doc-line.road-tax  no-undo.
define variable varbaseeqrubl     as   logical               no-undo.
define variable varexcheqrubl     as   logical               no-undo.
define variable varexcheqbase     as   logical               no-undo.
define variable varhost-code      like ub.clients.obj-code   no-undo.
define variable varbase-code      like ub.currency.curr-code no-undo.
define variable varexch-code      like ub.currency.curr-code no-undo.
define variable vartemp-rate      like ub.trn-doc.exch-rate  no-undo.
define variable vartemp-scale     like ub.trn-doc.exch-scale no-undo.
define variable varno-change      as   character initial "не изменять":u no-undo.
define variable varout-code       like ub.trn-doc.doc-code   no-undo.
define variable vardoc-type       like ub.parts.doc-type     no-undo.
assign
  varout-code = parout-code
  vardoc-type = {&act-overvalue}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save RECT-goods RECT-transport RECT-object ~
RECT-other RECT-road-tax RECT-price RECT-slt RECT-vat RECT-1 b-cancel ~
b-help varvat-pc varslt-pc b-cur-rate varbase-rate varbase-scale ~
b-calc-rate b-cur-exch-rate varexch-rate varexch-scale b-calc-exch-rate ~
b-calc-cli-t-rubl b-calc-rubl-t-cli b-calc-rubl-t-base b-calc-base-t-rubl ~
varsum-rubl varprice-base varsum-base varprice-cli varsum-cli varprice-rubl ~
varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat ~
varprice-rubl-vat varsum-rubl-vat varprice-base-slt varsum-base-slt ~
varprice-cli-slt varsum-cli-slt varprice-rubl-slt varsum-rubl-slt ~
varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax ~
varsum-cli-road-tax varprice-rubl-road-tax varsum-rubl-road-tax ~
varprice-base-transport varsum-base-transport varprice-rubl-transport ~
varsum-rubl-transport varpurch-code-name varprice-base-other ~
varsum-base-other varprice-rubl-other varsum-rubl-other
&Scoped-Define DISPLAYED-OBJECTS varobj-type varobj-code varobj-name ~
varsupp-type varsupp-code varsupp-name varfact-qnty varartic varprod-type ~
varprod-code vargds-name varvat-type varold-vat-pc varvat-pc ~
varincome-in-code varin-code varpart-code varslt-type varold-slt-pc ~
varslt-pc varcur-base-name varcur-base-rate varcur-base-scale ~
varold-base-rate varbase-rate varbase-scale varcur-cli-name ~
varcur-exch-rate varcur-exch-scale varold-exch-rate varexch-rate ~
varexch-scale varcli-base-rate varold-price-cli varold-sum-cli ~
varold-price-rubl varold-sum-rubl varold-price-base varold-sum-base ~
varsum-rubl varprice-base varsum-base varprice-cli varsum-cli varprice-rubl ~
varold-price-base-vat varold-sum-base-vat varold-price-cli-vat ~
varold-sum-cli-vat varold-price-rubl-vat varold-sum-rubl-vat ~
varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat ~
varprice-rubl-vat varsum-rubl-vat varold-price-base-slt varold-sum-base-slt ~
varold-price-cli-slt varold-sum-cli-slt varold-price-rubl-slt ~
varold-sum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt ~
varsum-cli-slt varprice-rubl-slt varsum-rubl-slt varold-price-base-road-tax ~
varold-sum-base-road-tax varold-price-cli-road-tax varold-sum-cli-road-tax ~
varold-price-rubl-road-tax varold-sum-rubl-road-tax varprice-base-road-tax ~
varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax ~
varprice-rubl-road-tax varsum-rubl-road-tax varold-price-base-transport ~
varold-sum-base-transport varold-price-rubl-transport ~
varold-sum-rubl-transport varold-purch-code-name varprice-base-transport ~
varsum-base-transport varprice-rubl-transport varsum-rubl-transport ~
varpurch-code-name varold-price-base-other varold-sum-base-other ~
varold-price-rubl-other varold-sum-rubl-other varprice-base-other ~
varsum-base-other varprice-rubl-other varsum-rubl-other v-rubli-firstshift ~
vartitle-road-tax

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc-base-t-rubl
     LABEL ">"
     SIZE 5 BY .75.

DEFINE BUTTON b-calc-cli-t-rubl
     LABEL "<"
     SIZE 5 BY .75.

DEFINE BUTTON b-calc-exch-rate
     LABEL "Расчет"
     SIZE 6.5 BY 1.

DEFINE BUTTON b-calc-rate
     LABEL "Расчет"
     SIZE 6.5 BY 1.

DEFINE BUTTON b-calc-rubl-t-base
     LABEL "<"
     SIZE 5 BY .75.

DEFINE BUTTON b-calc-rubl-t-cli
     LABEL ">"
     SIZE 5 BY .75.

DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-cur-exch-rate
     LABEL "Уст"
     SIZE 3.5 BY 1.

DEFINE BUTTON b-cur-rate
     LABEL "Уст"
     SIZE 3.5 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE varpurch-code-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE v-rubli-firstshift AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(16)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varbase-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.

DEFINE VARIABLE varbase-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-base-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Единица поставщика"
     VIEW-AS FILL-IN
     SIZE 10 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varcur-base-name AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varcur-base-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Тек"
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.

DEFINE VARIABLE varcur-base-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE varcur-cli-name AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varcur-exch-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Тек"
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.

DEFINE VARIABLE varcur-exch-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE varexch-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.

DEFINE VARIABLE varexch-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1 NO-UNDO.

DEFINE VARIABLE varfact-qnty AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     LABEL "Факт"
     VIEW-AS FILL-IN
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(48)":U
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE varin-code AS CHARACTER FORMAT "X(14)":U
     LABEL "ПН"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varincome-in-code AS CHARACTER FORMAT "X(14)":U
     LABEL "ВнПН"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-name AS CHARACTER FORMAT "X(40)":U
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varold-base-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12.38 BY 1 NO-UNDO.

DEFINE VARIABLE varold-exch-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12.38 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-base AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-base-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-base-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-base-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-base-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-base-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-cli AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-cli-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-cli-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-cli-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-rubl AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-rubl-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-rubl-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-rubl-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-rubl-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-price-rubl-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varold-purch-code-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE varold-slt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-base AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-base-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-base-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-base-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-base-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-base-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-cli AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-cli-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-cli-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-cli-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-rubl-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-rubl-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-rubl-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-rubl-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-sum-rubl-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varold-vat-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varpart-code AS CHARACTER FORMAT "X(20)":U
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-base AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-base-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-base-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-base-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-base-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-base-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-cli AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-cli-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-cli-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-cli-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-rubl AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-rubl-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-rubl-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-rubl-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-rubl-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprice-rubl-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE varprod-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varprod-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varslt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varslt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НП"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varsum-base AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-base-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-base-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-base-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-base-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-base-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-cli AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-cli-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-cli-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-cli-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-rubl-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-rubl-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-rubl-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-rubl-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsum-rubl-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varsupp-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varsupp-name AS CHARACTER FORMAT "X(40)":U
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE varsupp-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE vartitle-road-tax AS CHARACTER FORMAT "X(256)":U INITIAL "Стеклопосуда"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE varvat-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varvat-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32 BY 4.88.

DEFINE RECTANGLE RECT-goods
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 1.42.

DEFINE RECTANGLE RECT-object
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.5 BY 1.42.

DEFINE RECTANGLE RECT-other
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.13 BY 2.17.

DEFINE RECTANGLE RECT-part
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.38 BY 1.42.

DEFINE RECTANGLE RECT-part-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.38 BY 2.5.

DEFINE RECTANGLE RECT-price
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.5.

DEFINE RECTANGLE RECT-road-tax
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.42.

DEFINE RECTANGLE RECT-slt
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.46.

DEFINE RECTANGLE RECT-transport
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.13 BY 2.33.

DEFINE RECTANGLE RECT-vat
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varobj-type AT ROW 1.25 COL 37.25 COLON-ALIGNED NO-LABEL
     varobj-code AT ROW 1.25 COL 41.75 COLON-ALIGNED NO-LABEL
     varobj-name AT ROW 1.25 COL 47.88 COLON-ALIGNED NO-LABEL
     varsupp-type AT ROW 1.25 COL 71.25 COLON-ALIGNED NO-LABEL
     varsupp-code AT ROW 1.25 COL 75.5 COLON-ALIGNED NO-LABEL
     varsupp-name AT ROW 1.25 COL 81.75 COLON-ALIGNED NO-LABEL
     varfact-qnty AT ROW 2.5 COL 72.5 COLON-ALIGNED
     varartic AT ROW 2.63 COL 7.5 COLON-ALIGNED
     varprod-type AT ROW 2.63 COL 25 COLON-ALIGNED NO-LABEL
     varprod-code AT ROW 2.63 COL 29.63 COLON-ALIGNED NO-LABEL
     vargds-name AT ROW 2.63 COL 40 COLON-ALIGNED NO-LABEL
     varvat-type AT ROW 4 COL 71.5 COLON-ALIGNED
     varold-vat-pc AT ROW 4 COL 84 COLON-ALIGNED NO-LABEL
     varvat-pc AT ROW 4 COL 90.5 COLON-ALIGNED NO-LABEL
     varincome-in-code AT ROW 4.25 COL 6 COLON-ALIGNED
     varin-code AT ROW 4.25 COL 25 COLON-ALIGNED
     varpart-code AT ROW 4.25 COL 45 COLON-ALIGNED
     varslt-type AT ROW 5.25 COL 71.5 COLON-ALIGNED
     varold-slt-pc AT ROW 5.25 COL 84 COLON-ALIGNED NO-LABEL
     varslt-pc AT ROW 5.25 COL 90.5 COLON-ALIGNED NO-LABEL
     varcur-base-name AT ROW 5.5 COL 9.5 NO-LABEL
     varcur-base-rate AT ROW 5.5 COL 16.5 COLON-ALIGNED
     varcur-base-scale AT ROW 5.5 COL 25 COLON-ALIGNED NO-LABEL
     b-cur-rate AT ROW 5.5 COL 32
     varold-base-rate AT ROW 5.5 COL 33.5 COLON-ALIGNED NO-LABEL
     varbase-rate AT ROW 5.5 COL 46.5 COLON-ALIGNED NO-LABEL
     varbase-scale AT ROW 5.5 COL 55 COLON-ALIGNED NO-LABEL
     b-calc-rate AT ROW 5.5 COL 61.5
     varcur-cli-name AT ROW 6.5 COL 9.5 NO-LABEL
     varcur-exch-rate AT ROW 6.5 COL 16.5 COLON-ALIGNED
     varcur-exch-scale AT ROW 6.5 COL 25 COLON-ALIGNED NO-LABEL
     b-cur-exch-rate AT ROW 6.5 COL 32
     varold-exch-rate AT ROW 6.5 COL 33.5 COLON-ALIGNED NO-LABEL
     varexch-rate AT ROW 6.5 COL 46.5 COLON-ALIGNED NO-LABEL
     varexch-scale AT ROW 6.5 COL 55 COLON-ALIGNED NO-LABEL
     b-calc-exch-rate AT ROW 6.5 COL 61.5
     varcli-base-rate AT ROW 6.5 COL 87 COLON-ALIGNED
     b-calc-cli-t-rubl AT ROW 7.75 COL 28.5
     b-calc-rubl-t-cli AT ROW 7.75 COL 33.5
     b-calc-rubl-t-base AT ROW 7.75 COL 61
     b-calc-base-t-rubl AT ROW 7.75 COL 66
     varold-price-cli AT ROW 8.5 COL 1 NO-LABEL
     varold-sum-cli AT ROW 8.5 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl AT ROW 8.5 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl AT ROW 8.5 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base AT ROW 8.5 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base AT ROW 8.5 COL 79.75 COLON-ALIGNED NO-LABEL
     varsum-rubl AT ROW 9.5 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base AT ROW 9.5 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base AT ROW 9.5 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli AT ROW 9.54 COL 1 NO-LABEL
     varsum-cli AT ROW 9.54 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl AT ROW 9.54 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-price-base-vat AT ROW 11.17 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-vat AT ROW 11.17 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-cli-vat AT ROW 11.21 COL 1 NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     varold-sum-cli-vat AT ROW 11.21 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl-vat AT ROW 11.21 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-vat AT ROW 11.21 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-vat AT ROW 12.08 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-vat AT ROW 12.08 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli-vat AT ROW 12.13 COL 1 NO-LABEL
     varsum-cli-vat AT ROW 12.13 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl-vat AT ROW 12.13 COL 31.5 COLON-ALIGNED NO-LABEL
     varsum-rubl-vat AT ROW 12.13 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base-slt AT ROW 13.67 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-slt AT ROW 13.67 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-cli-slt AT ROW 13.71 COL 1 NO-LABEL
     varold-sum-cli-slt AT ROW 13.71 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl-slt AT ROW 13.71 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-slt AT ROW 13.71 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-slt AT ROW 14.71 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-slt AT ROW 14.71 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli-slt AT ROW 14.75 COL 1 NO-LABEL
     varsum-cli-slt AT ROW 14.75 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl-slt AT ROW 14.75 COL 31.5 COLON-ALIGNED NO-LABEL
     varsum-rubl-slt AT ROW 14.75 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base-road-tax AT ROW 16.25 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-road-tax AT ROW 16.25 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-cli-road-tax AT ROW 16.29 COL 1 NO-LABEL
     varold-sum-cli-road-tax AT ROW 16.29 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl-road-tax AT ROW 16.29 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-road-tax AT ROW 16.29 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-road-tax AT ROW 17.33 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-road-tax AT ROW 17.33 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli-road-tax AT ROW 17.38 COL 1 NO-LABEL
     varsum-cli-road-tax AT ROW 17.38 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl-road-tax AT ROW 17.38 COL 33.5 NO-LABEL
     varsum-rubl-road-tax AT ROW 17.38 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base-transport AT ROW 19 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-transport AT ROW 19 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-rubl-transport AT ROW 19.04 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-transport AT ROW 19.04 COL 47 COLON-ALIGNED NO-LABEL
     varold-purch-code-name AT ROW 19.75 COL 1.5 NO-LABEL
     varprice-base-transport AT ROW 19.92 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-transport AT ROW 19.92 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-rubl-transport AT ROW 19.96 COL 33.5 NO-LABEL
     varsum-rubl-transport AT ROW 19.96 COL 47 COLON-ALIGNED NO-LABEL
     varpurch-code-name AT ROW 21.5 COL 1.5 NO-LABEL
     varold-price-base-other AT ROW 21.67 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-other AT ROW 21.67 COL 79.75 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     varold-price-rubl-other AT ROW 21.71 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-other AT ROW 21.71 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-other AT ROW 22.58 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-other AT ROW 22.58 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-rubl-other AT ROW 22.63 COL 33.5 NO-LABEL
     varsum-rubl-other AT ROW 22.63 COL 47 COLON-ALIGNED NO-LABEL
     v-rubli-firstshift AT ROW 7.75 COL 45 NO-LABEL
     vartitle-road-tax AT ROW 15.71 COL 1.5 NO-LABEL
     "Цена" VIEW-AS TEXT
          SIZE 4.5 BY .67 AT ROW 7.75 COL 40
          BGCOLOR 3 FGCOLOR 15
     "Сумма" VIEW-AS TEXT
          SIZE 5.5 BY .67 AT ROW 7.75 COL 91.5
          BGCOLOR 3 FGCOLOR 15
     "Транспортные расходы" VIEW-AS TEXT
          SIZE 21.25 BY .67 AT ROW 18.25 COL 33
          BGCOLOR 3 FGCOLOR 15
     "НДС" VIEW-AS TEXT
          SIZE 4 BY .67 AT ROW 10.46 COL 1.38
          BGCOLOR 3 FGCOLOR 15
     "Сумма" VIEW-AS TEXT
          SIZE 5.5 BY .67 AT ROW 7.75 COL 22.5
          BGCOLOR 3 FGCOLOR 15
     "Цена" VIEW-AS TEXT
          SIZE 4.5 BY .67 AT ROW 7.75 COL 71.5
          BGCOLOR 3 FGCOLOR 15
     "Цена" VIEW-AS TEXT
          SIZE 4.5 BY .67 AT ROW 7.75 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     "ВалПост" VIEW-AS TEXT
          SIZE 7.5 BY .67 AT ROW 6.75 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     "Базовая валюта" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 7.75 COL 76.5
          BGCOLOR 3 FGCOLOR 15
     "Объект" VIEW-AS TEXT
          SIZE 6.25 BY .67 AT ROW 1.42 COL 33
     "Сумма" VIEW-AS TEXT
          SIZE 5.5 BY .67 AT ROW 7.75 COL 51.5
          BGCOLOR 3 FGCOLOR 15
     "Прочие расходы" VIEW-AS TEXT
          SIZE 15.13 BY .67 AT ROW 21 COL 33
          BGCOLOR 3 FGCOLOR 15
     "Поставщик" VIEW-AS TEXT
          SIZE 9.75 BY .67 AT ROW 1.42 COL 63.13
     "Валюта пост." VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 7.75 COL 9
          BGCOLOR 3 FGCOLOR 15
     "НП" VIEW-AS TEXT
          SIZE 4 BY .67 AT ROW 12.96 COL 1.38
          BGCOLOR 3 FGCOLOR 15
     "Тип приобретения" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 18.5 COL 9.5
          BGCOLOR 3 FGCOLOR 15
     "БазВал" VIEW-AS TEXT
          SIZE 7.5 BY .67 AT ROW 5.75 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     RECT-goods AT ROW 2.46 COL 1.13
     RECT-transport AT ROW 18.79 COL 33
     RECT-object AT ROW 1 COL 32.5
     RECT-part AT ROW 4.04 COL 1
     RECT-other AT ROW 21.46 COL 33
     RECT-road-tax AT ROW 16.04 COL 1.13
     RECT-price AT ROW 8.25 COL 1
     RECT-slt AT ROW 13.46 COL 1.13
     RECT-vat AT ROW 10.83 COL 1.13
     RECT-part-2 AT ROW 5.25 COL 1
     RECT-1 AT ROW 18.79 COL 1
     SPACE(66.13) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Установка цены"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-part IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-part-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-rubli-firstshift IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varartic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcli-base-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcur-base-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varcur-base-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcur-base-scale IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcur-cli-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varcur-exch-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcur-exch-scale IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfact-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vargds-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varin-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varincome-in-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varobj-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varobj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varobj-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-base-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-exch-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-base-other IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-base-road-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-base-slt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-base-transport IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-base-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-cli IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varold-price-cli-road-tax IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varold-price-cli-slt IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varold-price-cli-vat IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varold-price-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-rubl-other IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-rubl-road-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-rubl-slt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-rubl-transport IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-price-rubl-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-purch-code-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varold-slt-pc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-base-other IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-base-road-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-base-slt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-base-transport IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-base-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-cli-road-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-cli-slt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-cli-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-rubl-other IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-rubl-road-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-rubl-slt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-rubl-transport IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-sum-rubl-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varold-vat-pc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varpart-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprice-cli IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varprice-cli-road-tax IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varprice-cli-slt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varprice-cli-vat IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varprice-rubl-other IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varprice-rubl-road-tax IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varprice-rubl-transport IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varprod-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX varpurch-code-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varslt-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varsupp-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varsupp-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varsupp-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vartitle-road-tax IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varvat-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON return OF FRAME Dialog-Frame /* Установка цены */
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Установка цены */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-base-t-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-base-t-rubl Dialog-Frame
ON CHOOSE OF b-calc-base-t-rubl IN FRAME Dialog-Frame /* > */
DO:
  run proc-calc-base-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Ошибка при пересчете значений в базовой валюте." SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE(1) SKIP
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-cli-t-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-cli-t-rubl Dialog-Frame
ON CHOOSE OF b-calc-cli-t-rubl IN FRAME Dialog-Frame /* < */
DO:
  run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE "Ошибка при пересчете значений в валюте клиента." SKIP
             RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1) SKIP
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-exch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-exch-rate Dialog-Frame
ON CHOOSE OF b-calc-exch-rate IN FRAME Dialog-Frame /* Расчет */
DO:
  run proc-calc-exch-rate in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при пересчете курса валюты поставщика." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box error.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-rate Dialog-Frame
ON CHOOSE OF b-calc-rate IN FRAME Dialog-Frame /* Расчет */
DO:
  run proc-calc-rate in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Ошибка при расчете по новому курсу базовой валюты." SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE(1) SKIP
            ERROR-STATUS:GET-MESSAGE(2)
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-rubl-t-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-rubl-t-base Dialog-Frame
ON CHOOSE OF b-calc-rubl-t-base IN FRAME Dialog-Frame /* < */
DO:
  run proc-calc-rubl-base in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Ошибка при пересчете значений в {&abbr_rublyah}." SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE(1) SKIP
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
if varexcheqrubl then do:
  run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE "Ошибка при пересчете значений в валюте." SKIP
             RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1) SKIP
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-rubl-t-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-rubl-t-cli Dialog-Frame
ON CHOOSE OF b-calc-rubl-t-cli IN FRAME Dialog-Frame /* > */
DO:
run proc-calc-rubl-cli in THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   MESSAGE "Ошибка при пересчете значений в {&abbr_rublyah}." SKIP
           RETURN-VALUE SKIP
           ERROR-STATUS:GET-MESSAGE(1) SKIP
   VIEW-AS ALERT-BOX ERROR.
   RETURN NO-APPLY.
END.
if varbaseeqrubl then do:
  run proc-calc-base-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE "Ошибка при пересчете значений в валюте." SKIP
             RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1) SKIP
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  assign
    paris-ok = false.
  apply "go" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cur-exch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cur-exch-rate Dialog-Frame
ON CHOOSE OF b-cur-exch-rate IN FRAME Dialog-Frame /* Уст */
DO:
  run state-cur-exch-rate in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке текущего курса." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
     view-as alert-box.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cur-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cur-rate Dialog-Frame
ON CHOOSE OF b-cur-rate IN FRAME Dialog-Frame /* Уст */
DO:
  run state-cur-rate in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке текущего курса." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
     view-as alert-box.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  {&rate-correct}
  {&rate-exch-correct}
  /*Если не отработали триггера на leave*/
  if round(varbase-rate           , 4) <> input frame {&frame-name} varbase-rate             then apply "leave" to varbase-rate            in frame {&frame-name}.
  if       varbase-scale               <> input frame {&frame-name} varbase-scale            then apply "leave" to varbase-scale           in frame {&frame-name}.
  if varprice-base           <> input frame {&frame-name} varprice-base            then apply "leave" to varprice-base           in frame {&frame-name}.
  if varsum-base             <> input frame {&frame-name} varsum-base              then apply "leave" to varsum-base             in frame {&frame-name}.
  if varprice-rubl           <> input frame {&frame-name} varprice-rubl            then apply "leave" to varprice-rubl           in frame {&frame-name}.
  if varsum-rubl             <> input frame {&frame-name} varsum-rubl              then apply "leave" to varsum-rubl             in frame {&frame-name}.
  if varprice-cli            <> input frame {&frame-name} varprice-cli             then apply "leave" to varprice-cli            in frame {&frame-name}.
  if varsum-cli              <> input frame {&frame-name} varsum-cli               then apply "leave" to varsum-cli              in frame {&frame-name}.
  if round (varvat-pc, 2)    <> input frame {&frame-name} varvat-pc                then apply "leave" to varvat-pc               in frame {&frame-name}.
  if varprice-base-vat       <> input frame {&frame-name} varprice-base-vat        then apply "leave" to varprice-base-vat       in frame {&frame-name}.
  if varsum-base-vat         <> input frame {&frame-name} varsum-base-vat          then apply "leave" to varsum-base-vat         in frame {&frame-name}.
  if varprice-rubl-vat       <> input frame {&frame-name} varprice-rubl-vat        then apply "leave" to varprice-rubl-vat       in frame {&frame-name}.
  if varsum-rubl-vat         <> input frame {&frame-name} varsum-rubl-vat          then apply "leave" to varsum-rubl-vat         in frame {&frame-name}.
  if varprice-cli-vat        <> input frame {&frame-name} varprice-cli-vat         then apply "leave" to varprice-cli-vat        in frame {&frame-name}.
  if varsum-cli-vat          <> input frame {&frame-name} varsum-cli-vat           then apply "leave" to varsum-cli-vat          in frame {&frame-name}.
  if round(varslt-pc, 2)     <> input frame {&frame-name} varslt-pc                then apply "leave" to varslt-pc               in frame {&frame-name}.
  if varprice-base-slt       <> input frame {&frame-name} varprice-base-slt        then apply "leave" to varprice-base-slt       in frame {&frame-name}.
  if varsum-base-slt         <> input frame {&frame-name} varsum-base-slt          then apply "leave" to varsum-base-slt         in frame {&frame-name}.
  if varprice-rubl-slt       <> input frame {&frame-name} varprice-rubl-slt        then apply "leave" to varprice-rubl-slt       in frame {&frame-name}.
  if varsum-rubl-slt         <> input frame {&frame-name} varsum-rubl-slt          then apply "leave" to varsum-rubl-slt         in frame {&frame-name}.
  if varprice-cli-slt        <> input frame {&frame-name} varprice-cli-slt         then apply "leave" to varprice-cli-slt        in frame {&frame-name}.
  if varsum-cli-slt          <> input frame {&frame-name} varsum-cli-slt           then apply "leave" to varsum-cli-slt          in frame {&frame-name}.
  if varprice-base-road-tax  <> input frame {&frame-name} varprice-base-road-tax   then apply "leave" to varprice-base-road-tax  in frame {&frame-name}.
  if varsum-base-road-tax    <> input frame {&frame-name} varsum-base-road-tax     then apply "leave" to varsum-base-road-tax    in frame {&frame-name}.
  if varprice-rubl-road-tax  <> input frame {&frame-name} varprice-rubl-road-tax   then apply "leave" to varprice-rubl-road-tax  in frame {&frame-name}.
  if varsum-rubl-road-tax    <> input frame {&frame-name} varsum-rubl-road-tax     then apply "leave" to varsum-rubl-road-tax    in frame {&frame-name}.
  if varprice-cli-road-tax   <> input frame {&frame-name} varprice-cli-road-tax    then apply "leave" to varprice-cli-road-tax   in frame {&frame-name}.
  if varsum-cli-road-tax     <> input frame {&frame-name} varsum-cli-road-tax      then apply "leave" to varsum-cli-road-tax     in frame {&frame-name}.
  if varprice-base-transport <> input frame {&frame-name} varprice-base-transport  then apply "leave" to varprice-base-transport in frame {&frame-name}.
  if varsum-base-transport   <> input frame {&frame-name} varsum-base-transport    then apply "leave" to varsum-base-transport   in frame {&frame-name}.
  if varprice-rubl-transport <> input frame {&frame-name} varprice-rubl-transport  then apply "leave" to varprice-rubl-transport in frame {&frame-name}.
  if varsum-rubl-transport   <> input frame {&frame-name} varsum-rubl-transport    then apply "leave" to varsum-rubl-transport   in frame {&frame-name}.
  if varprice-base-other     <> input frame {&frame-name} varprice-base-other      then apply "leave" to varprice-base-other     in frame {&frame-name}.
  if varsum-base-other       <> input frame {&frame-name} varsum-base-other        then apply "leave" to varsum-base-other       in frame {&frame-name}.
  if varprice-rubl-other     <> input frame {&frame-name} varprice-rubl-other      then apply "leave" to varprice-rubl-other     in frame {&frame-name}.
  if varsum-rubl-other       <> input frame {&frame-name} varsum-rubl-other        then apply "leave" to varsum-rubl-other       in frame {&frame-name}.
  IF varpurch-code-name      <> INPUT FRAME {&FRAME-NAME} varpurch-code-name       THEN APPLY "leave" TO varpurch-code-name      IN FRAME {&FRAME-NAME}.
  if varbase-rate            < 0                      or varbase-rate         = ?  then do: message "Неверный курс базовой валюты: "                                                varbase-rate            view-as alert-box. apply "entry" to varbase-rate            in frame {&frame-name}. return no-apply. end.
  if varbase-scale           < 0                      or varbase-scale        = ?  then do: message "Неверная шкала курса базовой валюты: "                                         varbase-scale           view-as alert-box. apply "entry" to varbase-scale           in frame {&frame-name}. return no-apply. end.
  if varprice-base           < 0                      or varprice-base        = ?  then do: message "Неверная цена в базовой валюте: "                                              varprice-base           view-as alert-box. apply "entry" to varprice-base           in frame {&frame-name}. return no-apply. end.
  if varsum-base             < 0                      or varsum-base          = ?  then do: message "Неверная сумма в базовой валюте: "                                             varsum-base             view-as alert-box. apply "entry" to varsum-base             in frame {&frame-name}. return no-apply. end.
  if varprice-rubl           < 0                      or varprice-rubl        = ?  then do: message "Неверная цена в {&abbr_rublyah} "                                                       varprice-rubl           view-as alert-box. apply "entry" to varprice-rubl           in frame {&frame-name}. return no-apply. end.
  if varsum-rubl             < 0                      or varsum-rubl          = ?  then do: message "Неверная сумма в {&abbr_rublyah}: "                                                     varsum-rubl             view-as alert-box. apply "entry" to varsum-rubl             in frame {&frame-name}. return no-apply. end.
  if varprice-cli            < 0                      or varprice-cli         = ?  then do: message "Неверная цена в валюте поставщика "                                            varprice-cli            view-as alert-box. apply "entry" to varprice-cli            in frame {&frame-name}. return no-apply. end.
  if varsum-cli              < 0                      or varsum-cli           = ?  then do: message "Неверная сумма в валюте поставщика: "                                          varsum-cli              view-as alert-box. apply "entry" to varsum-cli              in frame {&frame-name}. return no-apply. end.
  if varvat-pc               < 0 or varvat-pc > 100.0 or varvat-pc            = ?  then do: message "Неверный процент НДС: "                                                        varvat-pc               view-as alert-box. apply "entry" to varvat-pc               in frame {&frame-name}. return no-apply. end.
  if varprice-base-vat       < 0                      or varprice-base-vat    = ?  then do: message "Неверная ценовая компонента НДС в базовой валюте: "                            varprice-base-vat       view-as alert-box. apply "entry" to varprice-base-vat       in frame {&frame-name}. return no-apply. end.
  if varsum-base-vat         < 0                      or varsum-base-vat      = ?  then do: message "Неверная сумма НДС в базовой валюте: "                                         varsum-base-vat         view-as alert-box. apply "entry" to varsum-base-vat         in frame {&frame-name}. return no-apply. end.
  if varprice-rubl-vat       < 0                      or varprice-rubl-vat    = ?  then do: message "Неверная ценовая компонента НДС в {&abbr_rublyah}: "                                    varprice-rubl-vat       view-as alert-box. apply "entry" to varprice-rubl-vat       in frame {&frame-name}. return no-apply. end.
  if varsum-rubl-vat         < 0                      or varsum-rubl-vat      = ?  then do: message "Неверная сумма НДС в {&abbr_rublyah}: "                                                 varsum-rubl-vat         view-as alert-box. apply "entry" to varsum-rubl-vat         in frame {&frame-name}. return no-apply. end.
  if varprice-cli-vat        < 0                      or varprice-cli-vat     = ?  then do: message "Неверная ценовая компонента НДС в валюте поставщика: "                         varprice-cli-vat        view-as alert-box. apply "entry" to varprice-cli-vat        in frame {&frame-name}. return no-apply. end.
  if varsum-cli-vat          < 0                      or varsum-cli-vat       = ?  then do: message "Неверная сумма НДС в валюте поставщика: "                                      varsum-cli-vat          view-as alert-box. apply "entry" to varsum-cli-vat          in frame {&frame-name}. return no-apply. end.
  if varslt-pc               < 0 or varslt-pc > 100.0 or varslt-pc            = ?  then do: message "Неверный процент НП: "                                                         varslt-pc               view-as alert-box. apply "entry" to varslt-pc               in frame {&frame-name}. return no-apply. end.
  if varprice-base-slt       < 0                      or varprice-base-slt    = ?  then do: message "Неверная ценовая компонента НП в базовой валюте: "                             varprice-base-slt       view-as alert-box. apply "entry" to varprice-base-slt       in frame {&frame-name}. return no-apply. end.
  if varsum-base-slt         < 0                      or varsum-base-slt      = ?  then do: message "Неверная сумма НП в базовой валюте: "                                          varsum-base-slt         view-as alert-box. apply "entry" to varsum-base-slt         in frame {&frame-name}. return no-apply. end.
  if varprice-rubl-slt       < 0                      or varprice-rubl-slt    = ?  then do: message "Неверная ценовая компонента НП в {&abbr_rublyah}: "                                     varprice-rubl-slt       view-as alert-box. apply "entry" to varprice-rubl-slt       in frame {&frame-name}. return no-apply. end.
  if varsum-rubl-slt         < 0                      or varsum-rubl-slt      = ?  then do: message "Неверная сумма НП в {&abbr_rublyah}: "                                                  varsum-rubl-slt         view-as alert-box. apply "entry" to varsum-rubl-slt         in frame {&frame-name}. return no-apply. end.
  if varprice-cli-slt        < 0                      or varprice-cli-slt     = ?  then do: message "Неверная ценовая компонента НП в валюте поставщика: "                          varprice-cli-slt        view-as alert-box. apply "entry" to varprice-cli-slt        in frame {&frame-name}. return no-apply. end.
  if varsum-cli-slt          < 0                      or varsum-cli-slt       = ?  then do: message "Неверная сумма НП в валюте поставщика: "                                       varsum-cli-slt          view-as alert-box. apply "entry" to varsum-cli-slt          in frame {&frame-name}. return no-apply. end.
  if varprice-base-road-tax  < 0                      or varprice-base-road-tax  = ? then do: message "Неверная ценовая компонента налога <" vartitle-road-tax "> в базовой валюте: " varprice-base-road-tax  view-as alert-box. apply "entry" to varprice-base-road-tax  in frame {&frame-name}. return no-apply. end.
  if varsum-base-road-tax    < 0                      or varsum-base-road-tax    = ? then do: message "Неверная сумма налога <"              vartitle-road-tax "> в базовой валюте: " varsum-base-road-tax    view-as alert-box. apply "entry" to varsum-base-road-tax    in frame {&frame-name}. return no-apply. end.
  if varprice-rubl-road-tax  < 0                      or varprice-rubl-road-tax  = ? then do: message "Неверная ценовая компонента налога <" vartitle-road-tax "> в {&abbr_rublyah}: "         varprice-rubl-road-tax  view-as alert-box. apply "entry" to varprice-rubl-road-tax  in frame {&frame-name}. return no-apply. end.
  if varsum-rubl-road-tax    < 0                      or varsum-rubl-road-tax    = ? then do: message "Неверная сумма налога <"              vartitle-road-tax "> в {&abbr_rublyah}: "         varsum-rubl-road-tax    view-as alert-box. apply "entry" to varsum-rubl-road-tax    in frame {&frame-name}. return no-apply. end.
  if varprice-cli-road-tax   < 0                      or varprice-cli-road-tax   = ? then do: message "Неверная ценовая компонента налога <" vartitle-road-tax "> в валюте поставщика: " varprice-rubl-road-tax  view-as alert-box. apply "entry" to varprice-rubl-road-tax  in frame {&frame-name}. return no-apply. end.
  if varsum-cli-road-tax     < 0                      or varsum-cli-road-tax     = ? then do: message "Неверная сумма налога <"              vartitle-road-tax "> в валюте поставщика: " varsum-rubl-road-tax    view-as alert-box. apply "entry" to varsum-rubl-road-tax    in frame {&frame-name}. return no-apply. end.
  if varprice-base-transport < 0                      or varprice-base-transport = ? then do: message "Неверная ценовая компонента транспортного расхода в базовой валюте: "          varprice-base-transport view-as alert-box. apply "entry" to varprice-base-transport in frame {&frame-name}. return no-apply. end.
  if varsum-base-transport   < 0                      or varsum-base-transport   = ? then do: message "Неверная сумма транспортного расхода в базовой валюте: "                       varsum-base-transport   view-as alert-box. apply "entry" to varsum-base-transport   in frame {&frame-name}. return no-apply. end.
  if varprice-rubl-transport < 0                      or varprice-rubl-transport = ? then do: message "Неверная ценовая компонента транспортного расхода в {&abbr_rublyah}: "                  varprice-rubl-transport view-as alert-box. apply "entry" to varprice-rubl-transport in frame {&frame-name}. return no-apply. end.
  if varsum-rubl-transport   < 0                      or varsum-rubl-transport   = ? then do: message "Неверная сумма транспортного расхода в {&abbr_rublyah}: "                               varsum-rubl-transport   view-as alert-box. apply "entry" to varsum-rubl-transport   in frame {&frame-name}. return no-apply. end.
  if varprice-base-other     < 0                      or varprice-base-other     = ? then do: message "Неверная ценовая компонента прочего расхода в базовой валюте: "                varprice-base-other     view-as alert-box. apply "entry" to varprice-base-other     in frame {&frame-name}. return no-apply. end.
  if varsum-base-other       < 0                      or varsum-base-other       = ? then do: message "Неверная сумма прочего расхода в базовой валюте: "                             varsum-base-other       view-as alert-box. apply "entry" to varsum-base-other       in frame {&frame-name}. return no-apply. end.
  if varprice-rubl-other     < 0                      or varprice-rubl-other     = ? then do: message "Неверная ценовая компонента прочего расхода в {&abbr_rublyah}: "                        varprice-rubl-other     view-as alert-box. apply "entry" to varprice-rubl-other     in frame {&frame-name}. return no-apply. end.
  if varsum-rubl-other       < 0                      or varsum-rubl-other       = ? then do: message "Неверная сумма прочего расхода в {&abbr_rublyah}: "                                     varsum-rubl-other       view-as alert-box. apply "entry" to varsum-rubl-other       in frame {&frame-name}. return no-apply. end.
  assign
    parprice-base         = varprice-base
    parsum-base           = varsum-base
    parprice-rubl         = varprice-rubl
    parsum-rubl           = varsum-rubl
    parprice-cli          = varprice-cli
    parsum-cli            = varsum-cli
    parvat-pc             = varvat-pc
    parvat-base           = varprice-base-vat
    parsum-vat-base       = varsum-base-vat
    parvat-rubl           = varprice-rubl-vat
    parsum-vat-rubl       = varsum-rubl-vat
    parvat-cli            = varprice-cli-vat
    parsum-vat-cli        = varsum-cli-vat
    parslt-pc             = varslt-pc
    parslt-base           = varprice-base-slt
    parsum-slt-base       = varsum-base-slt
    parslt-rubl           = varprice-rubl-slt
    parsum-slt-rubl       = varsum-rubl-slt
    parslt-cli            = varprice-cli-slt
    parsum-slt-cli        = varsum-cli-slt
    parroad-tax-base      = varprice-base-road-tax
    parsum-road-tax-base  = varsum-base-road-tax
    parroad-tax-rubl      = varprice-rubl-road-tax
    parsum-road-tax-rubl  = varsum-rubl-road-tax
    parroad-tax-cli       = varprice-cli-road-tax
    parsum-road-tax-cli   = varsum-cli-road-tax
    partransport-base     = varprice-base-transport
    parsum-transport-base = varsum-base-transport
    partransport-rubl     = varprice-rubl-transport
    parsum-transport-rubl = varsum-rubl-transport
    parother-base         = varprice-base-other
    parsum-other-base     = varsum-base-other
    parother-rubl         = varprice-rubl-other
    parsum-other-rubl     = varsum-rubl-other
    parpurch-code         = (IF varpurch-code-name <> varno-change THEN LOOKUP (varpurch-code-name, {&purchase-codes-full}) ELSE ?)
    paris-ok              = true

    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varbase-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varbase-rate Dialog-Frame
ON LEAVE OF varbase-rate IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} {&self-name} <> round ({&self-name}, 4) then do:
    assign
      frame {&frame-name}
      varbase-rate.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varbase-rate Dialog-Frame
ON return OF varbase-rate IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varbase-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varbase-scale Dialog-Frame
ON LEAVE OF varbase-scale IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} varbase-scale <> varbase-scale then do:
    assign
      frame {&frame-name}
      varbase-scale.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varbase-scale Dialog-Frame
ON return OF varbase-scale IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcli-base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcli-base-rate Dialog-Frame
ON return OF varcli-base-rate IN FRAME Dialog-Frame /* Единица поставщика */
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varexch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varexch-rate Dialog-Frame
ON LEAVE OF varexch-rate IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} {&self-name} <> round ({&self-name}, 4) then do:
    assign
      frame {&frame-name}
      varexch-rate.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varexch-rate Dialog-Frame
ON return OF varexch-rate IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varexch-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varexch-scale Dialog-Frame
ON LEAVE OF varexch-scale IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} varexch-scale <> varexch-scale then do:
    assign
      frame {&frame-name}
      varexch-scale.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varexch-scale Dialog-Frame
ON return OF varexch-scale IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base Dialog-Frame
ON LEAVE OF varprice-base IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    frame {&frame-name} varprice-base.
  assign varsum-base = varprice-base / varfact-qnty.
  display varsum-base with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base Dialog-Frame
ON return OF varprice-base IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-base-other
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-other Dialog-Frame
ON ENTRY OF varprice-base-other IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-other Dialog-Frame
ON LEAVE OF varprice-base-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other   like varsum-rubl-other   no-undo.
define variable varmem-price-base-other like varprice-base-other no-undo.
define variable varmem-sum-base-other   like varsum-base-other   no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other
  .
  assign frame {&frame-name} varprice-base-other.
  assign
    varprice-rubl-other = varprice-base-other * varbase-rate / varbase-scale
    varsum-rubl-other   = varprice-rubl-other * varfact-qnty
    varsum-base-other   = varprice-base-other * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-other = varmem-price-rubl-other
      varsum-rubl-other   = varmem-sum-rubl-other
      varprice-base-other = varmem-price-base-other
      varsum-base-other   = varmem-sum-base-other
    .
  end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-other Dialog-Frame
ON return OF varprice-base-other IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-base-road-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-road-tax Dialog-Frame
ON ENTRY OF varprice-base-road-tax IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-road-tax Dialog-Frame
ON LEAVE OF varprice-base-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame {&frame-name} varprice-base-road-tax.
  assign
    varprice-rubl-road-tax = varprice-base-road-tax * varbase-rate / varbase-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-road-tax = varmem-price-rubl-road-tax
      varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
      varprice-base-road-tax = varmem-price-base-road-tax
      varsum-base-road-tax   = varmem-sum-base-road-tax
      varprice-cli-road-tax  = varmem-price-cli-road-tax
      varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-road-tax Dialog-Frame
ON return OF varprice-base-road-tax IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-base-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-slt Dialog-Frame
ON ENTRY OF varprice-base-slt IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-slt Dialog-Frame
ON LEAVE OF varprice-base-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-slt = varprice-rubl-slt
    varmem-sum-rubl-slt   = varsum-rubl-slt
    varmem-price-base-slt = varprice-base-slt
    varmem-sum-base-slt   = varsum-base-slt
    varmem-price-cli-slt  = varprice-cli-slt
    varmem-sum-cli-slt    = varsum-cli-slt
    varmem-slt-pc         = varslt-pc
   .
  assign frame {&frame-name}
    varprice-base-slt.
  assign
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-rubl-slt = varprice-base-slt * varbase-rate / varbase-scale
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
    varslt-pc         = (varprice-base-slt / (varprice-base - varprice-base-other - varprice-base-transport - varprice-base-road-tax - varprice-base-slt)) * 100
  .
  run chg-slt-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НП." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box.
    assign
     varprice-rubl-slt = varmem-price-rubl-slt
     varsum-rubl-slt   = varmem-sum-rubl-slt
     varprice-base-slt = varmem-price-base-slt
     varsum-base-slt   = varmem-sum-base-slt
     varprice-cli-slt  = varmem-price-cli-slt
     varsum-cli-slt    = varmem-sum-cli-slt
     varslt-pc         = varmem-slt-pc
     .
    display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame {&frame-name}.
  end.
  display varslt-pc with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-slt Dialog-Frame
ON return OF varprice-base-slt IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-base-transport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-transport Dialog-Frame
ON ENTRY OF varprice-base-transport IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-transport Dialog-Frame
ON LEAVE OF varprice-base-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport   like varsum-rubl-transport   no-undo.
define variable varmem-price-base-transport like varprice-base-transport no-undo.
define variable varmem-sum-base-transport   like varsum-base-transport   no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
  .
  assign frame {&frame-name} varprice-base-transport.
  assign
    varprice-rubl-transport = varprice-base-transport * varbase-rate / varbase-scale
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
    varsum-base-transport   = varprice-base-transport * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-transport = varmem-price-rubl-transport
      varsum-rubl-transport   = varmem-sum-rubl-transport
      varprice-base-transport = varmem-price-base-transport
      varsum-base-transport   = varmem-sum-base-transport
    .
  end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-transport Dialog-Frame
ON return OF varprice-base-transport IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-base-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-vat Dialog-Frame
ON ENTRY OF varprice-base-vat IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-vat Dialog-Frame
ON LEAVE OF varprice-base-vat IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
if (input frame {&frame-name} varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100 < 0   or
   (input frame {&frame-name} varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100 > 100 then do:
   message "При такой ценовой компоненте НДС получится неверный процент НДС: " (input frame {&frame-name} varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-price-base-vat in this-procedure.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-base-vat Dialog-Frame
ON return OF varprice-base-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli Dialog-Frame
ON LEAVE OF varprice-cli IN FRAME Dialog-Frame
DO:
define variable varmemprice-cli like varprice-cli no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
   assign
     varmemprice-cli = varprice-cli.
  assign
    frame {&frame-name}
    varprice-cli.
  if varexcheqrubl = yes then do:
    run proc-calc-rubl-cli in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при пересчете части в {&abbr_rublyah}." skip
              return-value
      view-as alert-box error.
      assign
        varprice-cli = varmemprice-cli.
    end.
  end.
  if varexcheqbase = yes then do:
    run proc-calc-baseeqcli in this-procedure no-error.
    if error-status:error then do:
       message "Ошибка при пересчете части в базовой валюте." skip
               return-value
       view-as alert-box error.
       assign
         varprice-cli = varmemprice-cli.
    end.
  end.
  assign varsum-cli = (varprice-cli + varprice-cli-road-tax +
                       (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) +
                       (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0)
                      ) * varfact-qnty / varcli-base-rate.
  display varsum-cli with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli Dialog-Frame
ON return OF varprice-cli IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-cli-road-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-road-tax Dialog-Frame
ON ENTRY OF varprice-cli-road-tax IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-road-tax Dialog-Frame
ON LEAVE OF varprice-cli-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame {&frame-name} varprice-cli-road-tax.
  assign
    varprice-rubl-road-tax = varprice-cli-road-tax  / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varsum-cli-road-tax    = varprice-cli-road-tax / varcli-base-rate * varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-road-tax = varmem-price-rubl-road-tax
      varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
      varprice-base-road-tax = varmem-price-base-road-tax
      varsum-base-road-tax   = varmem-sum-base-road-tax
      varprice-cli-road-tax  = varmem-price-cli-road-tax
      varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-road-tax Dialog-Frame
ON return OF varprice-cli-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-cli-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-slt Dialog-Frame
ON ENTRY OF varprice-cli-slt IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-slt Dialog-Frame
ON LEAVE OF varprice-cli-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-slt = varprice-rubl-slt
    varmem-sum-rubl-slt   = varsum-rubl-slt
    varmem-price-base-slt = varprice-base-slt
    varmem-sum-base-slt   = varsum-base-slt
    varmem-price-cli-slt  = varprice-cli-slt
    varmem-sum-cli-slt    = varsum-cli-slt
    varmem-slt-pc         = varslt-pc
   .
  assign frame {&frame-name}
    varprice-cli-slt.
  assign
    varsum-cli-slt    = varprice-cli-slt / varcli-base-rate * varfact-qnty
    varprice-rubl-slt = varprice-cli-slt / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varslt-pc         = varprice-cli-slt / (varprice-cli + varprice-cli-road-tax + (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) + (if varslt-type <> {&inc-vat} then varprice-cli-slt else 0) - varprice-cli-slt) * 100
  .
  run chg-slt-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НП." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box.
    assign
     varprice-rubl-slt = varmem-price-rubl-slt
     varsum-rubl-slt   = varmem-sum-rubl-slt
     varprice-base-slt = varmem-price-base-slt
     varsum-base-slt   = varmem-sum-base-slt
     varprice-cli-slt  = varmem-price-cli-slt
     varsum-cli-slt    = varmem-sum-cli-slt
     varslt-pc         = varmem-slt-pc
     .
    display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame {&frame-name}.
  end.
  display varslt-pc with frame {&frame-name}.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-slt Dialog-Frame
ON return OF varprice-cli-slt IN FRAME Dialog-Frame
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-cli-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-vat Dialog-Frame
ON ENTRY OF varprice-cli-vat IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-vat Dialog-Frame
ON LEAVE OF varprice-cli-vat IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
if (input frame {&frame-name} varprice-cli-vat / (varprice-cli + (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) + (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat)) * 100 < 0   or
   (input frame {&frame-name} varprice-cli-vat / (varprice-cli + (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) + (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat)) * 100 > 100 then do:
   message "При такой ценовой компоненте НДС получится неверный процент НДС: " (input frame {&frame-name} varprice-cli-vat / (varprice-cli + (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) + (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-price-cli-vat in this-procedure.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-cli-vat Dialog-Frame
ON return OF varprice-cli-vat IN FRAME Dialog-Frame
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl Dialog-Frame
ON LEAVE OF varprice-rubl IN FRAME Dialog-Frame
DO:
define variable varmemprice-rubl like varprice-rubl no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
   assign
     varmemprice-rubl = varprice-rubl.
  assign
    frame {&frame-name}
    varprice-rubl.
  if varbaseeqrubl = yes then do:
    run proc-calc-base-rubl in this-procedure no-error.
    if error-status:error then do:
       message "Ошибка при пересчете валютной части." skip
               return-value
       view-as alert-box error.
       assign
         varprice-rubl = varmemprice-rubl.
    end.
  end.
  assign varsum-rubl = varprice-rubl * varfact-qnty.
  display varsum-rubl with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl Dialog-Frame
ON return OF varprice-rubl IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-rubl-other
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-other Dialog-Frame
ON ENTRY OF varprice-rubl-other IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-other Dialog-Frame
ON LEAVE OF varprice-rubl-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other  like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other    like varsum-rubl-other no-undo.
define variable varmem-price-base-other  like varprice-base-other no-undo.
define variable varmem-sum-base-other    like varsum-base-other no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other

    .
  assign frame {&frame-name} varprice-rubl-other.
  assign
    varsum-rubl-other   = varprice-rubl-other * varfact-qnty
    varprice-base-other = varprice-rubl-other / varbase-rate * varbase-scale
    varsum-base-other   = varprice-base-other * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-other = varmem-price-rubl-other
    varsum-rubl-other   = varmem-sum-rubl-other
    varprice-base-other = varmem-price-base-other
    varsum-base-other   = varmem-sum-base-other
.
end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-other Dialog-Frame
ON return OF varprice-rubl-other IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-rubl-road-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-road-tax Dialog-Frame
ON ENTRY OF varprice-rubl-road-tax IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-road-tax Dialog-Frame
ON LEAVE OF varprice-rubl-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax  like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax    like varsum-rubl-road-tax no-undo.
define variable varmem-price-base-road-tax  like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax    like varsum-base-road-tax no-undo.
define variable varmem-price-cli-road-tax   like varprice-base-road-tax no-undo.
define variable varmem-sum-cli-road-tax     like varsum-base-road-tax no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax

    .
  assign frame {&frame-name} varprice-rubl-road-tax.
  assign
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty.
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-road-tax = varmem-price-rubl-road-tax
    varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
    varprice-base-road-tax = varmem-price-base-road-tax
    varsum-base-road-tax   = varmem-sum-base-road-tax
    varprice-cli-road-tax  = varmem-price-cli-road-tax
    varsum-cli-road-tax    = varmem-sum-cli-road-tax
.
end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-road-tax Dialog-Frame
ON return OF varprice-rubl-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-rubl-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-slt Dialog-Frame
ON ENTRY OF varprice-rubl-slt IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-slt Dialog-Frame
ON LEAVE OF varprice-rubl-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
assign
   varmem-price-rubl-slt = varprice-rubl-slt
   varmem-sum-rubl-slt   = varsum-rubl-slt
   varmem-price-base-slt = varprice-base-slt
   varmem-sum-base-slt   = varsum-base-slt
   varmem-price-cli-slt  = varprice-cli-slt
   varmem-sum-cli-slt    = varsum-cli-slt
   varmem-slt-pc         = varslt-pc
   .

assign frame {&frame-name}
   varprice-rubl-slt.
assign
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
  varsum-base-slt   = varprice-base-slt * varfact-qnty
  varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
  varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
  varslt-pc         = (varprice-rubl-slt / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt)) * 100
  .
run chg-slt-pc in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при изменении процента НП." skip
          return-value skip
          error-status:get-message(1)
  view-as alert-box.
  assign
   varprice-rubl-slt = varmem-price-rubl-slt
   varsum-rubl-slt   = varmem-sum-rubl-slt
   varprice-base-slt = varmem-price-base-slt
   varsum-base-slt   = varmem-sum-base-slt
   varprice-cli-slt  = varmem-price-cli-slt
   varsum-cli-slt    = varmem-sum-cli-slt
   varslt-pc         = varmem-slt-pc
   .
  display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame {&frame-name}.
end.
DISPLAY varslt-pc WITH FRAME {&FRAME-NAME}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-slt Dialog-Frame
ON return OF varprice-rubl-slt IN FRAME Dialog-Frame
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-rubl-transport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-transport Dialog-Frame
ON ENTRY OF varprice-rubl-transport IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-transport Dialog-Frame
ON LEAVE OF varprice-rubl-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport  like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport    like varsum-rubl-transport no-undo.
define variable varmem-price-base-transport  like varprice-base-transport no-undo.
define variable varmem-sum-base-transport    like varsum-base-transport no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
   .
  assign frame {&frame-name} varprice-rubl-transport.
  assign
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
    varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
    varsum-base-transport   = varprice-base-transport * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-transport = varmem-price-rubl-transport
    varsum-rubl-transport   = varmem-sum-rubl-transport
    varprice-base-transport = varmem-price-base-transport
    varsum-base-transport   = varmem-sum-base-transport
.
end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-transport Dialog-Frame
ON return OF varprice-rubl-transport IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varprice-rubl-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-vat Dialog-Frame
ON ENTRY OF varprice-rubl-vat IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-vat Dialog-Frame
ON LEAVE OF varprice-rubl-vat IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
if (input frame {&frame-name} varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100 < 0   or
   (input frame {&frame-name} varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100 > 100 then do:
   message "При такой ценовой компоненте НДС получится неверный процент НДС: " (input frame {&frame-name} varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-price-rubl-vat in this-procedure.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varprice-rubl-vat Dialog-Frame
ON return OF varprice-rubl-vat IN FRAME Dialog-Frame
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varpurch-code-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varpurch-code-name Dialog-Frame
ON VALUE-CHANGED OF varpurch-code-name IN FRAME Dialog-Frame
DO:
  ASSIGN FRAME {&FRAME-NAME} {&self-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varslt-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varslt-pc Dialog-Frame
ON ENTRY OF varslt-pc IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varslt-pc Dialog-Frame
ON LEAVE OF varslt-pc IN FRAME Dialog-Frame
DO:
define variable varmem-slt-pc like ub.doc-line.slt-pc no-undo.
if input frame {&frame-name} {&self-name} <> round ({&self-name}, 2) then do:
assign
  varmem-slt-pc = varslt-pc.
assign
   frame {&frame-name}
   varslt-pc.
run chg-slt-pc in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при изменении процента НП." skip
          return-value skip
          error-status:get-message(1)
  view-as alert-box.
  assign
    varslt-pc = varmem-slt-pc.
  display varslt-pc with frame {&frame-name}.

end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varslt-pc Dialog-Frame
ON return OF varslt-pc IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base Dialog-Frame
ON LEAVE OF varsum-base IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign frame {&frame-name} varsum-base.
  assign varprice-base = varsum-base / varfact-qnty.
  display varprice-base with frame {&frame-name}.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base Dialog-Frame
ON return OF varsum-base IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-base-other
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-other Dialog-Frame
ON ENTRY OF varsum-base-other IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-other Dialog-Frame
ON LEAVE OF varsum-base-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other   like varsum-rubl-other   no-undo.
define variable varmem-price-base-other like varprice-base-other no-undo.
define variable varmem-sum-base-other   like varsum-base-other   no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other
  .
  assign frame {&frame-name} varsum-base-other.
  assign
    varprice-base-other = varsum-base-other / varfact-qnty
    varprice-rubl-other = varprice-base-other * varbase-rate / varbase-scale
    varsum-rubl-other   = varprice-rubl-other * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-other = varmem-price-rubl-other
    varsum-rubl-other   = varmem-sum-rubl-other
    varprice-base-other = varmem-price-base-other
    varsum-base-other   = varmem-sum-base-other
    .
  end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-other Dialog-Frame
ON return OF varsum-base-other IN FRAME Dialog-Frame
DO:
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-base-road-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-road-tax Dialog-Frame
ON ENTRY OF varsum-base-road-tax IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-road-tax Dialog-Frame
ON LEAVE OF varsum-base-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame {&frame-name} varsum-base-road-tax.
  assign
    varprice-base-road-tax = varsum-base-road-tax / varfact-qnty
    varprice-rubl-road-tax = varprice-base-road-tax * varbase-rate / varbase-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-road-tax = varmem-price-rubl-road-tax
    varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
    varprice-base-road-tax = varmem-price-base-road-tax
    varsum-base-road-tax   = varmem-sum-base-road-tax
    varprice-cli-road-tax  = varmem-price-cli-road-tax
    varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .

  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-road-tax Dialog-Frame
ON return OF varsum-base-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-base-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-slt Dialog-Frame
ON ENTRY OF varsum-base-slt IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-slt Dialog-Frame
ON LEAVE OF varsum-base-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
assign
   varmem-price-rubl-slt = varprice-rubl-slt
   varmem-sum-rubl-slt   = varsum-rubl-slt
   varmem-price-base-slt = varprice-base-slt
   varmem-sum-base-slt   = varsum-base-slt
   varmem-price-cli-slt  = varprice-cli-slt
   varmem-sum-cli-slt    = varsum-cli-slt
   varmem-slt-pc         = varslt-pc
   .
assign frame {&frame-name}
   varsum-base-slt.
assign
  varprice-base-slt = varsum-base-slt / varfact-qnty
  varprice-rubl-slt = varprice-base-slt * varbase-rate / varbase-scale
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
  varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
  varslt-pc         = (varsum-base-slt / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt)) * 100
  .
run chg-slt-pc in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при изменении процента НП." skip
          return-value skip
          error-status:get-message(1)
  view-as alert-box.
  assign
   varprice-rubl-slt = varmem-price-rubl-slt
   varsum-rubl-slt   = varmem-sum-rubl-slt
   varprice-base-slt = varmem-price-base-slt
   varsum-base-slt   = varmem-sum-base-slt
   varprice-cli-slt  = varmem-price-cli-slt
   varsum-cli-slt    = varmem-sum-cli-slt
   varslt-pc         = varmem-slt-pc
   .
  display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame {&frame-name}.
end.
display varslt-pc with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-slt Dialog-Frame
ON return OF varsum-base-slt IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-base-transport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-transport Dialog-Frame
ON ENTRY OF varsum-base-transport IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-transport Dialog-Frame
ON LEAVE OF varsum-base-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport   like varsum-rubl-transport   no-undo.
define variable varmem-price-base-transport like varprice-base-transport no-undo.
define variable varmem-sum-base-transport   like varsum-base-transport   no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
  .
  assign frame {&frame-name} varsum-base-transport.
  assign
    varprice-base-transport = varsum-base-transport / varfact-qnty
    varprice-rubl-transport = varprice-base-transport * varbase-rate / varbase-scale
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-transport = varmem-price-rubl-transport
    varsum-rubl-transport   = varmem-sum-rubl-transport
    varprice-base-transport = varmem-price-base-transport
    varsum-base-transport   = varmem-sum-base-transport
    .

  end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-transport Dialog-Frame
ON return OF varsum-base-transport IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-base-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-vat Dialog-Frame
ON ENTRY OF varsum-base-vat IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-vat Dialog-Frame
ON LEAVE OF varsum-base-vat IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
if (input frame {&frame-name} varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100 < 0   or
   (input frame {&frame-name} varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100 > 100 then do:
   message "При такой сумовой компоненте НДС получится неверный процент НДС: " (input frame {&frame-name} varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-sum-base-vat in this-procedure.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-base-vat Dialog-Frame
ON return OF varsum-base-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli Dialog-Frame
ON LEAVE OF varsum-cli IN FRAME Dialog-Frame
DO:
define variable varmemsum-cli    like varsum-cli   no-undo.
DEFINE VARIABLE varmem-price-cli LIKE varprice-cli NO-UNDO.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmemsum-cli   = varsum-cli
    varmem-price-cli = varprice-cli.
  assign frame {&frame-name} varsum-cli.
  assign varprice-cli = varsum-cli / varfact-qnty * varcli-base-rate -
                        varprice-cli-road-tax -
                        (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) -
                        (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0).
  display varprice-cli with frame {&frame-name}.

  IF varexcheqrubl = YES THEN DO:
    RUN proc-calc-rubl-cli IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE "Ошибка при пересчете части в {&abbr_rublyah}." SKIP
              RETURN-VALUE
      VIEW-AS ALERT-BOX ERROR.
      ASSIGN
        varsum-cli   = varmemsum-cli
        varprice-cli = varmem-price-cli.
    END.
  END.

  if varexcheqbase = yes then do:
    run proc-calc-baseeqcli in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при пересчете части в базовой валюте." skip
                   return-value
      view-as alert-box error.
      assign
         varsum-cli = varmemsum-cli
         varprice-cli = varmem-price-cli.
    end.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli Dialog-Frame
ON return OF varsum-cli IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-cli-road-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-road-tax Dialog-Frame
ON ENTRY OF varsum-cli-road-tax IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-road-tax Dialog-Frame
ON LEAVE OF varsum-cli-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame {&frame-name} varsum-cli-road-tax.
  assign
    varprice-cli-road-tax  = varsum-cli-road-tax / varfact-qnty * varcli-base-rate
    varprice-rubl-road-tax = varprice-cli-road-tax / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-road-tax = varmem-price-rubl-road-tax
    varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
    varprice-base-road-tax = varmem-price-base-road-tax
    varsum-base-road-tax   = varmem-sum-base-road-tax
    varprice-cli-road-tax  = varmem-price-cli-road-tax
    varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .

  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-road-tax Dialog-Frame
ON return OF varsum-cli-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-cli-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-slt Dialog-Frame
ON ENTRY OF varsum-cli-slt IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-slt Dialog-Frame
ON LEAVE OF varsum-cli-slt IN FRAME Dialog-Frame
DO:
    define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
    define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
    define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
    define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
    define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
    define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
    define variable varmem-slt-pc         like ub.doc-line.vat-pc no-undo.
    if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    assign
       varmem-price-rubl-slt = varprice-rubl-slt
       varmem-sum-rubl-slt   = varsum-rubl-slt
       varmem-price-base-slt = varprice-base-slt
       varmem-sum-base-slt   = varsum-base-slt
       varmem-price-cli-slt  = varprice-cli-slt
       varmem-sum-cli-slt    = varsum-cli-slt
       varmem-slt-pc         = varslt-pc
       .
    assign frame {&frame-name}
       varsum-cli-slt.
    assign
      varprice-cli-slt  = varsum-cli-slt / varfact-qnty * varcli-base-rate
      varprice-rubl-slt = varprice-cli-slt / varcli-base-rate * varexch-rate / varexch-scale
      varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
      varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
      varsum-base-slt   = varprice-base-slt * varfact-qnty
      varslt-pc         = varsum-cli-slt / (varsum-cli - varsum-cli-slt) * 100
      .
    run chg-slt-pc in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при изменении процента НП." skip
              return-value skip
              error-status:get-message(1)
      view-as alert-box.
      assign
       varprice-rubl-slt = varmem-price-rubl-slt
       varsum-rubl-slt   = varmem-sum-rubl-slt
       varprice-base-slt = varmem-price-base-slt
       varsum-base-slt   = varmem-sum-base-slt
       varprice-cli-slt  = varmem-price-cli-slt
       varsum-cli-slt    = varmem-sum-cli-slt
       varslt-pc         = varmem-slt-pc
       .
      display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame {&frame-name}.
    end.
    display varslt-pc with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-slt Dialog-Frame
ON return OF varsum-cli-slt IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-cli-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-vat Dialog-Frame
ON ENTRY OF varsum-cli-vat IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-vat Dialog-Frame
ON LEAVE OF varsum-cli-vat IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  if (input frame {&frame-name} varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-vat)) * 100 < 0   or
     (input frame {&frame-name} varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-vat)) * 100 > 100 then do:
     message "При такой сумовой компоненте НДС получится неверный процент НДС: " (input frame {&frame-name} varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-vat)) * 100 " ."
     view-as alert-box.
     return no-apply.
  end.
  run calc-sum-cli-vat in this-procedure.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-cli-vat Dialog-Frame
ON return OF varsum-cli-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl Dialog-Frame
ON LEAVE OF varsum-rubl IN FRAME Dialog-Frame
DO:

define variable varmemsum-rubl like varsum-rubl no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign varmemsum-rubl = varsum-rubl.
  assign frame {&frame-name} varsum-rubl.
  if varbaseeqrubl = yes then do:
    run proc-calc-base-rubl in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при пересчете валютной части." skip
                   return-value
      view-as alert-box error.
      assign
         varsum-rubl = varmemsum-rubl.
    end.
  end.
  assign varprice-rubl = varsum-rubl / varfact-qnty.
  display varprice-rubl with frame {&frame-name}.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl Dialog-Frame
ON return OF varsum-rubl IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-rubl-other
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-other Dialog-Frame
ON ENTRY OF varsum-rubl-other IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-other Dialog-Frame
ON LEAVE OF varsum-rubl-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other  like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other    like varsum-rubl-other   no-undo.
define variable varmem-price-base-other  like varprice-base-other no-undo.
define variable varmem-sum-base-other    like varsum-base-other   no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other
  .
  assign frame {&frame-name} varsum-rubl-other.
  assign
    varprice-rubl-other = varsum-rubl-other   / varfact-qnty
    varprice-base-other = varprice-rubl-other / varbase-rate * varbase-scale
    varsum-base-other   = varprice-base-other * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-other = varmem-price-rubl-other
      varsum-rubl-other   = varmem-sum-rubl-other
      varprice-base-other = varmem-price-base-other
      varsum-base-other   = varmem-sum-base-other
    .
  end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-other Dialog-Frame
ON return OF varsum-rubl-other IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-rubl-road-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-road-tax Dialog-Frame
ON ENTRY OF varsum-rubl-road-tax IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-road-tax Dialog-Frame
ON LEAVE OF varsum-rubl-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax  like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax    like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax  like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax    like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax   like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax     like varsum-cli-road-tax    no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame {&frame-name} varsum-rubl-road-tax.
  assign
    varprice-rubl-road-tax = varsum-rubl-road-tax   / varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-road-tax = varmem-price-rubl-road-tax
      varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
      varprice-base-road-tax = varmem-price-base-road-tax
      varsum-base-road-tax   = varmem-sum-base-road-tax
      varprice-cli-road-tax  = varmem-price-cli-road-tax
      varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-road-tax Dialog-Frame
ON return OF varsum-rubl-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-rubl-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-slt Dialog-Frame
ON ENTRY OF varsum-rubl-slt IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-slt Dialog-Frame
ON LEAVE OF varsum-rubl-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-slt = varprice-rubl-slt
    varmem-sum-rubl-slt   = varsum-rubl-slt
    varmem-price-base-slt = varprice-base-slt
    varmem-sum-base-slt   = varsum-base-slt
    varmem-price-cli-slt  = varprice-cli-slt
    varmem-sum-cli-slt    = varsum-cli-slt
    varmem-slt-pc         = varslt-pc
   .

  assign frame {&frame-name}
    varsum-rubl-slt.
  assign
    varprice-rubl-slt = varsum-rubl-slt / varfact-qnty
    varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
    varslt-pc         = (varsum-rubl-slt / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt)) * 100
  .
  run chg-slt-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НП." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box.
    assign
     varprice-rubl-slt = varmem-price-rubl-slt
     varsum-rubl-slt   = varmem-sum-rubl-slt
     varprice-base-slt = varmem-price-base-slt
     varsum-base-slt   = varmem-sum-base-slt
     varprice-cli-slt  = varmem-price-cli-slt
     varsum-cli-slt    = varmem-sum-cli-slt
     varslt-pc         = varmem-slt-pc
     .
    display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame {&frame-name}.
  end.
  display varslt-pc with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-slt Dialog-Frame
ON return OF varsum-rubl-slt IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-rubl-transport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-transport Dialog-Frame
ON ENTRY OF varsum-rubl-transport IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-transport Dialog-Frame
ON LEAVE OF varsum-rubl-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport  like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport    like varsum-rubl-transport   no-undo.
define variable varmem-price-base-transport  like varprice-base-transport no-undo.
define variable varmem-sum-base-transport    like varsum-base-transport   no-undo.

if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
  .
  assign frame {&frame-name} varsum-rubl-transport.
  assign
    varprice-rubl-transport = varsum-rubl-transport   / varfact-qnty
    varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
    varsum-base-transport   = varprice-base-transport * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-transport = varmem-price-rubl-transport
      varsum-rubl-transport   = varmem-sum-rubl-transport
      varprice-base-transport = varmem-price-base-transport
      varsum-base-transport   = varmem-sum-base-transport
    .
  end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-transport Dialog-Frame
ON return OF varsum-rubl-transport IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsum-rubl-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-vat Dialog-Frame
ON ENTRY OF varsum-rubl-vat IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-vat Dialog-Frame
ON LEAVE OF varsum-rubl-vat IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  if (input frame {&frame-name} varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100 < 0   or
     (input frame {&frame-name} varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100 > 100 then do:
     message "При такой сумовой компоненте НДС получится неверный процент НДС: " (input frame {&frame-name} varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100 < 0 " ."
     view-as alert-box.
     return no-apply.
  end.
  run calc-sum-rubl-vat in this-procedure.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsum-rubl-vat Dialog-Frame
ON return OF varsum-rubl-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varvat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varvat-pc Dialog-Frame
ON ENTRY OF varvat-pc IN FRAME Dialog-Frame
DO:
  {&rate-correct}
  {&rate-exch-correct}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varvat-pc Dialog-Frame
ON LEAVE OF varvat-pc IN FRAME Dialog-Frame
DO:
if input frame {&frame-name} {&self-name} <> round ({&self-name}, 2) then do:
  define variable varmem-vat-pc like ub.doc-line.vat-pc no-undo.
  assign frame {&frame-name}
     varvat-pc.
  run chg-vat-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НДС." skip
                  return-value skip
                  error-status:get-message(1)
    view-as alert-box.
    assign
      varvat-pc = varmem-vat-pc.
    display varvat-pc with frame {&frame-name}.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varvat-pc Dialog-Frame
ON return OF varvat-pc IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
run start-state in this-procedure no-error.
if error-status:error then do:
  message
  "Ошибка при начальной установке сумм." skip
  return-value skip
  error-status:get-message(1)
  view-as alert-box error.
  return error.
end.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  if parmode <> "part":u then do:
    hide rect-part varincome-in-code varin-code varpart-code in frame {&frame-name}.
  end.
  find first bf_clients where bf_clients.obj-type = parobj-type and
                              bf_clients.obj-code = parobj-code no-lock no-error.
  if not available bf_clients then do:
    message
      "Не найден объект " parobj-type " " parobj-code " ." view-as alert-box error.
    undo, return error.
  end.
  { gbl/hostcode.i bf_clients.obj-type bf_clients.obj-code varhost-code no-error}
  if error-status:error then do:
    message "Ошибка при поиске фирмы для объекта: " bf_clients.obj-type " " bf_clients.obj-code " ." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    undo, return error.
  end.
  { gbl/basecode.i varhost-code varbase-code no-error }
  if error-status:error then do:
    message "Ошибка при поиске базовой валюты для фирмы: " varhost-code " ." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    undo, return error.
  end.
  assign
    varexch-code = parexch-code.
  if varbase-code <> 0 then do:
    assign
      varbaseeqrubl = no.
  end.
  else do:
    assign
      varbaseeqrubl = yes.
  end.
  if varexch-code = 0 then do:
    assign
      varexcheqrubl = yes.
  end.
  else do:
    assign
      varexcheqrubl = no.
  end.
  if varexch-code = varbase-code then do:
    assign
      varexcheqbase = yes.
  end.
  else do:
    assign
      varexcheqbase = no.
  end.
  { gbl/exchrate.i varbase-code today vartemp-rate vartemp-scale varcur-base-name }
  { gbl/exchrate.i varexch-code today vartemp-rate vartemp-scale varcur-cli-name }
  display varcur-base-name varcur-cli-name with frame {&frame-name}.
  run tax-name in this-procedure ({&road-tax}, output vartitle-road-tax) no-error.
  if error-status:error then do:
    message
      "Ошибка при определении названия налога." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box.
      undo, return error.
  end.
  assign
  v-rubli-firstshift = "{&abbr_rubli_firstshift}"
  .

  ASSIGN
    varpurch-code-name:LIST-ITEMS IN FRAME {&FRAME-NAME} = varno-change + ",":u + {&purchase-input-codes-full}
    varpurch-code-name = varno-change.
  DISPLAY varpurch-code-name WITH FRAME {&FRAME-NAME}.
if paris-road-tax = no then do:
    hide rect-road-tax vartitle-road-tax
    varsum-base-road-tax varprice-base-road-tax varsum-rubl-road-tax varprice-rubl-road-tax varsum-cli-road-tax varprice-cli-road-tax
    varold-sum-base-road-tax varold-price-base-road-tax varold-sum-rubl-road-tax varold-price-rubl-road-tax varold-sum-cli-road-tax varold-price-cli-road-tax
    in frame {&frame-name}.
  end.
  if varexcheqrubl = yes then do:
    disable varexch-rate varexch-scale varprice-rubl varsum-rubl b-calc-exch-rate b-calc-cli-t-rubl b-calc-rubl-t-cli b-cur-exch-rate
            varprice-rubl-vat varsum-rubl-vat varprice-rubl-slt varsum-rubl-slt varprice-rubl-road-tax varsum-rubl-road-tax
    with frame {&frame-name}.
  end.
  if varexcheqbase = yes or varbaseeqrubl = yes then do:
    disable varbase-rate varbase-scale varprice-base varsum-base b-calc-rate b-calc-base-t-rubl b-calc-rubl-t-base b-cur-rate
            varprice-base-vat varsum-base-vat varprice-base-slt varsum-base-slt varprice-base-road-tax varsum-base-road-tax
            varprice-base-transport varsum-base-transport varprice-base-other varsum-base-other
    with frame {&frame-name}.
  end.
  if varvat-type = {&without-vat} then do:
    disable varvat-pc varprice-cli-vat varsum-cli-vat varprice-rubl-vat varsum-rubl-vat varprice-base-vat varsum-base-vat with frame {&frame-name}.
  end.
  if varslt-type = {&without-slt} then do:
    disable varslt-pc varprice-cli-slt varsum-cli-slt varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt with frame {&frame-name}.
  end.
  IF NOT (parcontract-code = 0 OR
          parcontract-code = ?    )THEN DO:
    DISABLE varpurch-code-name WITH FRAME {&FRAME-NAME}.
  END.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-price-base-vat Dialog-Frame
PROCEDURE calc-price-base-vat :
assign frame {&frame-name}
   varprice-base-vat.
assign
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varprice-rubl-vat = varprice-base-vat * varbase-rate / varbase-scale
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
  varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
  varvat-pc         = (varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100
  .
display varsum-base-vat varprice-rubl-vat varsum-rubl-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-price-cli-vat Dialog-Frame
PROCEDURE calc-price-cli-vat :
assign frame {&frame-name}
   varprice-cli-vat.
assign
  varsum-cli-vat    = varprice-cli-vat * varfact-qnty / varcli-base-rate
  varprice-rubl-vat = varprice-cli-vat / varcli-base-rate * varexch-rate / varexch-scale
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varvat-pc         = varprice-cli-vat / (varprice-cli + (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) + (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat) * 100
  .
display varsum-cli-vat varprice-rubl-vat varsum-rubl-vat varprice-base-vat varsum-base-vat varvat-pc with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-price-rubl-vat Dialog-Frame
PROCEDURE calc-price-rubl-vat :
assign frame {&frame-name}
   varprice-rubl-vat.
assign
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
  varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
  varvat-pc         = (varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100
  .
display varsum-rubl-vat varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-sum-base-vat Dialog-Frame
PROCEDURE calc-sum-base-vat :
assign frame {&frame-name}
   varsum-base-vat.
assign
  varprice-base-vat = varprice-base-vat / varfact-qnty
  varprice-rubl-vat = varprice-base-vat * varbase-rate / varbase-scale
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
  varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
  varvat-pc         = (varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100
  .
display varprice-base-vat varprice-rubl-vat varsum-rubl-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-sum-cli-vat Dialog-Frame
PROCEDURE calc-sum-cli-vat :
assign frame {&frame-name}
   varsum-cli-vat.
  assign
   varprice-cli-vat  = varsum-cli-vat / varfact-qnty * varcli-base-rate
   varprice-rubl-vat = varprice-cli-vat / varcli-base-rate * varexch-rate / varexch-scale
   varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
   varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
   varsum-base-vat   = varprice-base-vat * varfact-qnty
   varvat-pc         = varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-slt - varsum-cli-vat) * 100
  .
  display varprice-cli-vat varprice-rubl-vat varsum-rubl-vat varprice-base-vat varsum-base-vat varvat-pc with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-sum-rubl-vat Dialog-Frame
PROCEDURE calc-sum-rubl-vat :
assign frame {&frame-name}
   varsum-rubl-vat.
  assign
   varprice-rubl-vat = varsum-rubl-vat / varfact-qnty
   varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
   varsum-base-vat   = varsum-rubl-vat / varbase-rate * varbase-scale
   varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
   varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
   varvat-pc         = (varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100
  .
  display varprice-rubl-vat varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-abs Dialog-Frame
PROCEDURE chg-abs :
assign
  varroad-tax-rubl  = varprice-rubl-road-tax
  vartransport-rubl = varprice-rubl-transport
  varother-rubl     = varprice-rubl-other
  varroad-tax-base  = varprice-base-road-tax
  vartransport-base = varprice-base-transport
  varother-base     = varprice-base-other
  varroad-tax-cli   = varprice-cli-road-tax

.
{ str/in-vatp.i calc-parts var }
assign
  varprice-rubl-slt = slt-rubl-loc
  varprice-base-slt = slt-base-loc
  varprice-cli-slt  = slt-cli-loc
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varsum-base-slt   = varprice-base-slt * varfact-qnty
  varsum-cli-slt    = varprice-cli-slt / varcli-base-rate * varfact-qnty
  varprice-rubl-vat = vat-rubl-loc
  varprice-base-vat = vat-base-loc
  varprice-cli-vat  = vat-cli-loc
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varsum-cli-vat    = varprice-cli-vat / varcli-base-rate * varfact-qnty.
display
varprice-rubl-slt varprice-base-slt varsum-rubl-slt varsum-base-slt varprice-cli-slt varsum-cli-slt
varprice-rubl-vat varprice-base-vat varsum-rubl-vat varsum-base-vat varprice-cli-vat varsum-cli-vat
with frame {&frame-name}.
run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
if error-status:error then do:
   message "Ошибка при пересчете значений в валюте клиента." skip
           return-value skip
           error-status:get-message(1) skip
   view-as alert-box error.
   return error.
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-slt-pc Dialog-Frame
PROCEDURE chg-slt-pc :
assign
  varroad-tax-rubl  = varprice-rubl-road-tax
  vartransport-rubl = varprice-rubl-transport
  varother-rubl     = varprice-rubl-other
  varroad-tax-base  = varprice-base-road-tax
  vartransport-base = varprice-base-transport
  varother-base     = varprice-base-other
  varroad-tax-cli   = varprice-cli-road-tax
.
{ str/in-vatp.i calc-parts var }
if varslt-type <> {&inc-slt} then do:
  run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
     message "Ошибка при пересчете значений в валюте клиента." skip
             return-value skip
             error-status:get-message(1) skip
     view-as alert-box error.
     return error.
  end.
end.
{ str/in-vatp.i calc-parts var }
assign
  varprice-rubl-slt = slt-rubl-loc
  varprice-base-slt = slt-base-loc
  varprice-cli-slt  = slt-cli-loc
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varsum-base-slt   = varprice-base-slt * varfact-qnty
  varsum-cli-slt    = varprice-cli-slt / varcli-base-rate * varfact-qnty
  varprice-rubl-vat = vat-rubl-loc
  varprice-base-vat = vat-base-loc
  varprice-cli-vat  = vat-cli-loc
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varsum-cli-vat    = varprice-cli-vat / varcli-base-rate * varfact-qnty.
display
varprice-rubl-slt varprice-base-slt varprice-cli-slt varsum-rubl-slt varsum-base-slt varsum-cli-slt
varprice-rubl-vat varprice-base-vat varprice-cli-vat varsum-rubl-vat varsum-base-vat varsum-cli-vat
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-vat-pc Dialog-Frame
PROCEDURE chg-vat-pc :
assign
  varroad-tax-rubl  = varprice-rubl-road-tax
  vartransport-rubl = varprice-rubl-transport
  varother-rubl     = varprice-rubl-other
  varroad-tax-base  = varprice-base-road-tax
  vartransport-base = varprice-base-transport
  varother-base     = varprice-base-other
  varroad-tax-cli   = varprice-cli-road-tax
.
{ str/in-vatp.i calc-parts var }
assign
  varprice-rubl-vat = vat-rubl-loc
  varprice-base-vat = vat-base-loc
  varprice-cli-vat  = vat-cli-loc
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varsum-cli-vat    = varprice-cli-vat  / varcli-base-rate * varfact-qnty.
display varprice-rubl-vat varprice-base-vat varprice-cli-vat
        varsum-rubl-vat   varsum-base-vat   varsum-cli-vat   with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY varobj-type varobj-code varobj-name varsupp-type varsupp-code
          varsupp-name varfact-qnty varartic varprod-type varprod-code
          vargds-name varvat-type varold-vat-pc varvat-pc varincome-in-code
          varin-code varpart-code varslt-type varold-slt-pc varslt-pc
          varcur-base-name varcur-base-rate varcur-base-scale varold-base-rate
          varbase-rate varbase-scale varcur-cli-name varcur-exch-rate
          varcur-exch-scale varold-exch-rate varexch-rate varexch-scale
          varcli-base-rate varold-price-cli varold-sum-cli varold-price-rubl
          varold-sum-rubl varold-price-base varold-sum-base varsum-rubl
          varprice-base varsum-base varprice-cli varsum-cli varprice-rubl
          varold-price-base-vat varold-sum-base-vat varold-price-cli-vat
          varold-sum-cli-vat varold-price-rubl-vat varold-sum-rubl-vat
          varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat
          varprice-rubl-vat varsum-rubl-vat varold-price-base-slt
          varold-sum-base-slt varold-price-cli-slt varold-sum-cli-slt
          varold-price-rubl-slt varold-sum-rubl-slt varprice-base-slt
          varsum-base-slt varprice-cli-slt varsum-cli-slt varprice-rubl-slt
          varsum-rubl-slt varold-price-base-road-tax varold-sum-base-road-tax
          varold-price-cli-road-tax varold-sum-cli-road-tax
          varold-price-rubl-road-tax varold-sum-rubl-road-tax
          varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax
          varsum-cli-road-tax varprice-rubl-road-tax varsum-rubl-road-tax
          varold-price-base-transport varold-sum-base-transport
          varold-price-rubl-transport varold-sum-rubl-transport
          varold-purch-code-name varprice-base-transport varsum-base-transport
          varprice-rubl-transport varsum-rubl-transport varpurch-code-name
          varold-price-base-other varold-sum-base-other varold-price-rubl-other
          varold-sum-rubl-other varprice-base-other varsum-base-other
          varprice-rubl-other varsum-rubl-other v-rubli-firstshift
          vartitle-road-tax
      WITH FRAME Dialog-Frame.
  ENABLE b-save RECT-goods RECT-transport RECT-object RECT-other RECT-road-tax
         RECT-price RECT-slt RECT-vat RECT-1 b-cancel b-help varvat-pc
         varslt-pc b-cur-rate varbase-rate varbase-scale b-calc-rate
         b-cur-exch-rate varexch-rate varexch-scale b-calc-exch-rate
         b-calc-cli-t-rubl b-calc-rubl-t-cli b-calc-rubl-t-base
         b-calc-base-t-rubl varsum-rubl varprice-base varsum-base varprice-cli
         varsum-cli varprice-rubl varprice-base-vat varsum-base-vat
         varprice-cli-vat varsum-cli-vat varprice-rubl-vat varsum-rubl-vat
         varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt
         varprice-rubl-slt varsum-rubl-slt varprice-base-road-tax
         varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax
         varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-transport
         varsum-base-transport varprice-rubl-transport varsum-rubl-transport
         varpurch-code-name varprice-base-other varsum-base-other
         varprice-rubl-other varsum-rubl-other
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-base-rubl Dialog-Frame
PROCEDURE proc-calc-base-rubl :
assign
    varprice-base           = varprice-rubl           / varbase-rate * varbase-scale
    varsum-base             = varprice-base           * varfact-qnty
    varprice-base-road-tax  = varprice-rubl-road-tax  / varbase-rate * varbase-scale
    varsum-base-road-tax    = varprice-base-road-tax  * varfact-qnty
    varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
    varsum-base-transport   = varprice-base-transport * varfact-qnty
    varprice-base-other     = varprice-rubl-other     / varbase-rate * varbase-scale
    varsum-base-other       = varprice-base-other     * varfact-qnty.
  /*В системе на данный момент все считается исходя из процента НДС и процента НП. Поэтому пересчитываем,основываясь на этот процент*/
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
  .
  { str/in-vatp.i calc-parts var }
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty.
  display varprice-base           varsum-base
          varprice-base-vat       varsum-base-vat varprice-rubl-vat varsum-rubl-vat
          varprice-base-slt       varsum-base-slt varprice-rubl-slt varsum-rubl-slt
          varprice-base-road-tax  when paris-road-tax varsum-base-road-tax when paris-road-tax
          varprice-base-transport varsum-base-transport
          varprice-base-other     varsum-base-other
  with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-baseeqcli Dialog-Frame
PROCEDURE proc-calc-baseeqcli :
assign
    varprice-base           = (varprice-cli + varprice-cli-road-tax + (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) + (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0)) / varcli-base-rate + varprice-base-transport + varprice-base-other
    varsum-base             = varprice-base           * varfact-qnty
    varprice-base-road-tax  = varprice-cli-road-tax   * varcli-base-rate
    varsum-base-road-tax    = varprice-base-road-tax  * varfact-qnty
   .
  /*В системе на данный момент все считается исходя из процента НДС и процента НП. Поэтому пересчитываем,основываясь на этот процент*/
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
  { str/in-vatp.i calc-parts var }
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-base           varsum-base
          varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-base-road-tax  when paris-road-tax
          varsum-base-road-tax    when paris-road-tax
          varprice-base-transport varsum-base-transport
          varprice-base-other     varsum-base-other
  with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-cli-rubl Dialog-Frame
PROCEDURE proc-calc-cli-rubl :
assign
    varprice-cli            = (varprice-rubl - varprice-rubl-transport - varprice-rubl-other - varprice-rubl-road-tax - (if varvat-type <> {&inc-vat} then varprice-rubl-vat else 0) - (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0)) / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli              = (varprice-rubl - varprice-rubl-transport - varprice-rubl-other - varprice-rubl-road-tax - (if varvat-type <> {&inc-vat} then varprice-rubl-vat else 0) - (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0)) / varexch-rate * varexch-scale * varfact-qnty
    varprice-cli-road-tax   = varprice-cli-road-tax   / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax     = varprice-cli-road-tax   / varexch-rate * varexch-scale * varfact-qnty
   .
  /*В системе на данный момент все считается исходя из процента НДС и процента НП. Поэтому пересчитываем,основываясь на этот процент*/
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
  { str/in-vatp.i calc-parts var }
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-cli            varsum-cli
          varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-cli-road-tax  when paris-road-tax
          varsum-cli-road-tax    when paris-road-tax
  with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-exch-rate Dialog-Frame
PROCEDURE proc-calc-exch-rate :
assign
     varexch-scale = 1
     varexch-rate  = (varprice-rubl - varprice-rubl-road-tax -
                      (if varvat-type <> {&inc-vat} then varprice-rubl-vat else 0) -
                      (if varslt-type <> {&inc-slt} then varprice-rubl-slt else 0)
                     )
                     / (varprice-cli / varcli-base-rate).
  display varexch-scale varexch-rate with frame {&frame-name}.
  assign
     varprice-cli-road-tax   = varprice-rubl-road-tax  / varexch-rate * varexch-scale * varcli-base-rate
     varsum-cli-road-tax     = varprice-rubl-road-tax  / varexch-rate * varexch-scale * varfact-qnty
  .
  /*В системе на данный момент все считается исходя из процента НДС и процента НП.
    Поэтому пересчитываем,основываясь на этот процент*/
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
  { str/in-vatp.i calc-parts var }
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate .
  display varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-cli-road-tax   when paris-road-tax
          varsum-cli-road-tax     when paris-road-tax
  with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-rate Dialog-Frame
PROCEDURE proc-calc-rate :
assign
     varbase-scale = 1
     varbase-rate  = varprice-rubl / varprice-base.
  display varbase-scale varbase-rate with frame {&frame-name}.
  assign
     varprice-base-road-tax  = varprice-rubl-road-tax  / varbase-rate * varbase-scale
     varsum-base-road-tax    = varprice-base-road-tax  * varfact-qnty
     varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
     varsum-base-transport   = varprice-base-transport * varfact-qnty
     varprice-base-other     = varprice-rubl-other     / varbase-rate * varbase-scale
     varsum-base-other       = varprice-base-other     * varfact-qnty.
  /*В системе на данный момент все считается исходя из процента НДС и процента НП.
    Поэтому пересчитываем,основываясь на этот процент*/
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
  { str/in-vatp.i calc-parts var }
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-base-road-tax  when paris-road-tax
          varsum-base-road-tax    when paris-road-tax
          varprice-base-transport varsum-base-transport
          varprice-base-other     varsum-base-other
  with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-rubl-base Dialog-Frame
PROCEDURE proc-calc-rubl-base :
assign
    varprice-rubl           = varprice-base           * varbase-rate / varbase-scale
    varsum-rubl             = varprice-rubl           * varfact-qnty
    varprice-rubl-road-tax  = varprice-base-road-tax  * varbase-rate / varbase-scale
    varsum-rubl-road-tax    = varprice-rubl-road-tax  * varfact-qnty
    varprice-rubl-transport = varprice-base-transport * varbase-rate / varbase-scale
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
    varprice-rubl-other     = varprice-base-other     * varbase-rate / varbase-scale
    varsum-rubl-other       = varprice-rubl-other     * varfact-qnty.
  /*В системе на данный момент все считается исходя из процента НДС и процента НП. Поэтому пересчитываем,основываясь на этот процент*/
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
  .
  { str/in-vatp.i calc-parts var }
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty.
  display varprice-rubl           varsum-rubl
          varprice-base-vat       varsum-base-vat varprice-rubl-vat varsum-rubl-vat
          varprice-base-slt       varsum-base-slt varprice-rubl-slt varsum-rubl-slt
          varprice-rubl-road-tax  when paris-road-tax varsum-rubl-road-tax when paris-road-tax
          varprice-rubl-transport varsum-rubl-transport
          varprice-rubl-other     varsum-rubl-other
  with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc-rubl-cli Dialog-Frame
PROCEDURE proc-calc-rubl-cli :
assign
    varprice-rubl           = (varprice-cli + varprice-cli-road-tax + (if varvat-type <> {&inc-vat} then varprice-cli-vat else 0) + (if varslt-type <> {&inc-slt} then varprice-cli-slt else 0)) / varcli-base-rate * varexch-rate / varexch-scale + varprice-rubl-transport + varprice-rubl-other
    varsum-rubl             = varprice-rubl           * varfact-qnty
    varprice-rubl-road-tax  = varprice-cli-road-tax / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-road-tax    = varprice-rubl-road-tax  * varfact-qnty
  .
  /*В системе на данный момент все считается исходя из процента НДС и процента НП. Поэтому пересчитываем,основываясь на этот процент*/
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
.
  { str/in-vatp.i calc-parts var }
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-rubl           varsum-rubl
          varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-rubl-road-tax  when paris-road-tax
          varsum-rubl-road-tax    when paris-road-tax
          varprice-rubl-transport varsum-rubl-transport
          varprice-rubl-other     varsum-rubl-other
  with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rate-correct Dialog-Frame
PROCEDURE rate-correct :
define output parameter parrate-correct as logical no-undo.
if varprice-rubl  = varprice-base * varbase-rate / varbase-scale or
   varprice-base = varprice-rubl / varbase-rate * varbase-scale or
   varbase-rate = varprice-rubl / varprice-base *  varbase-scale then do:
   assign parrate-correct = true.
end.
else do:
  assign parrate-correct = false.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rate-exch-correct Dialog-Frame
PROCEDURE rate-exch-correct :
define output parameter parrate-exch-correct as logical no-undo.
if (varprice-rubl - varprice-rubl-road-tax - varprice-rubl-transport - varprice-rubl-other - (if varvat-type <> {&inc-vat} then varprice-rubl-vat else 0) - (if varslt-type <> {&inc-slt} then varprice-rubl-slt else 0)) = varprice-cli / varcli-base-rate * varexch-rate / varexch-scale         or
   (varprice-cli / varcli-base-rate)  = (varprice-rubl - varprice-rubl-road-tax - varprice-rubl-transport - varprice-rubl-other - (if varvat-type <> {&inc-vat} then varprice-rubl-vat else 0) - (if varslt-type <> {&inc-slt} then varprice-rubl-slt else 0)) / varexch-rate * varexch-scale      or
   (varexch-rate / varexch-scale)     = (varprice-rubl - varprice-rubl-road-tax - varprice-rubl-transport - varprice-rubl-other - (if varvat-type <> {&inc-vat} then varprice-rubl-vat else 0) - (if varslt-type <> {&inc-slt} then varprice-rubl-slt else 0)) / (varprice-cli / varcli-base-rate) then do:
   assign parrate-exch-correct = true.
end.
else do:
  assign parrate-exch-correct = false.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE start-state Dialog-Frame
PROCEDURE start-state :
define buffer bf-supp_parts   for ub.parts.
define buffer bf-supp_clients for ub.clients.
define variable varhost-code        like ub.clients.obj-code no-undo.
define variable varhave-parts       as   logical             no-undo.
define variable varno-recalc-vat-pc like ub.parts.vat-pc     no-undo.
define variable varno-recalc-slt-pc like ub.parts.slt-pc     no-undo.
define variable varcount            as   integer             no-undo.

do on error undo, return error return-value :
assign
  varno-recalc-vat-pc = ?
  varno-recalc-slt-pc = ?.
find first bf_goods where bf_goods.gds-code = pargds-code no-lock no-error.
if not available bf_goods then do:
  return error substitute ("Не найден товар с внутренним кодом &1.", pargds-code).
end.
assign
  varartic     = bf_goods.artic
  varprod-type = bf_goods.prod-type
  varprod-code = bf_goods.prod-code
  vargds-name  = bf_goods.gds-name.
find first bf-cur-obj_clients where bf-cur-obj_clients.obj-type = parobj-type and
                                    bf-cur-obj_clients.obj-code = parobj-code no-lock no-error.
if not available bf-cur-obj_clients then do:
  return error substitute ("Не найден объект &1 &2.", parobj-type, parobj-code).
end.
if bf-cur-obj_clients.obj-type <> {&shop}  and
   bf-cur-obj_clients.obj-type <> {&stock} then do:
  return error substitute ("Объект &1 &2 не является складом или магазином.", bf-cur-obj_clients.obj-type, bf-cur-obj_clients.obj-code).
end.
{ gbl/hostcode.i bf-cur-obj_clients.obj-type bf-cur-obj_clients.obj-code varhost-code }
assign
  varobj-type = bf-cur-obj_clients.obj-type
  varobj-code = bf-cur-obj_clients.obj-code
  varobj-name = bf-cur-obj_clients.obj-name.
find first bf-supp_clients where bf-supp_clients.obj-type = parcli-type and
                                 bf-supp_clients.obj-code = parcli-code no-lock no-error.
if not available bf-supp_clients then do:
  return error substitute ("Не найден контрагент &1 &2.", parcli-type, parcli-code).
end.
assign
  varsupp-type = bf-supp_clients.obj-type
  varsupp-code = bf-supp_clients.obj-code
  varsupp-name = bf-supp_clients.obj-name.

if parmode = "part":u then do:
  find first bf_parts where bf_parts.obj-type  = varobj-type  and
                            bf_parts.obj-code  = varobj-code  and
                            bf_parts.artic     = varartic     and
                            bf_parts.prod-type = varprod-type and
                            bf_parts.prod-code = varprod-code and
                            bf_parts.in-code   = parin-code   and
                            bf_parts.out-code  = parout-code  and
                            bf_parts.part-code = parpart-code no-lock no-error.
  if not available bf_parts then do:
    return error substitute ("Не найдена партия. Объект &1 &2. Товар &3 &4 &5. Порожд. накл. &6. Накл. &7. Код партии &8.",
                             varobj-type,
                             varobj-code,
                             varartic,
                             varprod-type,
                             varprod-code,
                             parin-code,
                             parout-code,
                             parpart-code).
  end.
  assign
    varin-code   = parin-code
    varpart-code = parpart-code
    varfact-qnty = bf_parts.fact-qnty.
  find first bf_parts-attr where bf_parts-attr.in-code   = varin-code        and
                                 bf_parts-attr.gds-code  = bf_goods.gds-code and
                                 bf_parts-attr.part-code = varpart-code      no-lock no-error.
  if available bf_parts-attr then do:
    assign
      varincome-in-code = bf_parts-attr.income-in-code.
  end.
  else do:
    assign
      varincome-in-code = varin-code.
  end.
end.
assign
  varcur-base-rate  = parbase-rate
  varcur-base-scale = parbase-scale.
assign
  varcur-exch-rate  = parexch-rate
  varcur-exch-scale = parexch-scale.
/*Заполняем суммы, цены, курсы и проценты*/
if parmode = "goods":u or parmode = "parts":u then do:
  assign
    varfact-qnty  = 0
    varhave-parts = no.
  for each tt-clcparts on error undo, return error return-value :
    delete tt-clcparts.
  end.
  assign
    varcount = 1.
  for each tt-chs-parts on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
    if varcount = 1 then do:
      assign
        varno-recalc-vat-pc = tt-chs-parts.vat-pc
        varno-recalc-slt-pc = tt-chs-parts.slt-pc.
    end.
    else do:
      if tt-chs-parts.vat-pc <> varno-recalc-vat-pc then do:
        assign
          varno-recalc-vat-pc = ?.
      end.
      if tt-chs-parts.slt-pc <> varno-recalc-slt-pc then do:
        assign
          varno-recalc-slt-pc = ?.
      end.
    end.
    create tt-clcparts.
    buffer-copy tt-chs-parts to tt-clcparts.
    assign varhave-parts = yes.
  end.
  if varhave-parts = no then do:
    return error substitute ("В свободной зоне нет партий по товару с внутренним кодом &1 от поставщика &2 &3.",
                             pargds-code,
                             parcli-type,
                             parcli-code).
  end.
  find first tt-clcparts no-error.
  if available tt-clcparts then do:
    run clcprtsl_calc-ttable in this-procedure (
                                              input no,
                                              input no,
                                              input 0,
                                              input 0 ,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input ?,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0 ) no-error.
    if error-status:error then do:
      return error substitute ("Ошибка <&1> при обсчете свободной зоны по товару.", return-value).
    end.
  end.
  else do:
    return error substitute ("По товару &1 &2 &3 нет свободной зоны от данного поставщика на объекте &4 &5. Изменять нечего.",
                             varartic,
                             varprod-type,
                             varprod-code,
                             varobj-type,
                             varobj-code).
  end.
  FIND FIRST tt-chs-parts.
  FIND FIRST tt-chs-parts-another WHERE tt-chs-parts-another.purch-code <> tt-chs-parts.purch-code NO-ERROR.
  IF AVAILABLE tt-chs-parts-another THEN DO:
    ASSIGN
      varold-purch-code-name = "разные".
  END.
  ELSE DO:
    &SCOPED-DEFINE purchase-code string(tt-chs-parts.purch-code)
    ASSIGN
      varold-purch-code-name = {&purchase-codes-name}.

  END.

end.
else do:
  for each tt-clcparts on error undo, return error return-value :
    delete tt-clcparts.
  end.
  create tt-clcparts.
  buffer-copy bf_parts to tt-clcparts.
  assign
    varno-recalc-vat-pc = tt-clcparts.vat-pc
    varno-recalc-slt-pc = tt-clcparts.slt-pc.
  run clcprtsl_calc-parts in this-procedure (
   input recid(tt-clcparts),
   input no,
   input no,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input ?,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0) no-error.
  if error-status:error then do:
    return error substitute ("Ошибка <&1> при обсчете партии по товару.", return-value).
  end.
  for each tt-allsum-line on error undo, return error return-value :
    delete tt-allsum-line.
  end.
  for each tt-allsum on error undo, return error return-value :
    create tt-allsum-line.
    buffer-copy tt-allsum to tt-allsum-line.
  end.
  &SCOPED-DEFINE purchase-code string(bf_parts.purch-code)
  ASSIGN
    varold-purch-code-name = {&purchase-codes-name}.
end.
find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = {&sum-general} no-error.
if error-status:error then do:
  return error substitute ("Не найдена запись по типу &1 для товара &2 &3 &4.", {&sum-general}, varartic, varprod-type, varprod-code).
end.
assign
   varfact-qnty                = bf_tt-allsum-line.fact-qnty
   varcli-base-rate            = parcli-base-rate
   varvat-type                 = parvat-type
   varslt-type                 = parslt-type
   varold-sum-base             = bf_tt-allsum-line.sum-dsc-base-acc
   varold-price-base           = bf_tt-allsum-line.sum-dsc-base-acc / varfact-qnty
   varold-sum-rubl             = bf_tt-allsum-line.sum-dsc-rubl-acc
   varold-price-rubl           = bf_tt-allsum-line.sum-dsc-rubl-acc / varfact-qnty
   varold-sum-cli              = bf_tt-allsum-line.sum-dsc-cli-acc
   varold-price-cli            = (bf_tt-allsum-line.sum-dsc-cli-acc - bf_tt-allsum-line.road-tax-cli-acc - (if varvat-type <> {&inc-vat} then bf_tt-allsum-line.vat-cli-acc else 0) - (if varslt-type <> {&inc-slt} then bf_tt-allsum-line.slt-cli-acc else 0)) / varfact-qnty * varcli-base-rate
   varold-base-rate            = (if varold-price-rubl / varold-price-base = ? then 1 else varold-price-rubl / varold-price-base)
   varsum-base                 = varold-sum-base
   varprice-base               = varold-price-base
   varsum-rubl                 = varold-sum-rubl
   varprice-rubl               = varold-price-rubl
   varsum-cli                  = varold-sum-cli
   varprice-cli                = varold-price-cli
   varbase-rate                = varold-base-rate
   varbase-scale               = 1
   varold-sum-base-slt         = bf_tt-allsum-line.slt-base-acc
   varold-price-base-slt       = bf_tt-allsum-line.slt-base-acc / varfact-qnty
   varold-sum-rubl-slt         = bf_tt-allsum-line.slt-rubl-acc
   varold-price-rubl-slt       = bf_tt-allsum-line.slt-rubl-acc / varfact-qnty
   varold-sum-cli-slt          = bf_tt-allsum-line.slt-cli-acc
   varold-price-cli-slt        = bf_tt-allsum-line.slt-cli-acc / varfact-qnty * varcli-base-rate
   varold-slt-pc               = (if varno-recalc-slt-pc <> ? then varno-recalc-slt-pc else (varold-sum-rubl-slt / (varold-sum-rubl - varold-sum-rubl-slt) * 100))
   varsum-base-slt             = varold-sum-base-slt
   varprice-base-slt           = varold-price-base-slt
   varsum-rubl-slt             = varold-sum-rubl-slt
   varprice-rubl-slt           = varold-price-rubl-slt
   varsum-cli-slt              = varold-sum-cli-slt
   varprice-cli-slt            = varold-price-cli-slt
   varslt-pc                   = varold-slt-pc
   varold-sum-base-vat         = bf_tt-allsum-line.vat-base-acc
   varold-price-base-vat       = bf_tt-allsum-line.vat-base-acc / varfact-qnty
   varold-sum-rubl-vat         = bf_tt-allsum-line.vat-rubl-acc
   varold-price-rubl-vat       = bf_tt-allsum-line.vat-rubl-acc / varfact-qnty
   varold-sum-cli-vat          = bf_tt-allsum-line.vat-cli-acc
   varold-price-cli-vat        = bf_tt-allsum-line.vat-cli-acc / varfact-qnty * varcli-base-rate
   varold-vat-pc               = (if varno-recalc-vat-pc <> ? then varno-recalc-vat-pc else (varold-sum-rubl-vat / (varold-sum-rubl - varold-sum-rubl-slt - varold-sum-rubl-vat) * 100))
   varsum-base-vat             = varold-sum-base-vat
   varprice-base-vat           = varold-price-base-vat
   varsum-rubl-vat             = varold-sum-rubl-vat
   varprice-rubl-vat           = varold-price-rubl-vat
   varsum-cli-vat              = varold-sum-cli-vat
   varprice-cli-vat            = varold-price-cli-vat
   varvat-pc                   = varold-vat-pc
   varold-sum-base-road-tax    = bf_tt-allsum-line.road-tax-base-acc
   varold-price-base-road-tax  = bf_tt-allsum-line.road-tax-base-acc / varfact-qnty
   varold-sum-rubl-road-tax    = bf_tt-allsum-line.road-tax-rubl-acc
   varold-price-rubl-road-tax  = bf_tt-allsum-line.road-tax-rubl-acc / varfact-qnty
   varold-sum-cli-road-tax     = bf_tt-allsum-line.road-tax-cli-acc
   varold-price-cli-road-tax   = bf_tt-allsum-line.road-tax-cli-acc / varfact-qnty * varcli-base-rate
   varsum-base-road-tax        = varold-sum-base-road-tax
   varprice-base-road-tax      = varold-price-base-road-tax
   varsum-rubl-road-tax        = varold-sum-rubl-road-tax
   varprice-rubl-road-tax      = varold-price-rubl-road-tax
   varsum-cli-road-tax         = varold-sum-cli-road-tax
   varprice-cli-road-tax       = varold-price-cli-road-tax
   varold-sum-base-transport   = bf_tt-allsum-line.transport-base-acc
   varold-price-base-transport = bf_tt-allsum-line.transport-base-acc / varfact-qnty
   varold-sum-rubl-transport   = bf_tt-allsum-line.transport-rubl-acc
   varold-price-rubl-transport = bf_tt-allsum-line.transport-rubl-acc / varfact-qnty
   varsum-base-transport       = varold-sum-base-transport
   varprice-base-transport     = varold-price-base-transport
   varsum-rubl-transport       = varold-sum-rubl-transport
   varprice-rubl-transport     = varold-price-rubl-transport
   varold-sum-base-other       = bf_tt-allsum-line.other-base-acc
   varold-price-base-other     = bf_tt-allsum-line.other-base-acc / varfact-qnty
   varold-sum-rubl-other       = bf_tt-allsum-line.other-rubl-acc
   varold-price-rubl-other     = bf_tt-allsum-line.other-rubl-acc / varfact-qnty
   varsum-base-other           = varold-sum-base-other
   varprice-base-other         = varold-price-base-other
   varsum-rubl-other           = varold-sum-rubl-other
   varprice-rubl-other         = varold-price-rubl-other
   varold-exch-rate            = (if (varold-sum-rubl - varold-sum-rubl-transport - varold-sum-rubl-other - varold-sum-rubl-road-tax) / varold-sum-cli = ? then 1 else (varold-sum-rubl - varold-sum-rubl-transport - varold-sum-rubl-other - varold-sum-rubl-road-tax) / varold-sum-cli)
   varexch-rate                = varold-exch-rate
   varexch-scale               = 1
  .
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-cur-exch-rate Dialog-Frame
PROCEDURE state-cur-exch-rate :
do on error undo, return error return-value:
 assign
   varexch-rate  = varcur-exch-rate
   varexch-scale = varcur-exch-scale.
 display varexch-rate varexch-scale with frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-cur-rate Dialog-Frame
PROCEDURE state-cur-rate :
do on error undo, return error return-value:
 assign
   varbase-rate  = varcur-base-rate
   varbase-scale = varcur-base-scale.
 display varbase-rate varbase-scale with frame {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
