/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур и функций для множественных прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 03/24/06
Author: Svetlana Chernova
Creation date: 03/24/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ str/lvldsc.i }
{ str/specattr.i }

define variable v-str1 as character no-undo .
FUNCTION fnc-base-price-doc RETURN decimal
  ( local-bc as integer, p-recid as recid ).
define buffer   base-price       for ub.price-doc-forming-gds .   /* цена за основной едизм, устанавливаемая в этой же ДНЦ */
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
define buffer   buf_main-pdf     for ub.price-doc-forming .

find first buf_main-pdf no-lock where recid (buf_main-pdf) = p-recid .

  /* ищем в этой же ДНЦ цену такого же кода, но с основным едизмом */
  run prc-base-code in this-procedure (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.pdf-id = buf_main-pdf.pdf-id and
       base-price.pdf-db = buf_main-pdf.pdf-db and
       base-price.plt-id = buf_main-pdf.plt-id and
       base-price.plt-db-num = buf_main-pdf.plt-db-num and
       base-price.b-code  = local-base-code
       no-error.
  if not available base-price then do:
    /* ищем в этой же ДНЦ главную цену такого товара */
    run prc-main-code in this-procedure
       ( input local-bc, output local-main-code ).
    find  base-price no-lock where
          base-price.pdf-id = buf_main-pdf.pdf-id and
          base-price.pdf-db = buf_main-pdf.pdf-db and
          base-price.plt-id = buf_main-pdf.plt-id and
          base-price.plt-db-num = buf_main-pdf.plt-db-num and
          base-price.b-code  = local-main-code
          no-error.
  end.
  if available base-price then
    return (base-price.price-sale-doc).
  else
    return (?).
END FUNCTION.


procedure set-price-line :

  do
  on error undo, return error return-value
  :
define input  parameter p-plt-id as integer   no-undo .
define input  parameter p-plt-db as integer   no-undo .
define input  parameter  p-calc-method      as character no-undo .
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-b-code           as integer   no-undo .
define input  parameter  p-gds-code         as integer   no-undo .
define input  parameter  p-artic            as character no-undo .
define input  parameter  p-prod-type        as character no-undo .
define input  parameter  p-prod-code        as integer   no-undo .
define input  parameter  p-base-rate        as decimal   no-undo .
define input  parameter  p-base-scale       as decimal   no-undo .
define input  parameter  p-exch-scale       as decimal   no-undo .
define input  parameter  p-exch-rate        as decimal   no-undo .
define input  parameter  v-doc-code         as character no-undo .
define input  parameter  common-price       as decimal   no-undo .
define input  parameter  v-copy-type        as character no-undo .
define input  parameter  v-copy-code        as integer   no-undo .

define output parameter  p-new-calc-method  as character no-undo .
define output parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-calc-doc   as decimal   no-undo .
define output parameter  p-price-calc-rubl  as decimal   no-undo .
define output parameter  p-price-prev-base  as decimal   no-undo .
define output parameter  p-price-prev-doc   as decimal   no-undo .
define output parameter  p-price-prev-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-road-tax-base    as decimal   no-undo .
define output parameter  p-road-tax-doc     as decimal   no-undo .
define output parameter  p-road-tax-rubl    as decimal   no-undo .
define output parameter  p-excise-base      as decimal   no-undo .
define output parameter  p-excise-doc       as decimal   no-undo .
define output parameter  p-excise-rubl      as decimal   no-undo .
define output parameter  p-vat-pc           as decimal   no-undo .
define output parameter  p-slt-pc           as decimal   no-undo .
define output parameter  p-prev-doc-code    as character no-undo .
define output parameter  p-d-pcnt           as decimal   no-undo .

define variable cost-base    as decimal   no-undo .
define variable cost-rubl    as decimal   no-undo .
define variable cur-rt-base  as decimal   no-undo .
define variable cur-rt-rubl  as decimal   no-undo .

define variable local_vat-pc as decimal   no-undo .
define variable local_slt-pc as decimal   no-undo .
define variable new_vat-pc   as character no-undo  init "".
define variable new_slt-pc   as character no-undo  init "".
define variable new_round    as character no-undo  init "".
define variable loc_round    as character no-undo  init "".
define variable v-hostcode   as integer   no-undo .


define variable v-plt-id       as integer   no-undo .
define variable v-plt-db-num   as integer   no-undo .
define variable v-pdf-id       as integer   no-undo .
define variable v-pdf-db-num   as integer   no-undo .
define variable v-plt-id2      as integer   no-undo .
define variable v-plt-db-num2  as integer   no-undo .
define variable v1-recid       as recid no-undo .
define variable v1-cur-rt      as decimal   no-undo .
define variable v1-cur-ex      as decimal   no-undo .
define variable v1 as integer   no-undo .
define variable v2 as integer   no-undo .
define variable v3 as integer   no-undo .
define variable v4 as integer   no-undo .
define variable vd as decimal   no-undo .
define variable v-PriceWithVat as decimal   no-undo .
define variable v-PriceWithoutVat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .
define variable v-descript as character no-undo .

define buffer prev-list                     for ub.price-list  .
define buffer buf_price-list-type           for ub.price-list-type  .
define buffer buf_buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming-gds       for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming           for ub.price-doc-forming  .
define buffer buf_gds-obj                   for ub.gds-obj  .
define buffer buf_trn-doc                   for ub.trn-doc  .
define buffer buf_doc-line                  for ub.doc-line  .
define buffer buf_bar-code                  for ub.bar-code  .
define buffer buf_gds-dtl                   for ub.gds-dtl  .
define buffer buf-goods                     for ub.goods  .
define buffer buf-gds-grp                   for ub.gds-grp  .
define variable loc-increase-pc       as decimal   no-undo .
define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo.
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo.
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo.
define variable p-type-rmethod        as logical   no-undo .
define variable loc-rez               as character no-undo .
define variable t-type                as character no-undo .
define variable g-g                   as logical   no-undo .

define variable var-pr-r-b as character no-undo .
define variable v-base as logical   no-undo .
{ gbl/rbisbase.i v-base no-error }
if error-status :error then do:
   message
     error-status :get-message(1) skip
     return-value skip
     "rbisbase"
     view-as alert-box error
   .
end.

/* что мы берем по объектам */
for each  x_obj-group :
  { gbl/gdsoincr.i
    p-gds-code
    x_obj-group.obj-type
    x_obj-group.obj-code
    loc-increase-pc
    no-error
  }
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.

run gds-attr-margin-value
( input   p-gds-code           ,
  input   x_obj-group.obj-type ,
  input   x_obj-group.obj-code ,
  output  p-prc-min            ,
  output  p-prc-max            ,
  output  loc-grp-increase-pc  ,
  output  loc-grp-round-method ,
  output  loc-grp-round-base   ,
  output  p-value-margin       ,
  output  p-type-margin        ,
  output  p-value-increase     ,
  output  p-type-increase      ,
  output  p-value-rmethod      ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) .
  end.

  g-g = false .
  find first buf-goods no-lock where buf-goods.gds-code =  p-gds-code no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  case p-calc-method:
    when {&pr-common} or
    when {&pr-calc-no} or
    when {&pr-calc-fix} or
    when {&pr-calc-undo}
    then do:
       p-increase-pc  = 0  .
       p-round-method = {&pr-round-off} .
    end.
    when {&pr-calc-goods} then do: /*----------------------------------------------------------------------------------------*/
      /* нужно посчитать цену способом изub.goods */
      case buf-goods.calc-method:
        when {&pr-calc-grp} then do:
          /* нужно посчитать цену способом из gds-grp */
          find buf-gds-grp no-lock where
               buf-gds-grp.node-code = buf-goods.grp-code.
           assign
            p-increase-pc  = loc-grp-increase-pc
            p-round-method = loc-grp-round-method
            p-round-base   = loc-grp-round-base
            g-g = true
           .
        end.
        otherwise do:
           p-increase-pc  =  loc-increase-pc .
        end.
      end case.
      if g-g = false then do:
          /* Округление по товару */
          run gdsoattr-value
             ( input {&attr-round-method-o} ,
               input p-gds-code ,
               input x_obj-group.obj-type ,
               input x_obj-group.obj-code ,
               output loc-rez ,
               output t-type
               ) no-error  .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                "gdsoattr-value"
                view-as alert-box error .
          case NUM-ENTRIES (loc-rez," ") :
              when 0 then do:
              end.
              when 1 then do:
                p-round-method = loc-rez .
                p-round-base   = 0 .
              end.
              when 2 then do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(2 , loc-rez, " " )) .
              end.
              otherwise do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
              end.
          end case.
      end.
    end.
  end case.
    { gbl/hostcode.i
      x_obj-group.obj-type
      x_obj-group.obj-code
      v-hostcode
      no-error }
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "hostcode"
        view-as alert-box error
      .
    /* НДС */
    { gbl/pftxvalg.i
      p-gds-code
      {&vat-tax-code}
      ?
      v-hostcode
      x_obj-group.obj-type
      x_obj-group.obj-code
      local_vat-pc
      no-error
      }
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "НДС"
       view-as alert-box error
     .
    /* slt */
    { gbl/pftxvalg.i
      p-gds-code
      {&slt-tax-code}
      ?
      v-hostcode
      x_obj-group.obj-type
      x_obj-group.obj-code
      local_slt-pc
      no-error }
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "НсП"
      view-as alert-box error
    .
    new_slt-pc = new_slt-pc + string(local_slt-pc) + {&delim-par} .
    new_vat-pc = new_vat-pc + string(local_vat-pc) + {&delim-par} .
    new_round  = new_round  + string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)   + {&delim-par} .
    loc_round  = string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)  .
    find current buf_price-doc-forming no-lock no-error .
    if not available buf_price-doc-forming then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "qqqqqqqq"
       view-as alert-box error
     .
    end.
end.

assign
  v-plt-id     = p-plt-id
  v-plt-db-num = p-plt-db
  p-new-calc-method = p-calc-method
.
run re-define in this-procedure (
    input-output p-calc-method
  , input p-gds-code
  ) no-error .
  if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "re-define"
       view-as alert-box error
     .
  end.

  define variable v-sps as character no-undo .
v-sps =
 "{&bef-pr-calc-goods},
{&bef-pr-calc-grp},
{&bef-pr-calc-cost},
{&bef-pr-calc-costobj},
{&bef-pr-calc-rsrv},
{&bef-pr-calc-last},
{&bef-pr-calc-lastobj},
{&bef-pr-calc-inp},
{&bef-pr-calc-old},
{&bef-pr-calc-new},
{&bef-pr-calc-obj},
{&bef-pr-calc-wbill},
{&bef-pr-calc-wbill-novat},
{&bef-pr-calc-cost-novat},
{&bef-pr-calc-old-novat},
{&bef-pr-calc-ov},
{&bef-pr-calc-pdf},
{&bef-pr-calc-no},
{&bef-pr-calc-scale},
{&bef-pr-calc-special},
{&bef-pr-calc-fix},
{&bef-pr-calc-base},
{&bef-pr-common},
{&bef-pr-calc-cost-wbill},
{&bef-pr-calc-cost-wbill-novat},
{&bef-pr-calc-slt},
{&bef-pr-calc-slt-wbill},
{&bef-pr-calc-cost-gr},
{&bef-pr-calc-rsrv-gr},
{&bef-pr-calc-last-gr},
{&bef-pr-calc-cost-novat-gr},
{&bef-pr-calc-prod},
{&bef-pr-calc-prod-vat},
{&bef-pr-calc-level-prod},
{&bef-pr-calc-level-prod-vat},
{&bef-pr-calc-undo}"
  .
if lookup ( p-calc-method , v-sps )  = 0 then  do:

    p-calc-method = entry (1,p-calc-method, " ") no-error .
    if error-status :error then message p-calc-method.

end.
/* проверим */
define variable v-i as integer   no-undo init 0.
  for each  x_obj-group :
      v-i = v-i + 1.
      if entry( v-i, new_round , {&delim-par} ) <> string ( loc_round ) then do:
          message "На выбранных объектах используются разные параметры Наценки и округления ! Для расчета выбран" string ( loc_round ) skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.

      if entry( v-i, new_vat-pc , {&delim-par} ) <> string ( local_vat-pc ) then do:
          message "На выбранных объектах используются разные НДС ! Для расчета выбран" string ( local_vat-pc ) "%" skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_slt-pc , {&delim-par} ) <> string ( local_slt-pc ) then do:
          message "На выбранных объектах используются разные НсП ! Для расчета выбран" string ( local_slt-pc )
          skip
          "код     :" p-gds-code   skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic             skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
  end.
assign
  p-vat-pc  = local_vat-pc
  p-slt-pc  = local_slt-pc
.

find first buf_price-list-type no-lock where
           buf_price-list-type.plt-id     = v-plt-id    and
           buf_price-list-type.plt-db-num = v-plt-db-num
           no-error .
   if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "q5"
      view-as alert-box error
    .
   return error return-value .
   end.

/* предыдущая цена  на СЕЙЧАС по ДНЦ  */

  { gbl/bc-mpl.i
    buf_price-list-type.gop-id
    buf_price-list-type.gop-db-num
    p-b-code
    0
    0
    v1-recid
    p-price-prev-doc
    v1-cur-rt
    v1-cur-ex
    no-error }
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "bc-mpl"
      view-as alert-box error
    .

/* message 'цена' p-price-prev-doc 'p-price-prev-doc' . */
define buffer old1_price-doc-forming     for ub.price-doc-forming  .
define buffer old1_price-doc-forming-gds for ub.price-doc-forming-gds  .

find first old1_price-doc-forming no-lock where
           recid(old1_price-doc-forming) = v1-recid no-error .
find first old1_price-doc-forming-gds no-lock where
           old1_price-doc-forming-gds.pdf-db      = old1_price-doc-forming.pdf-db      and
           old1_price-doc-forming-gds.pdf-id      = old1_price-doc-forming.pdf-id      and
           old1_price-doc-forming-gds.plt-db-num  = old1_price-doc-forming.plt-db-num  and
           old1_price-doc-forming-gds.plt-id      = old1_price-doc-forming.plt-id      and
           old1_price-doc-forming-gds.b-code      = p-b-code
           no-error .

if available old1_price-doc-forming-gds then do:
   p-d-pcnt = old1_price-doc-forming-gds.d-pcnt .
end.
else do:
  p-d-pcnt = 0 .
end.

case p-calc-method :
   when {&pr-calc-new} or
   when {&pr-calc-fix} then do:
    assign
      p-new-calc-method = p-calc-method
      cost-rubl = ?
      cost-base = ?
    .
      if available buf_price-doc-forming then do:
        assign
          v-pdf-id      = buf_price-doc-forming.pdf-id
          v-pdf-db-num  = buf_price-doc-forming.pdf-db
          v-plt-id2     = buf_price-doc-forming.plt-id
          v-plt-db-num2 = buf_price-doc-forming.plt-db-num
        .
        find first buf_buf_price-doc-forming-gds no-lock where
              buf_buf_price-doc-forming-gds.pdf-id =  v-pdf-id and
              buf_buf_price-doc-forming-gds.pdf-db =  v-pdf-db-num and
              buf_buf_price-doc-forming-gds.plt-id =  v-plt-id2     and
              buf_buf_price-doc-forming-gds.plt-db-num =  v-plt-db-num2 and
              buf_buf_price-doc-forming-gds.b-code =  p-b-code
              no-error .
            if available buf_buf_price-doc-forming-gds then do:
                assign
                  cost-rubl = buf_buf_price-doc-forming-gds.price-sale-rubl
                  cost-base = buf_buf_price-doc-forming-gds.price-sale-base
                .
            end.
      end.
   end.
   when {&pr-calc-cost-gr}  or
   when {&pr-calc-rsrv-gr}  or
   when {&pr-calc-last-gr}
   then do:
      run str/sgdsavrg.p
      (   input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when {&pr-calc-cost-novat-gr} or
   when {&pr-calc-wbill-novat} or
   when {&pr-calc-old-novat} or
   when {&pr-calc-old} or
   when {&pr-calc-cost-wbill} or
   when {&pr-calc-cost-wbill-novat} or
   when {&pr-calc-undo} then do:
      run str/mplnovat.p
        ( input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,           /*p-increase-pc*/
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when {&pr-calc-wbill} then do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = v-doc-code no-error .
        find first buf_doc-line  no-lock where
                  buf_doc-line.doc-code = v-doc-code      and
                  buf_doc-line.artic    = p-artic         and
                  buf_doc-line.prod-type   = p-prod-type  and
                  buf_doc-line.prod-code   = p-prod-code no-error .
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code  = v-doc-code   and
                   buf_gds-dtl.artic     = p-artic      and
                   buf_gds-dtl.prod-type = p-prod-type  and
                   buf_gds-dtl.prod-code = p-prod-code  and
                   buf_gds-dtl.prt-code  = buf_bar-code.node-code no-error .
        assign
          v1 = recid (buf_trn-doc)
          v2 = recid (buf_doc-line)
          v3 = recid (buf_gds-dtl)
          v4  = buf_gds-dtl.prt-code
          no-error .
          if not v-base then do:
            run str/pr-wbil.p
            ( input "{1}"            ,
              input {&pr-calc-wbill} ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-rubl       ,
              output v4
              ) no-error .
          end.
          else do:
            run str/pr-wbil.p
            ( input "{1}"            ,
              input {&pr-calc-wbill} ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-base       ,
              output v4
              ) no-error .
          end.

          if not error-status :error then
              assign
                p-new-calc-method = {&pr-calc-wbill} + " " + v-doc-code
             .
    end.
    when {&pr-calc-ov} then do:
      find prev-list where
           prev-list.b-code     = p-b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = v-doc-code no-lock no-error.
      if available prev-list then
        assign
          p-new-calc-method = {&pr-calc-ov} + " " + v-doc-code
          cur-rt-base = prev-list.road-tax
          cur-rt-rubl = prev-list.road-tax
          cost-rubl = prev-list.price-sale
          cost-base = prev-list.price-sale
          .
      else
        message "Нет строки в переоценке :" v-doc-code "для товара :" p-artic
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when {&pr-calc-pdf} then do:
    find first b_price-doc-forming no-lock where
               b_price-doc-forming.pdf-id     = integer(entry(1,v-doc-code,"|")) and
               b_price-doc-forming.pdf-db     = integer(entry(2,v-doc-code,"|"))
               no-error .


      find b_price-doc-forming-gds no-lock where
           b_price-doc-forming-gds.b-code     = p-b-code and
           b_price-doc-forming-gds.plt-db-num = b_price-doc-forming.plt-db-num and
           b_price-doc-forming-gds.plt-id     = b_price-doc-forming.plt-id and
           b_price-doc-forming-gds.pdf-id     = b_price-doc-forming.pdf-id and
           b_price-doc-forming-gds.pdf-db     = b_price-doc-forming.pdf-db
           no-error.
      if available b_price-doc-forming-gds then
        assign
          p-new-calc-method = {&pr-calc-pdf} + " " + v-doc-code
          cur-rt-base = b_price-doc-forming-gds.road-tax-base
          cur-rt-rubl = b_price-doc-forming-gds.road-tax-rubl
          cost-rubl   = b_price-doc-forming-gds.price-sale-rubl
          cost-base   = b_price-doc-forming-gds.price-sale-base
          .
      else
        message "Нет строки в ДНЦ :" integer(entry(1,v-doc-code,"|")) integer(entry(2,v-doc-code,"|")) skip
                "для товара :" skip
                 "Бар-код" p-b-code     skip
                 "Артикул" p-artic      skip
                  p-prod-type  skip
                  p-prod-code  skip
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when {&pr-common} then do:
        assign
          p-new-calc-method = {&pr-common} + " " + string(common-price)
          cost-rubl = common-price
          cost-base = common-price
          .
          /* НЕОСНОВНЫЕ - применить кожффицмент */
    end.
    when {&pr-calc-obj} then do:
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = p-gds-code and
               buf_gds-obj.obj-type = v-copy-type and
               buf_gds-obj.obj-code = v-copy-code no-error .
        if available buf_gds-obj then do:
        assign
          p-new-calc-method = {&pr-calc-obj} + " " + v-copy-type + string(v-copy-code)
          cost-rubl = buf_gds-obj.price-sale
          cost-base = buf_gds-obj.price-sale
          .
          /* последняя цена barcoda на объекте */
          /*
          message p-price-prev-doc p-price-calc-rubl buf_gds-obj.price-sale .
          p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale .
          p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale .
          cost-rubl = p-price-prev-rubl .
          cost-base = p-price-calc-base .
          */
        end.
        else do:
            message "Нет товара на объекте :" v-copy-type v-copy-code skip
                    "для товара :" p-artic  "- расчет невозможен."
                    view-as alert-box information .

        end.
    end.


   when {&pr-calc-no} or
   when "" then do:
      run str/mplnovat.p
        ( input  {&pr-calc-no}    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).

          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = {&pr-calc-no} .
   end.
   when {&pr-calc-base} then do:
   end.

  when {&pr-calc-level-prod} then do:
    message 1.
  end.
  when {&pr-calc-level-prod-vat} then do:
    message 2.
  end.

  when {&pr-calc-prod}
     then do:
      find first x_obj-group .
    { gbl/proprice.i
      p-b-code
      x_obj-group.obj-type
      x_obj-group.obj-code
      v-PriceWithVat
      vd
      v-prod-vat
      v-str1
      v-str1
      no-error
    }
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара :" p-artic  p-b-code
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#2" update g#log as logical .
      end.
      else do:
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
      end.
  end.
  when {&pr-calc-prod-vat}
    then do:
      find first x_obj-group .
    { gbl/proprice.i
      p-b-code
      x_obj-group.obj-type
      x_obj-group.obj-code
      vd
      v-PriceWithVat
      v-prod-vat
      v-str1
      v-str1
      no-error
    }
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара :" p-artic  p-b-code
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
      end.
    end.

   otherwise do:
     message  "Не просчитывается метод p-calc-method = " p-calc-method  skip
               p-new-calc-method  skip
              "p-price-prev-doc " p-price-prev-doc  skip
              "mpl-lib ERR !!! " skip
              'артикул ' p-artic skip


              view-as alert-box information .
   end.
 end case.
run main-road-taxs in this-procedure
  ( input p-artic     ,
    input p-prod-type ,
    input p-prod-code ,
    input-output cur-rt-base ,
    input-output cur-rt-rubl )
    no-error .
    if error-status :error then do:
       message
         error-status :get-message(1) skip
         return-value skip
         "main-road-taxs"
         view-as alert-box error
       .
    end.
/* Переоценка в RB */
/* ПЕРЕСЧЕТ        */
  if p-exch-scale = 0  or  p-exch-scale = ?  then do:
    return error "Не определен курс валюты документа" .
  end.
  if p-base-scale = 0  or  p-base-scale = ?  then do:
     return error "Не определен курс базовой валюты " .
  end.

if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .

    if var-pr-r-b = "rubl":U then do:
        case p-calc-method :
         when {&pr-calc-level-prod} then do:
            message 3.
         end.
         when {&pr-calc-level-prod-vat} then do:
             message 4.
         end.

         when {&pr-calc-prod} then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100)   .
         end.
         when {&pr-calc-prod-vat} then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) * (1 +  p-vat-pc / 100)  .
         end.
         otherwise do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) .
         end.
        end case.
        assign
          p-price-calc-rubl  =  cost-rubl
          p-road-tax-rubl    =  cur-rt-rubl
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .

    end.
    else dO:
         case p-calc-method :
         when {&pr-calc-level-prod} then do:
            message 5.
         end.
         when {&pr-calc-level-prod-vat} then do:
             message 6.
         end.

         when {&pr-calc-prod} then do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
         end.
         when {&pr-calc-prod-vat} then do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)  .
         end.

         otherwise do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
         end.
         end case.
        assign
          p-price-calc-base  =  cost-base
          p-road-tax-base    =  cur-rt-base
          p-price-calc-rubl  =  p-price-calc-base * p-base-rate / p-base-scale
          p-price-sale-rubl  =  p-price-sale-base * p-base-rate / p-base-scale
          p-road-tax-rubl    =  p-road-tax-base   * p-base-rate / p-base-scale
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .

    end.
   /* ОКРУГЛЕНИЕ в ЦЕНАХ ДОКУМЕНТА */
  { str/pr-99.i
    p-price-sale-doc
    p-round-method
    p-round-base
    no-error }
    if error-status :error then do:
    message
      error-status :get-message(1) skip
      return-value skip
      "pr-99"
      view-as alert-box error
    .
    end.
  /* Пересчет по курсу валюты док в rubl  */
  p-price-calc-rubl = p-price-calc-doc * p-exch-rate / p-exch-scale .
  p-price-sale-rubl = p-price-sale-doc * p-exch-rate / p-exch-scale .
  p-road-tax-rubl   = p-road-tax-doc   * p-exch-rate / p-exch-scale .
  p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale .

  /* Пересчет по курсу валюты в base  */
  p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale .
  p-price-sale-base = p-price-sale-rubl / p-base-rate * p-base-scale .
  p-road-tax-base   = p-road-tax-rubl   / p-base-rate * p-base-scale .
  p-price-prev-base = p-price-prev-rubl / p-base-rate * p-base-scale .

  define buffer bufold_price-doc-forming for ub.price-doc-forming  .
  find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
  p-prev-doc-code = if available bufold_price-doc-forming
                       then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                       else "" .
  end.
end procedure. /* set-price-line */

PROCEDURE calc-price-line :
/* Расчет продажной цены по  ДНЦ */
define input  parameter  p-calc-method      as character no-undo .
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-b-code           as integer   no-undo .
define input  parameter  p-gds-code         as integer   no-undo .
define input  parameter  p-artic            as character no-undo .
define input  parameter  p-prod-type        as character no-undo .
define input  parameter  p-prod-code        as integer   no-undo .
define input  parameter  p-base-rate        as decimal   no-undo .
define input  parameter  p-base-scale       as decimal   no-undo .
define input  parameter  p-exch-scale       as decimal   no-undo .
define input  parameter  p-exch-rate        as decimal   no-undo .
define input  parameter  v-doc-code         as character no-undo .
define input  parameter  common-price       as decimal   no-undo .
define input  parameter  v-copy-type        as character no-undo .
define input  parameter  v-copy-code        as integer   no-undo .

define output parameter  p-new-calc-method  as character no-undo .
define output parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-calc-doc   as decimal   no-undo .
define output parameter  p-price-calc-rubl  as decimal   no-undo .
define output parameter  p-price-prev-base  as decimal   no-undo .
define output parameter  p-price-prev-doc   as decimal   no-undo .
define output parameter  p-price-prev-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-road-tax-base    as decimal   no-undo .
define output parameter  p-road-tax-doc     as decimal   no-undo .
define output parameter  p-road-tax-rubl    as decimal   no-undo .
define output parameter  p-excise-base      as decimal   no-undo .
define output parameter  p-excise-doc       as decimal   no-undo .
define output parameter  p-excise-rubl      as decimal   no-undo .
define output parameter  p-vat-pc           as decimal   no-undo .
define output parameter  p-slt-pc           as decimal   no-undo .
define output parameter  p-prev-doc-code    as character no-undo .
define output parameter  p-d-pcnt           as decimal   no-undo .

define variable cost-base    as decimal   no-undo .
define variable cost-rubl    as decimal   no-undo .
define variable cur-rt-base  as decimal   no-undo .
define variable cur-rt-rubl  as decimal   no-undo .

define variable local_vat-pc as decimal   no-undo .
define variable local_slt-pc as decimal   no-undo .
define variable new_vat-pc   as character no-undo  init "".
define variable new_slt-pc   as character no-undo  init "".
define variable new_round    as character no-undo  init "".
define variable loc_round    as character no-undo  init "".
define variable v-hostcode   as integer   no-undo .


define variable v-plt-id       as integer   no-undo .
define variable v-plt-db-num   as integer   no-undo .
define variable v-pdf-id       as integer   no-undo .
define variable v-pdf-db-num   as integer   no-undo .
define variable v-plt-id2      as integer   no-undo .
define variable v-plt-db-num2  as integer   no-undo .
define variable v1-recid       as recid no-undo .
define variable v1-cur-rt      as decimal   no-undo .
define variable v1-cur-ex      as decimal   no-undo .
define variable v1 as integer   no-undo .
define variable v2 as integer   no-undo .
define variable v3 as integer   no-undo .
define variable v4 as integer   no-undo .
define variable vd as decimal   no-undo .
define variable v-descript as character no-undo .

define buffer prev-list                     for ub.price-list  .
define buffer buf_price-list-type           for ub.price-list-type  .
define buffer buf_buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming-gds       for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming           for ub.price-doc-forming  .
define buffer buf_gds-obj                   for ub.gds-obj  .
define buffer buf_trn-doc                   for ub.trn-doc  .
define buffer buf_doc-line                  for ub.doc-line  .
define buffer buf_bar-code                  for ub.bar-code  .
define buffer buf_gds-dtl                   for ub.gds-dtl  .
define buffer buf-goods                     for ub.goods  .
define buffer buf-gds-grp                   for ub.gds-grp  .
define buffer buf_contract-specif           for ub.contract-specif .
define buffer buf_contract                  for ub.contract .
define variable loc-increase-pc       as decimal   no-undo .
define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo.
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo.
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo.
define variable p-type-rmethod        as logical   no-undo .
define variable loc-rez               as character no-undo .
define variable t-type                as character no-undo .
define variable g-g                   as logical   no-undo .
define variable v-PriceWithVat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .
define variable var-pr-r-b as character no-undo .
define variable v-base as logical   no-undo .
define variable v-num-specif          as integer   no-undo .
define variable v-spis                as character no-undo .
define variable v-contract-code       as integer   no-undo .
define variable v-bonus               as decimal   no-undo .

{ gbl/rbisbase.i v-base }

if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .


/* что мы берем по объектам */
for each  x_obj-group :
  { gbl/gdsoincr.i
    p-gds-code
    x_obj-group.obj-type
    x_obj-group.obj-code
    loc-increase-pc
    no-error
  }
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.

run gds-attr-margin-value
( input   p-gds-code           ,
  input   x_obj-group.obj-type ,
  input   x_obj-group.obj-code ,
  output  p-prc-min            ,
  output  p-prc-max            ,
  output  loc-grp-increase-pc  ,
  output  loc-grp-round-method ,
  output  loc-grp-round-base   ,
  output  p-value-margin       ,
  output  p-type-margin        ,
  output  p-value-increase     ,
  output  p-type-increase      ,
  output  p-value-rmethod      ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) .
  end.

  g-g = false .
  find first buf-goods no-lock where buf-goods.gds-code =  p-gds-code no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .

  case p-calc-method:
    when {&pr-common} or
    when {&pr-calc-no} or
    when {&pr-calc-fix} or
    when {&pr-calc-undo}
    then do:
       p-increase-pc  = 0  .
       p-round-method = {&pr-round-off} .
    end.
    when {&pr-calc-goods} then do: /*----------------------------------------------------------------------------------------*/
      /* нужно посчитать цену способом из ub.goods */
      case buf-goods.calc-method:
        when {&pr-calc-grp} then do:
          /* нужно посчитать цену способом из gds-grp */
          find buf-gds-grp no-lock where
               buf-gds-grp.node-code = buf-goods.grp-code.
           p-increase-pc  = loc-grp-increase-pc .
           p-round-method = loc-grp-round-method .
           p-round-base   = loc-grp-round-base .
           g-g = true  .
        end.
        otherwise do:
           p-increase-pc  =  loc-increase-pc .
        end.
      end case.
      if g-g = false then do:
          /* Округление по товару */
          run gdsoattr-value
             ( input {&attr-round-method-o} ,
               input p-gds-code ,
               input x_obj-group.obj-type ,
               input x_obj-group.obj-code ,
               output loc-rez ,
               output t-type
               ) no-error  .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                "gdsoattr-value"
                view-as alert-box error .
          case NUM-ENTRIES (loc-rez," ") :
              when 0 then do:
              end.
              when 1 then do:
                p-round-method = loc-rez .
                p-round-base   = 0 .
              end.
              when 2 then do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(2 , loc-rez, " " )) .
              end.
              otherwise do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
              end.
          end case.
      end.
    end.
  end case.

    { gbl/hostcode.i
      x_obj-group.obj-type
      x_obj-group.obj-code
      v-hostcode
      no-error }
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "hostcode"
        view-as alert-box error
      .
    /* НДС */
    { gbl/pftxvalg.i
      p-gds-code
      {&vat-tax-code}
      ?
      v-hostcode
      x_obj-group.obj-type
      x_obj-group.obj-code
      local_vat-pc
      no-error
      }
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "НДС"
       view-as alert-box error
     .
    /* slt */
    { gbl/pftxvalg.i
      p-gds-code
      {&slt-tax-code}
      ?
      v-hostcode
      x_obj-group.obj-type
      x_obj-group.obj-code
      local_slt-pc
      no-error }
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "НсП"
      view-as alert-box error
    .
    new_slt-pc = new_slt-pc + string(local_slt-pc) + {&delim-par} .
    new_vat-pc = new_vat-pc + string(local_vat-pc) + {&delim-par} .
    new_round  = new_round  + string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)   + {&delim-par} .
    loc_round  = string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)  .
    find current buf_price-doc-forming no-lock no-error .
    if not available buf_price-doc-forming then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "qqqqqqqq"
       view-as alert-box error
     .
    { gbl/gtplobj.i
      ?
      x_obj-group.obj-type
      x_obj-group.obj-code
      no
      v-plt-id
      v-plt-db-num
      no-error }
      if error-status :error then return error return-value .
    end.
end.

p-new-calc-method = p-calc-method .
run re-define in this-procedure (
    input-output p-calc-method
  , input p-gds-code
  ) .
  define variable v-sps as character no-undo .
v-sps =
 "{&bef-pr-calc-goods},
{&bef-pr-calc-grp},
{&bef-pr-calc-cost},
{&bef-pr-calc-costobj},
{&bef-pr-calc-rsrv},
{&bef-pr-calc-last},
{&bef-pr-calc-lastobj},
{&bef-pr-calc-inp},
{&bef-pr-calc-old},
{&bef-pr-calc-new},
{&bef-pr-calc-obj},
{&bef-pr-calc-wbill},
{&bef-pr-calc-wbill-novat},
{&bef-pr-calc-cost-novat},
{&bef-pr-calc-old-novat},
{&bef-pr-calc-ov},
{&bef-pr-calc-pdf},
{&bef-pr-calc-no},
{&bef-pr-calc-scale},
{&bef-pr-calc-special},
{&bef-pr-calc-fix},
{&bef-pr-calc-base},
{&bef-pr-common},
{&bef-pr-calc-cost-wbill},
{&bef-pr-calc-cost-wbill-novat},
{&bef-pr-calc-slt},
{&bef-pr-calc-slt-wbill},
{&bef-pr-calc-cost-gr},
{&bef-pr-calc-rsrv-gr},
{&bef-pr-calc-last-gr},
{&bef-pr-calc-cost-novat-gr},
{&bef-pr-calc-undo},
{&bef-pr-calc-specif}
"
  .


if lookup ( p-calc-method , v-sps )  = 0 then  do:

    p-calc-method = entry (1,p-calc-method, " ") no-error .
    if error-status :error then message p-calc-method.

end.
/* проверим */
define variable v-i as integer   no-undo init 0.
  for each  x_obj-group :
      v-i = v-i + 1.
      if entry( v-i, new_round , {&delim-par} ) <> string ( loc_round ) then do:
          message "На выбранных объектах используются разные параметры Наценки и округления ! Для расчета выбран" string ( loc_round ) skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.

      if entry( v-i, new_vat-pc , {&delim-par} ) <> string ( local_vat-pc ) then do:
          message "На выбранных объектах используются разные НДС ! Для расчета выбран" string ( local_vat-pc ) "%" skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_slt-pc , {&delim-par} ) <> string ( local_slt-pc ) then do:
          message "На выбранных объектах используются разные НсП ! Для расчета выбран" string ( local_slt-pc )
          skip
          "код     :" p-gds-code   skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic             skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
  end.

p-vat-pc  = local_vat-pc .
p-slt-pc  = local_slt-pc .
  if available buf_price-doc-forming then do:
    /* это текущий тип  пл*/
     find first buf_price-list-type no-lock where
                buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id    and
                buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num
                no-error .
     if error-status :error then return error return-value .
  end.
  else do:
  /* это главный тип если текущий неизвестен  */
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-id     = v-plt-id    and
           buf_price-list-type.plt-db-num = v-plt-db-num
           no-error .
   if error-status :error then return error return-value .
  end.
/* предыдущая цена  на СЕЙЧАС по ДНЦ  */

  { gbl/bc-mpl.i
    buf_price-list-type.gop-id
    buf_price-list-type.gop-db-num
    p-b-code
    0
    0
    v1-recid
    p-price-prev-doc
    v1-cur-rt
    v1-cur-ex
    no-error }
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "bc-mpl"
      view-as alert-box error
    .

/* message 'цена' p-price-prev-doc 'p-price-prev-doc' . */
define buffer old1_price-doc-forming     for ub.price-doc-forming  .
define buffer old1_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first old1_price-doc-forming no-lock where
           recid(old1_price-doc-forming) = v1-recid no-error .
find first old1_price-doc-forming-gds no-lock where
           old1_price-doc-forming-gds.pdf-db      = old1_price-doc-forming.pdf-db      and
           old1_price-doc-forming-gds.pdf-id      = old1_price-doc-forming.pdf-id      and
           old1_price-doc-forming-gds.plt-db-num  = old1_price-doc-forming.plt-db-num  and
           old1_price-doc-forming-gds.plt-id      = old1_price-doc-forming.plt-id      and
           old1_price-doc-forming-gds.b-code      = p-b-code
           no-error .

if available old1_price-doc-forming-gds then do:
   p-d-pcnt = old1_price-doc-forming-gds.d-pcnt .
end.
else do:
  p-d-pcnt = 0 .
end.


case p-calc-method :
   when {&pr-calc-new} or
   when {&pr-calc-fix} then do:
    assign
      p-new-calc-method = p-calc-method
      cost-rubl = ?
      cost-base = ?
    .
      if available buf_price-doc-forming then do:
        assign
          v-pdf-id      = buf_price-doc-forming.pdf-id
          v-pdf-db-num  = buf_price-doc-forming.pdf-db
          v-plt-id2     = buf_price-doc-forming.plt-id
          v-plt-db-num2 = buf_price-doc-forming.plt-db-num
        .
        find first buf_buf_price-doc-forming-gds no-lock where
              buf_buf_price-doc-forming-gds.pdf-id =  v-pdf-id and
              buf_buf_price-doc-forming-gds.pdf-db =  v-pdf-db-num and
              buf_buf_price-doc-forming-gds.plt-id =  v-plt-id2     and
              buf_buf_price-doc-forming-gds.plt-db-num =  v-plt-db-num2 and
              buf_buf_price-doc-forming-gds.b-code =  p-b-code
              no-error .
            if available buf_buf_price-doc-forming-gds then do:
                assign
                  cost-rubl = buf_buf_price-doc-forming-gds.price-sale-rubl
                  cost-base = buf_buf_price-doc-forming-gds.price-sale-base
                .
            end.
      end.
   end.
   when {&pr-calc-cost-gr}  or
   when {&pr-calc-rsrv-gr}  or
   when {&pr-calc-last-gr}
   then do:
      run str/sgdsavrg.p
      (   input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when {&pr-calc-cost-novat-gr} or
   when {&pr-calc-wbill-novat} or
   when {&pr-calc-old-novat} or
   when {&pr-calc-old} or
   when {&pr-calc-cost-wbill} or
   when {&pr-calc-cost-wbill-novat} or
   when {&pr-calc-undo} then do:
      run str/mplnovat.p
        ( input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,           /*p-increase-pc*/
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when {&pr-calc-wbill} then do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = v-doc-code no-error .
        find first buf_doc-line  no-lock where
                  buf_doc-line.doc-code = v-doc-code      and
                  buf_doc-line.artic    = p-artic         and
                  buf_doc-line.prod-type   = p-prod-type  and
                  buf_doc-line.prod-code   = p-prod-code no-error .
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code  = v-doc-code   and
                   buf_gds-dtl.artic     = p-artic      and
                   buf_gds-dtl.prod-type = p-prod-type  and
                   buf_gds-dtl.prod-code = p-prod-code  and
                   buf_gds-dtl.prt-code  = buf_bar-code.node-code no-error .
        assign
          v1 = recid (buf_trn-doc)
          v2 = recid (buf_doc-line)
          v3 = recid (buf_gds-dtl)
          v4  = buf_gds-dtl.prt-code
          no-error .
          if not v-base then do:
            run str/pr-wbil.p
            ( input "{1}"            ,
              input {&pr-calc-wbill} ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-rubl       ,
              output v4
              ) no-error .
          end.
          else do:
            run str/pr-wbil.p
            ( input "{1}"            ,
              input {&pr-calc-wbill} ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-base       ,
              output v4
              ) no-error .
          end.

          if not error-status :error then
              assign
                p-new-calc-method = {&pr-calc-wbill} + " " + v-doc-code
             .
    end.
    when {&pr-calc-ov} then do:
      find prev-list where
           prev-list.b-code     = p-b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = v-doc-code no-lock no-error.
      if available prev-list then
        assign
          p-new-calc-method = {&pr-calc-ov} + " " + v-doc-code
          cur-rt-base = prev-list.road-tax
          cur-rt-rubl = prev-list.road-tax
          cost-rubl = prev-list.price-sale
          cost-base = prev-list.price-sale
          .
      else
        message "Нет строки в переоценке :" v-doc-code "для товара :" p-artic
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when {&pr-calc-pdf} then do:
    find first b_price-doc-forming no-lock where
               b_price-doc-forming.pdf-id     = integer(entry(1,v-doc-code,"|")) and
               b_price-doc-forming.pdf-db     = integer(entry(2,v-doc-code,"|"))
               no-error .


      find b_price-doc-forming-gds no-lock where
           b_price-doc-forming-gds.b-code     = p-b-code and
           b_price-doc-forming-gds.plt-db-num = b_price-doc-forming.plt-db-num and
           b_price-doc-forming-gds.plt-id     = b_price-doc-forming.plt-id and
           b_price-doc-forming-gds.pdf-id     = b_price-doc-forming.pdf-id and
           b_price-doc-forming-gds.pdf-db     = b_price-doc-forming.pdf-db
           no-error.
      if available b_price-doc-forming-gds then
        assign
          p-new-calc-method = {&pr-calc-pdf} + " " + v-doc-code
          cur-rt-base = b_price-doc-forming-gds.road-tax-base
          cur-rt-rubl = b_price-doc-forming-gds.road-tax-rubl
          cost-rubl   = b_price-doc-forming-gds.price-sale-rubl
          cost-base   = b_price-doc-forming-gds.price-sale-base
          .
      else
        message "Нет строки в ДНЦ :" integer(entry(1,v-doc-code,"|")) integer(entry(2,v-doc-code,"|")) skip
                "для товара :" skip
                 "Бар-код" p-b-code     skip
                 "Артикул" p-artic      skip
                  p-prod-type  skip
                  p-prod-code  skip
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when {&pr-common} then do:
        assign
          p-new-calc-method = {&pr-common} + " " + string(common-price)
          cost-rubl = common-price
          cost-base = common-price
          .
          /* НЕОСНОВНЫЕ - применить коэффициент */
    end.
    when {&pr-calc-obj} then do:
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = p-gds-code and
               buf_gds-obj.obj-type = v-copy-type and
               buf_gds-obj.obj-code = v-copy-code no-error .
        if available buf_gds-obj then do:
        assign
          p-new-calc-method = {&pr-calc-obj} + " " + v-copy-type + string(v-copy-code)
          cost-rubl = buf_gds-obj.price-sale
          cost-base = buf_gds-obj.price-sale
          .
          /* последняя цена barcoda на объекте */
          /*
          message p-price-prev-doc p-price-calc-rubl buf_gds-obj.price-sale .
          p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale .
          p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale .
          cost-rubl = p-price-prev-rubl .
          cost-base = p-price-calc-base .
          */
        end.
        else do:
            message "Нет товара на объекте :" v-copy-type v-copy-code skip
                    "для товара :" p-artic  "- расчет невозможен."
                    view-as alert-box information .

        end.
    end.

   when {&pr-calc-no} or
   when "" then do:
      run str/mplnovat.p
        ( input  {&pr-calc-no}    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).

          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = {&pr-calc-no} .
   end.
   when {&pr-calc-base} then do:
   end.
    when {&pr-calc-level-prod} then do:
      find first x_obj-group.
          run calc-price-levelprod (
            input 2          , /* 1- цены с НДС; 2 - цены без ндс */
            input var-pr-r-b ,
            input p-b-code   ,
            input x_obj-group.obj-type ,
            input x_obj-group.obj-code ,
            output vd,
            output v-descript
          ) no-error.
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной c пороговой наценкой невозможен."
                view-as alert-box question buttons OK-Cancel title "#4" update g#log1 as logical .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = substitute("&1&2&3" ,p-calc-method, {&delim-par},v-descript ) .
      end.

    end.
    when {&pr-calc-level-prod-vat} then do:
      find first x_obj-group.
          run calc-price-levelprod (
            input 1          , /* 1- цены с НДС; 2 - цены без ндс */
            input var-pr-r-b ,
            input p-b-code   ,
            input x_obj-group.obj-type ,
            input x_obj-group.obj-code ,
            output vd ,
            output v-descript
          ) no-error.
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной c пороговой наценкой невозможен."
                view-as alert-box information .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = substitute("&1&2&3" ,p-calc-method, {&delim-par},v-descript ) .
      end.

    end.


    when {&pr-calc-prod}
    then do:
      find first x_obj-group.
    { gbl/proprice.i
      p-b-code
      x_obj-group.obj-type
      x_obj-group.obj-code
      v-PriceWithVat
      vd
      v-prod-vat
      v-str1
      v-str1
      no-error }
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "proprice.i"
        view-as alert-box error
      .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#3" update g#log as logical .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = p-calc-method .
      end.
    end.

    when {&pr-calc-prod-vat}
    then do:
      find first x_obj-group.
    { gbl/proprice.i
      p-b-code
      x_obj-group.obj-type
      x_obj-group.obj-code
      vd
      v-PriceWithVat
      v-prod-vat
      v-str1
      v-str1
      no-error }
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "proprice.i"
        view-as alert-box error
      .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box  .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = p-calc-method .
      end.
    end.
   when {&pr-calc-specif}
   then do:
      find first x_obj-group.
      assign
        v-num-specif    = 0
        v-contract-code = 0
      .
      for each buf_contract no-lock
      where buf_contract.host-code = v-cntxt-host-code-obj
      :
        {str/cont-slave-inc.i
            &FOR_ = YES
            &EACH_ = YES
            &BUFFER_SPECIF   =  buf_contract-specif
            &P_HOST_CODE     =  v-cntxt-host-code-obj
            &P_CONTRACT_NUM  =  buf_contract.contract-code
            &NO_LOCK=YES
            &NO_END=YES
        }
  /*        for each buf_contract-specif no-lock*/
  /*        where buf_contract-specif.host-code    = v-cntxt-host-code-obj*/
  /*          and buf_contract-specif.gds-code     = p-gds-code*/
           :
            if buf_contract-specif.gds-code = p-gds-code then do:
              assign
                v-num-specif = v-num-specif + 1
                v-contract-code = buf_contract.contract-code
              .
            end.
        end.
      end.
      if v-num-specif > 1 then do:
         run str/gds-cnts.w
            (input parparentproc
            ,input p-gds-code
            , "b-sel":U /* bttn */
            ,output v-spis
          ) no-error.
        find first buf_contract-specif no-lock
        where recid(buf_contract-specif) = integer(v-spis)
          no-error.
          if available buf_contract-specif then do:
              run read-bonus (
                  input  buf_contract-specif.contract-num  ,
                  input  buf_contract-specif.host-code     ,
                  input  buf_contract-specif.gds-code      ,
                  output v-bonus  ) .

              assign
                cost-rubl = buf_contract-specif.price-cli
                cost-base = buf_contract-specif.price-cli / p-base-rate * p-base-scale
                p-new-calc-method = {&pr-calc-specif}
              .

              if v-bonus <> ? and v-bonus <> 0 then do:
                 assign
                 cost-rubl = cost-rubl + ( cost-rubl * v-bonus / 100 )
                 cost-base = cost-base + ( cost-base * v-bonus / 100 )
                 .
              end.
          end.
          else do:
            message "Не найдена спецификация с recid " v-spis skip
                    "для товара с артикулом " p-artic skip
                    "на объекте " x_obj-group.obj-type x_obj-group.obj-code skip
                    view-as alert-box information .
          end.
      end. /* >1 */
      if v-num-specif = 0 then do:
          message "Не найдена ни одна спецификация" skip
                  "для товара с артикулом " p-artic skip
                  "на объекте " x_obj-group.obj-type x_obj-group.obj-code skip
                  view-as alert-box information .
      end. /* =0 */
      if v-num-specif = 1 then do:
/*        find first buf_contract-specif no-lock*/
/*        where buf_contract-specif.host-code    = v-cntxt-host-code-obj*/
/*          and buf_contract-specif.gds-code     = p-gds-code*/
/*          no-error.*/
            {str/cont-slave-inc.i
                &FOR_ = YES
                &EACH_ = YES
                &BUFFER_SPECIF   =  buf_contract-specif
                &P_HOST_CODE     =  v-cntxt-host-code-obj
                &P_CONTRACT_NUM  =  v-contract-code
                &NO_LOCK=YES
                &NO_END=YES
            }
            :
            if buf_contract-specif.gds-code = p-gds-code then do:
              run read-bonus (
                  input  buf_contract-specif.contract-num  ,
                  input  buf_contract-specif.host-code     ,
                  input  buf_contract-specif.gds-code      ,
                  output v-bonus  ) .

              assign
                cost-rubl = buf_contract-specif.price-cli
                cost-base = buf_contract-specif.price-cli / p-base-rate * p-base-scale
                p-new-calc-method = {&pr-calc-specif}
              .

              if v-bonus <> ? and v-bonus <> 0 then do:
                 assign
                 cost-rubl = cost-rubl + ( cost-rubl * v-bonus / 100 )
                 cost-base = cost-base + ( cost-base * v-bonus / 100 )
                 .
              end.
            end.
          end.
      end. /* =1 */
   end.
   otherwise do:
     message  "Не просчитывается метод p-calc-method = " p-calc-method  skip
               p-new-calc-method  skip
              "p-price-prev-doc " p-price-prev-doc  skip
              "mpl-lib ERR !!! " skip
              'артикул ' p-artic skip
              view-as alert-box information .
   end.
 end case.

run main-road-taxs in this-procedure
  ( input p-artic     ,
    input p-prod-type ,
    input p-prod-code ,
    input-output cur-rt-base ,
    input-output cur-rt-rubl )
    .
/* Переоценка в RB */
/* ПЕРЕСЧЕТ        */
  if p-exch-scale = 0  or  p-exch-scale = ?  then do:
    return error "Не определен курс валюты документа" .
  end.
  if p-base-scale = 0  or  p-base-scale = ?  then do:
     return error "Не определен курс базовой валюты " .
  end.
/*define variable var-pr-r-b as character no-undo .*/
/*define variable v-base as logical   no-undo .*/
/*{ gbl/rbisbase.i v-base }*/

if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .

    if var-pr-r-b = "rubl":U then do:
         case p-calc-method :
         when {&pr-calc-level-prod} then do: /* пороговый 1*/
            p-price-sale-rubl  =  cost-rubl + (cost-rubl * p-vat-pc / 100)  .
         end.
         when {&pr-calc-level-prod-vat} then do: /* пороговый 2*/
            p-price-sale-rubl  =  cost-rubl .
         end.
         when  {&pr-calc-prod} then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100)  .
         end.
         when  {&pr-calc-prod-vat} then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)   .
         end.
         otherwise do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) .
         end.
        end case.
        assign
          p-price-calc-rubl  =  cost-rubl
          p-road-tax-rubl    =  cur-rt-rubl
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .

    end.
    else do:
         case p-calc-method:
            when {&pr-calc-level-prod} then do:
                p-price-sale-base  =  cost-base + (cost-base * p-vat-pc / 100)  .
            end.
            when {&pr-calc-level-prod-vat} then do:
                p-price-sale-base  =  cost-base .
            end.
            when {&pr-calc-prod} then do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100)  .
            end.
            when {&pr-calc-prod-vat} then do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)  .
            end.
            otherwise do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
            end.
         end case.

        assign
          p-price-calc-base  =  cost-base
          p-road-tax-base    =  cur-rt-base
          p-price-calc-rubl  =  p-price-calc-base * p-base-rate / p-base-scale
          p-price-sale-rubl  =  p-price-sale-base * p-base-rate / p-base-scale
          p-road-tax-rubl    =  p-road-tax-base   * p-base-rate / p-base-scale
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .

    end.
   /* ОКРУГЛЕНИЕ в ЦЕНАХ ДОКУМЕНТА */
   if p-price-sale-doc <> 0 then do:
  { str/pr-99.i
    p-price-sale-doc
    p-round-method
    p-round-base
  }
  end.

  /* Пересчет по курсу валюты док в rubl  */
  assign
    p-price-calc-rubl = p-price-calc-doc * p-exch-rate / p-exch-scale
    p-price-sale-rubl = p-price-sale-doc * p-exch-rate / p-exch-scale
    p-road-tax-rubl   = p-road-tax-doc   * p-exch-rate / p-exch-scale
    p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale
   .
  /* Пересчет по курсу валюты в base  */
  assign
    p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale
    p-price-sale-base = p-price-sale-rubl / p-base-rate * p-base-scale
    p-road-tax-base   = p-road-tax-rubl   / p-base-rate * p-base-scale
    p-price-prev-base = p-price-prev-rubl / p-base-rate * p-base-scale
  .


  define buffer bufold_price-doc-forming for ub.price-doc-forming  .
  find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
  p-prev-doc-code = if available bufold_price-doc-forming
                       then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                       else "" .

END PROCEDURE.

PROCEDURE create-line :
/* Создание  */
define input  parameter p-plt-db-num        like ub.price-doc-forming-gds.plt-db-num  no-undo .
define input  parameter p-plt-id            like ub.price-doc-forming-gds.plt-id      no-undo .
define input  parameter p-pdf-db            like ub.price-doc-forming-gds.pdf-db      no-undo .
define input  parameter p-pdf-id            like ub.price-doc-forming-gds.pdf-id  no-undo .
define input  parameter p-line-num          like ub.price-doc-forming-gds.line-num no-undo .
define input  parameter p-b-code            like ub.price-doc-forming-gds.b-code   no-undo .
define input  parameter p-artic             like ub.price-doc-forming-gds.artic    no-undo .
define input  parameter p-prod-type         like ub.price-doc-forming-gds.prod-type no-undo .
define input  parameter p-prod-code         like ub.price-doc-forming-gds.prod-code no-undo .
define input  parameter p-calc-method       like ub.price-doc-forming-gds.calc-method  no-undo .
define input  parameter p-d-pcnt            like ub.price-doc-forming-gds.d-pcnt       no-undo .
define input  parameter p-have-start-period like ub.price-doc-forming-gds.have-start-period no-undo .
define input  parameter p-start-date        like ub.price-doc-forming-gds.start-date        no-undo .
define input  parameter p-start-shift-date  like ub.price-doc-forming-gds.start-shift-date  no-undo .
define input  parameter p-start-shift-name  like ub.price-doc-forming-gds.start-shift-name  no-undo .
define input  parameter p-start-shift-num   like ub.price-doc-forming-gds.start-shift-num   no-undo .
define input  parameter p-start-sys-date    like ub.price-doc-forming-gds.start-sys-date    no-undo .
define input  parameter p-start-sys-time    like ub.price-doc-forming-gds.start-sys-time    no-undo .
define input  parameter p-have-end-period   like ub.price-doc-forming-gds.have-end-period   no-undo .
define input  parameter p-end-date          like ub.price-doc-forming-gds.end-date          no-undo .
define input  parameter p-end-shift-date    like ub.price-doc-forming-gds.end-shift-date    no-undo .
define input  parameter p-end-shift-name    like ub.price-doc-forming-gds.end-shift-name    no-undo .
define input  parameter p-end-shift-num     like ub.price-doc-forming-gds.end-shift-num     no-undo .
define input  parameter p-end-sys-date      like ub.price-doc-forming-gds.end-sys-date      no-undo .
define input  parameter p-end-sys-time      like ub.price-doc-forming-gds.end-sys-time      no-undo .
define input  parameter p-price-calc-base   like ub.price-doc-forming-gds.price-calc-base   no-undo .
define input  parameter p-price-calc-doc    like ub.price-doc-forming-gds.price-calc-doc    no-undo .
define input  parameter p-price-calc-rubl   like ub.price-doc-forming-gds.price-calc-rubl   no-undo .
define input  parameter p-price-prev-base   like ub.price-doc-forming-gds.price-prev-base   no-undo .
define input  parameter p-price-prev-doc    like ub.price-doc-forming-gds.price-prev-doc    no-undo .
define input  parameter p-price-prev-rubl   like ub.price-doc-forming-gds.price-prev-rubl   no-undo .
define input  parameter p-price-sale-base   like ub.price-doc-forming-gds.price-sale-base   no-undo .
define input  parameter p-price-sale-doc    like ub.price-doc-forming-gds.price-sale-doc    no-undo .
define input  parameter p-price-sale-rubl   like ub.price-doc-forming-gds.price-sale-rubl   no-undo .
define input  parameter p-road-tax-base     like ub.price-doc-forming-gds.road-tax-base     no-undo .
define input  parameter p-road-tax-doc      like ub.price-doc-forming-gds.road-tax-doc      no-undo .
define input  parameter p-road-tax-rubl     like ub.price-doc-forming-gds.road-tax-rubl     no-undo .
define input  parameter p-excise-base       like ub.price-doc-forming-gds.excise-base       no-undo .
define input  parameter p-excise-doc        like ub.price-doc-forming-gds.excise-doc        no-undo .
define input  parameter p-excise-rubl       like ub.price-doc-forming-gds.excise-rubl       no-undo .
define input  parameter p-vat-pc            like ub.price-doc-forming-gds.vat-pc            no-undo .
define input  parameter p-slt-pc            like ub.price-doc-forming-gds.slt-pc            no-undo .
define input  parameter p-prev-doc-code     as character no-undo .
define input  parameter p-stts              like ub.price-doc-forming-gds.stts              no-undo .
define input-output parameter  v-sec        as integer   no-undo .

  run check-use-bar-code ( p-b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo, return error return-value.
  end.

find first ub.price-doc-forming-gds exclusive-lock where
           ub.price-doc-forming-gds.plt-db-num  =  p-plt-db-num and
           ub.price-doc-forming-gds.plt-id      =  p-plt-id     and
           ub.price-doc-forming-gds.pdf-db      =  p-pdf-db     and
           ub.price-doc-forming-gds.pdf-id      =  p-pdf-id     and
           ub.price-doc-forming-gds.b-code      =  p-b-code     no-error .
    if not available ub.price-doc-forming-gds then
    do:
      create ub.price-doc-forming-gds .
       assign
        ub.price-doc-forming-gds.plt-db-num = p-plt-db-num
        ub.price-doc-forming-gds.plt-id     = p-plt-id
        ub.price-doc-forming-gds.pdf-db     = p-pdf-db
        ub.price-doc-forming-gds.pdf-id     = p-pdf-id
        ub.price-doc-forming-gds.b-code     = p-b-code
        ub.price-doc-forming-gds.line-num   = p-line-num
       .
    end.

  assign
    ub.price-doc-forming-gds.artic            = p-artic
    ub.price-doc-forming-gds.prod-type        = p-prod-type
    ub.price-doc-forming-gds.prod-code        = p-prod-code
    ub.price-doc-forming-gds.calc-method      = p-calc-method
    ub.price-doc-forming-gds.d-pcnt            = p-d-pcnt
    ub.price-doc-forming-gds.have-start-period = p-have-start-period
    ub.price-doc-forming-gds.start-date       = p-start-date
    ub.price-doc-forming-gds.start-shift-date = p-start-shift-date
    ub.price-doc-forming-gds.start-shift-name = p-start-shift-name
    ub.price-doc-forming-gds.start-shift-num  = p-start-shift-num
    ub.price-doc-forming-gds.start-sys-date   = p-start-sys-date
    ub.price-doc-forming-gds.start-sys-time   = p-start-sys-time
    ub.price-doc-forming-gds.have-end-period  = p-have-end-period
    ub.price-doc-forming-gds.end-date         = p-end-date
    ub.price-doc-forming-gds.end-shift-date   = p-end-shift-date
    ub.price-doc-forming-gds.end-shift-name   = p-end-shift-name
    ub.price-doc-forming-gds.end-shift-num    = p-end-shift-num
    ub.price-doc-forming-gds.end-sys-date     = p-end-sys-date
    ub.price-doc-forming-gds.end-sys-time     = p-end-sys-time
    ub.price-doc-forming-gds.price-calc-base  = p-price-calc-base
    ub.price-doc-forming-gds.price-calc-doc   = p-price-calc-doc
    ub.price-doc-forming-gds.price-calc-rubl  = p-price-calc-rubl
    ub.price-doc-forming-gds.price-prev-base  = p-price-prev-base
    ub.price-doc-forming-gds.price-prev-doc   = p-price-prev-doc
    ub.price-doc-forming-gds.price-prev-rubl  = p-price-prev-rubl
    ub.price-doc-forming-gds.road-tax-base    = p-road-tax-base
    ub.price-doc-forming-gds.road-tax-doc     = p-road-tax-doc
    ub.price-doc-forming-gds.road-tax-rubl    = p-road-tax-rubl
    ub.price-doc-forming-gds.excise-base      = p-excise-base
    ub.price-doc-forming-gds.excise-doc       = p-excise-doc
    ub.price-doc-forming-gds.excise-rubl      = p-excise-rubl
    ub.price-doc-forming-gds.vat-pc           = p-vat-pc
    ub.price-doc-forming-gds.slt-pc           = p-slt-pc
    ub.price-doc-forming-gds.prev-doc-code    = p-prev-doc-code
    ub.price-doc-forming-gds.stts             = p-stts
    ub.price-doc-forming-gds.price-sale-base  = p-price-sale-base
    ub.price-doc-forming-gds.price-sale-doc   = p-price-sale-doc
    ub.price-doc-forming-gds.price-sale-rubl  = p-price-sale-rubl
    .

  /* Запись истории по строкам ДНЦ */
  run ref/h-pdfgds.p
    ( buffer ub.price-doc-forming-gds ,
      input p-price-sale-doc ,
      input-output v-sec
      ) .
END PROCEDURE.


PROCEDURE last-num :
define input  parameter p-recid as recid no-undo .
define output parameter p-last-id as integer   no-undo .

define buffer buf2_price-doc-forming     for ub.price-doc-forming  .
define buffer buf2_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first buf2_price-doc-forming no-lock where recid(buf2_price-doc-forming) = p-recid no-error .
      if error-status :error then do:
        p-last-id = ? .
        return .
      end.

    /* последний line-num */
    for each buf2_price-doc-forming-gds no-lock  where
            buf2_price-doc-forming-gds.plt-id     = buf2_price-doc-forming.plt-id     and
            buf2_price-doc-forming-gds.plt-db-num = buf2_price-doc-forming.plt-db-num and
            buf2_price-doc-forming-gds.pdf-id     = buf2_price-doc-forming.pdf-id     and
            buf2_price-doc-forming-gds.pdf-db     = buf2_price-doc-forming.pdf-db
            by buf2_price-doc-forming-gds.line-num
            :
            p-last-id = buf2_price-doc-forming-gds.line-num .
    end.

END PROCEDURE.

PROCEDURE calc-price-alt :
/* ---------------------------------------------------------------------------------------------------------------------------------
   вычисление цены заданного неосновного кода с округлением
------------------------------------------------------------------------------------------------------------------------------------ */
define input parameter bc         like ub.bar-code.b-code   no-undo.
define input parameter p-recid as recid no-undo .
define input parameter d-pcnt as decimal   no-undo .
define input parameter r-method   as character no-undo .
define input parameter r-base     as decimal   no-undo .

define output parameter pa-price-sale-base  as decimal   no-undo .
define output parameter pa-price-sale-doc   as decimal   no-undo .
define output parameter pa-price-sale-rubl  as decimal   no-undo .

pr-alt:
do on error undo pr-alt, return error:

  if r-method = ? or
     r-base = ? then do:
    /* не заданы они при вызове из p r  - s t a t . p  - если есть для неопределенной
       основной хоть одна зависимая неосновная - будет откачено */
    message
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      view-as alert-box error.
    undo pr-alt, return error.
  end.

define buffer buf_bar-code for ub.bar-code  .
define buffer buf_main_bar-code for ub.bar-code  .
define buffer buf_main_price-doc-forming for ub.price-doc-forming  .
define buffer buf_main_price-doc-forming-gds for ub.price-doc-forming-gds  .

find first buf_main_price-doc-forming no-lock where recid(buf_main_price-doc-forming) = p-recid  no-error .
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка "
  view-as alert-box error
.

find first buf_bar-code no-lock where
           buf_bar-code.b-code = bc no-error .

if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "3"
  view-as alert-box error
.

  /* вычисляем неосновную цену */
      assign
        pa-price-sale-doc = fnc-base-price-doc ( input bc , input p-recid ) *
                            buf_bar-code.cli-base-rate *
                            (1 - d-pcnt / 100)
                              .
  if pa-price-sale-doc <> 0 then do:
  { str/pr-99.i
    pa-price-sale-doc
    r-method
    r-base
  }
  end.
  pa-price-sale-rubl = pa-price-sale-doc * buf_main_price-doc-forming.exch-rate / buf_main_price-doc-forming.exch-scale .
  pa-price-sale-base = pa-price-sale-rubl / buf_main_price-doc-forming.base-rate * buf_main_price-doc-forming.base-scale .


end.
END PROCEDURE.

procedure calc-price-discnt :
/* ---------------------------------------------------------------------------------------------------------------------------------
   вычисление скидки от цены заданного неосновного кода
------------------------------------------------------------------------------------------------------------------------------------ */
  do
  on error undo, return error return-value
  :

define input parameter p-recid as recid no-undo .
define input parameter bc    like ub.bar-code.b-code   no-undo.

define buffer buf-price-doc-forming             for ub.price-doc-forming.
define buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-bar-code                      for ub.bar-code.
define buffer buf-goods                         for ub.goods.
define buffer old-price-doc-forming-gds         for ub.price-doc-forming-gds.

define variable pr-rec   as   recid                     no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.

pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc-forming no-lock where
        recid(buf-price-doc-forming) = p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-doc-forming-gds exclusive-lock where
        buf-price-doc-forming-gds.pdf-id = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db     = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code  = bc.
   if available buf-price-doc-forming-gds then do:
      buf-price-doc-forming-gds.d-pcnt =
      (1 - buf-price-doc-forming-gds.price-sale-doc /
            fnc-base-price-doc ( buf-bar-code.b-code, p-recid ) /
            buf-bar-code.cli-base-rate) * 100 .
   end.
end.

  end.

end procedure. /* calc-price-discnt */


procedure calc-price-sub :
/* ---------------------------------------------------------------------------------------------------------------------------------
   если главная цена, считает также все неосновные и спеццены по товару
   если основная - считает только для нее все неосновные
------------------------------------------------------------------------------------------------------------------------------------- */
define  input  parameter bc           like ub.price-doc-forming-gds.b-code no-undo.
define  input  parameter p-recid      as recid no-undo .
define  input  parameter calc-method  as character         no-undo. /* способ расчета цены - исходная цена */
define  input  parameter increase-pc  as decimal           no-undo. /* процент наценки (с минусом - скидки)*/
define  input  parameter round-method as character         no-undo. /* способ округления */
define  input  parameter round-base   as decimal           no-undo. /* база для округления / коэффициент */
define  input  parameter doc-code     as character no-undo .
define  input  parameter common-price as decimal   no-undo .
define  input  parameter copy-type    as character no-undo .
define  input  parameter copy-code    as integer   no-undo .
define  output parameter calc-rec     as recid             no-undo. /* recid последней пересчитанной основной цены */

define  buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define  buffer buf-bar-code              for ub.bar-code.
define  buffer buf-goods                 for ub.goods.
define  buffer buf-gds-prt               for ub.gds-prt.
define  buffer buf-gds-grp               for ub.gds-grp.
define  buffer buf-price-doc-forming     for ub.price-doc-forming.

calc-sub:
do on error undo calc-sub, return error:
  find  buf-price-doc-forming no-lock where
        recid (buf-price-doc-forming) =  p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-doc-forming-gds where
        buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num  = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code      = bc no-error .
  calc-rec = recid (buf-price-doc-forming-gds).

  if buf-gds-prt.upper-code = buf-goods.prt-root and  buf-goods.unit-base = buf-bar-code.unit-cli  then do: /* main-price */
    /* считаем все спецены для товара */
    for each  buf-price-doc-forming-gds exclusive-lock where
              buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
              buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
              buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
              buf-price-doc-forming-gds.plt-db-num    = buf-price-doc-forming.plt-db-num and
              buf-price-doc-forming-gds.artic      = buf-goods.artic and
              buf-price-doc-forming-gds.prod-type  = buf-goods.prod-type and
              buf-price-doc-forming-gds.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-doc-forming-gds.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base ,
        first buf-gds-prt no-lock where
              buf-gds-prt.node-code = buf-bar-code.node-code and
              buf-gds-prt.upper-code <> buf-goods.prt-root

        on error undo calc-sub, return error:
      /* основная спеццена */
          run calc-price-line  in this-procedure
            ( input  calc-method
            , input  increase-pc
            , input  round-method
            , input  round-base
            , input  buf-bar-code.b-code
            , input  buf-goods.gds-code
            , input  buf-goods.artic
            , input  buf-goods.prod-type
            , input  buf-goods.prod-code
            , input  buf-price-doc-forming.base-rate
            , input  buf-price-doc-forming.base-scale
            , input  buf-price-doc-forming.exch-scale
            , input  buf-price-doc-forming.exch-rate
            , input  doc-code
            , input  common-price
            , input  copy-type
            , input  copy-code
            , output buf-price-doc-forming-gds.calc-method
            , output buf-price-doc-forming-gds.price-calc-base
            , output buf-price-doc-forming-gds.price-calc-doc
            , output buf-price-doc-forming-gds.price-calc-rubl
            , output buf-price-doc-forming-gds.price-prev-base
            , output buf-price-doc-forming-gds.price-prev-doc
            , output buf-price-doc-forming-gds.price-prev-rubl
            , output buf-price-doc-forming-gds.price-sale-base
            , output buf-price-doc-forming-gds.price-sale-doc
            , output buf-price-doc-forming-gds.price-sale-rubl
            , output buf-price-doc-forming-gds.road-tax-base
            , output buf-price-doc-forming-gds.road-tax-doc
            , output buf-price-doc-forming-gds.road-tax-rubl
            , output buf-price-doc-forming-gds.excise-base
            , output buf-price-doc-forming-gds.excise-doc
            , output buf-price-doc-forming-gds.excise-rubl
            , output buf-price-doc-forming-gds.vat-pc
            , output buf-price-doc-forming-gds.slt-pc
            , output buf-price-doc-forming-gds.prev-doc-code
            , output buf-price-doc-forming-gds.d-pcnt
            ) no-error .
          if error-status :error then do :
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "calc-price-line"
              view-as alert-box error
            .
            undo calc-sub, return error.
            end.
      /* отмечаем, что нужно переоткрыть весь browse, потому что пересчитывалась
          не только главная цена,
          а также для reposition */
      calc-rec = recid (buf-price-doc-forming-gds).
    end.
    /* считаем все неосновные цены для товара, в т.ч. для которых нет основных */
    for each  buf-price-doc-forming-gds exclusive-lock where
              buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
              buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
              buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
              buf-price-doc-forming-gds.plt-db-num    = buf-price-doc-forming.plt-db-num and
              buf-price-doc-forming-gds.artic      = buf-goods.artic and
              buf-price-doc-forming-gds.prod-type  = buf-goods.prod-type and
              buf-price-doc-forming-gds.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-doc-forming-gds.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base ,
        first buf-gds-prt no-lock where
              buf-gds-prt.node-code = buf-bar-code.node-code /* and
              buf-gds-prt.upper-code <> buf-goods.prt-root   */
        on error undo calc-sub, return error:
        /*
        run calc-price-alt in this-procedure
            (input  buf-price-doc-forming-gds.b-code
            ,input  p-recid
            ,input  /* buf-price-doc-forming-gds.d-pcnt */ increase-pc
            ,input  round-method
            ,input  round-base
            ,output buf-price-doc-forming-gds.price-sale-base
            ,output buf-price-doc-forming-gds.price-sale-doc
            ,output buf-price-doc-forming-gds.price-sale-rubl
            ) no-error .

      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "calc-price-alt"
          view-as alert-box error
        .
        undo calc-sub, return error.
      end.
      */
    end.
  end.
  else do:
    /* нужно считать неосновные для 1 кода - менялась основная неглавная цена */
    /*
    run calc-base-update in this-procedure
      (input buf-bar-code.b-code,
      input p-recid,
      input round-method,
      input round-base) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "calc-base-update"
        view-as alert-box error
      .
      undo calc-sub, return error.
    end.
    */
  end.
end.
end procedure. /* calc-price-sub */


procedure calc-base-update :
/* ---------------------------------------------------------------------------------------------------------------------------------
   Пересчитывает все неосновные по одному основному
------------------------------------------------------------------------------------------------------------------------------------ */
define input parameter bc           like ub.bar-code.b-code   no-undo.
define input parameter p-recid      as recid no-undo .
define input parameter round-method as character    no-undo. /* способ округления */
define input parameter round-base   as decimal      no-undo. /* база для округления / коэффициент */

define buffer alt-bar-code              for ub.bar-code.
define buffer alt-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-bar-code              for ub.bar-code.
define buffer buf-goods                 for ub.goods.
define buffer buf-price-doc-forming     for ub.price-doc-forming  .

calc-base:
do on error undo calc-base, return error :

  find  buf-price-doc-forming no-lock where
        recid (buf-price-doc-forming) =  p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.

  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-doc-forming-gds exclusive-lock where
            alt-price-doc-forming-gds.pdf-id      = buf-price-doc-forming.pdf-id and
            alt-price-doc-forming-gds.plt-id      = buf-price-doc-forming.plt-id and
            alt-price-doc-forming-gds.pdf-db      = buf-price-doc-forming.pdf-db and
            alt-price-doc-forming-gds.plt-db-num  = buf-price-doc-forming.plt-db-num and
            alt-price-doc-forming-gds.b-code      = alt-bar-code.b-code
      on error undo calc-base, return error:
    /* неосновная цена */
  run calc-price-alt in this-procedure
      ( input  alt-price-doc-forming-gds.b-code
      , input  p-recid
      , input  alt-price-doc-forming-gds.d-pcnt
      , input  round-method
      , input  round-base
      , output alt-price-doc-forming-gds.price-sale-base
      , output alt-price-doc-forming-gds.price-sale-doc
      , output alt-price-doc-forming-gds.price-sale-rubl
      ) no-error .

    if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "calc-price-alt"
      view-as alert-box error
    .
      undo calc-base, return error.
    end.
  end.

end.
end procedure. /* calc-base-update */

define temp-table temp-exp-partbc no-undo
field b-code  as integer
index pi b-code
.

procedure expose-prt :
/* ------------------------------------------------------------------------------------------------------------------------
   разворачивание спеццен по главной цене, если есть настройки
   ------------------------------------------------------------------------------------------------------------------------*/
define input  parameter p-calc-method  as character no-undo .
define input  parameter p-increase-pc as decimal   no-undo .
define input  parameter p-main-code    like ub.goods.gds-code    no-undo.
define input  parameter old-recid      as recid no-undo .  /* ДНЦ */
define input  parameter new-recid      as recid no-undo .
define input  parameter p-round-method as character no-undo .
define input  parameter p-round-base   as decimal   no-undo .
define input  parameter v-doc-code     as character no-undo .
define input  parameter v-common-price as decimal   no-undo .
define input  parameter v-copy-type    as character no-undo .
define input  parameter v-copy-code    as integer   no-undo .
define input-output parameter v-line-num as integer   no-undo .
define input-output parameter v-sec      as integer   no-undo .
define output parameter new-rec-str      as recid   no-undo.

define buffer buf-bar-code              for ub.bar-code.
define buffer buf-goods                 for ub.goods.
define buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-price-list            for ub.price-doc-forming-gds.
define buffer buf-price-doc-forming     for ub.price-doc-forming.
define buffer new-price-doc-forming     for ub.price-doc-forming.
define buffer new-price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf-gds-prt               for ub.gds-prt  .
define buffer buf_parts for ub.parts  .
define buffer buf_goods for ub.goods  .

  do
  on error undo, return error return-value
  :

  find  buf-price-doc-forming no-lock where
        recid(buf-price-doc-forming) = old-recid .
  find  new-price-doc-forming no-lock where
        recid(new-price-doc-forming) = new-recid .

  find  buf-bar-code no-lock where
        buf-bar-code.b-code = p-main-code.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.


  find  buf-price-doc-forming-gds no-lock  where
        buf-price-doc-forming-gds.pdf-id = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db     = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code  = p-main-code no-error .
  if error-status :error then return .

  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.

/* Добавлять имеющиеся неосновные цены */
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
for each  buf-price-list where
          buf-price-list.pdf-id = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code and
          buf-price-list.artic       = buf-goods.artic  and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code
          ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli <> buf-goods.unit-base:
  /* найдена неосновная цена */

   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input  v-doc-code
        ,input  v-common-price
        ,input  v-copy-type
        ,input  v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .

  if error-status:error then do:
    message
      "Ошибка cre-pr-list."                skip
      "Код:" buf-bar-code.b-code           skip
      error-status :get-message(1)         skip
      return-value                         skip
       "pdf" new-price-doc-forming.pdf-id  skip
      view-as alert-box.
    next.
  end.
end.

end.

/* Добавлять имеющиеся цены признаков */
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
for each  buf-price-list where
          buf-price-list.pdf-id = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code and
          buf-price-list.artic       = buf-goods.artic  and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code  ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli = buf-goods.unit-base and
          buf-bar-code.in-code = ""
          :
  /* цены признаков */

   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .

      if error-status:error then do:
        message
          "Ошибка cre-pr-list.2" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.

end.

/* Добавлять имеющиеся цены партий */
if par-pr-parex = "yes" and
   par-pr-notls = "yes" then do:

define buffer bt_trn-doc  for ub.trn-doc  .
define buffer bf_parts    for ub.parts  .
define buffer free_parts  for ub.parts  .
define buffer buf_gds-obj for ub.gds-obj  .

find first buf_gds-obj no-lock where
           buf_gds-obj.gds-code = buf-goods.gds-code and
           buf_gds-obj.obj-type = v-cntxt-obj-type   and
           buf_gds-obj.obj-code = v-cntxt-obj-code   and
           buf_gds-obj.cash-parts = true
           no-error .
if not available buf_gds-obj then return .


 find first bt_trn-doc no-lock where
            bt_trn-doc.doc-code = v-doc-code no-error .

 if v-doc-code <> "" and available bt_trn-doc then do:

 for each temp-exp-partbc :
     delete temp-exp-partbc.
 end.

 /* Партии документа */

 for each bf_parts no-lock where
          bf_parts.out-code   = bt_trn-doc.doc-code and
          bf_parts.obj-type   = bt_trn-doc.obj-type and
          bf_parts.obj-code   = bt_trn-doc.obj-code and
          bf_parts.artic      = buf-goods.artic     and
          bf_parts.prod-type  = buf-goods.prod-type and
          bf_parts.prod-code  = buf-goods.prod-code  ,
        first free_parts no-lock where
              free_parts.in-code   = bf_parts.in-code   and
              free_parts.part-code = bf_parts.part-code and
              free_parts.out-code  = {&free-code}       and
              free_parts.rsrv-free = true               and
              free_parts.status_   = false              and
              free_parts.obj-type  = bf_parts.obj-type  and
              free_parts.obj-code  = bf_parts.obj-code  and
              free_parts.artic     = bf_parts.artic     and
              free_parts.prod-type = bf_parts.prod-type and
              free_parts.prod-code = bf_parts.prod-code ,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = bf_parts.in-code and
              buf-bar-code.part-code = bf_parts.part-code
              :

  /* цены партий */
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .

      if error-status:error then do:
        message
          "Ошибка cre-pr-list.3-" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.

      create temp-exp-partbc.
      assign
         temp-exp-partbc.b-code = buf-bar-code.b-code
      .
 end.
end.

/* Партии из старой переоценки */
for each  buf-price-list where
          buf-price-list.pdf-id     = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id     = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code         and
          buf-price-list.artic       = buf-goods.artic     and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli = buf-goods.unit-base and
          buf-bar-code.in-code <> "" ,
    first buf_parts no-lock where
          buf_parts.out-code    = {&free-code} and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code and
          buf_parts.obj-type   = v-cntxt-obj-type and
          buf_parts.obj-code   = v-cntxt-obj-code and
          buf_parts.part-code   = buf-bar-code.part-code and
          buf_parts.in-code     = buf-bar-code.in-code
          :
          find first temp-exp-partbc where
                     temp-exp-partbc.b-code = buf-bar-code.b-code no-error .
        if available temp-exp-partbc then next.

  /* цены партий без изменений */
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  {&pr-calc-old}
        ,input  0
        ,input  {&pr-round-off}
        ,input  0
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .

      if error-status:error then do:
        message
          "Ошибка cre-pr-list.3" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.

/* непереоцененные Партии  свободной зоны не вошедшие в текущий ДНЦ*/
  for each buf_parts no-lock where
          buf_parts.out-code    = {&free-code} and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code and
          buf_parts.obj-type    = v-cntxt-obj-type and
          buf_parts.obj-code    = v-cntxt-obj-code and
          buf_parts.part-code   = buf-bar-code.part-code and
          buf_parts.in-code     = buf-bar-code.in-code,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = buf_parts.in-code and
              buf-bar-code.part-code = buf_parts.part-code

          :
          find first temp-exp-partbc where
                     temp-exp-partbc.b-code = buf-bar-code.b-code no-error .
        if available temp-exp-partbc then next.

          find first new-price-doc-forming-gds where
                     new-price-doc-forming-gds.pdf-id     = new-price-doc-forming.pdf-id and
                     new-price-doc-forming-gds.pdf-db     = new-price-doc-forming.pdf-db and
                     new-price-doc-forming-gds.plt-id     = new-price-doc-forming.plt-id and
                     new-price-doc-forming-gds.plt-db-num = new-price-doc-forming.plt-db-num  and
                     new-price-doc-forming-gds.b-code = buf-bar-code.b-code
                     no-error .
        if available new-price-doc-forming-gds then next.


  /* цены партий без изменений */
   run create-calc-bc in this-procedure
       ( input recid( new-price-doc-forming )
        ,input {&pr-calc-old}
        ,input 0
        ,input {&pr-round-off}
        ,input 0
        ,input buf-bar-code.b-code
        ,input buf-goods.gds-code
        ,input buf-goods.artic
        ,input buf-goods.prod-type
        ,input buf-goods.prod-code
        ,input new-price-doc-forming.base-rate
        ,input new-price-doc-forming.base-scale
        ,input new-price-doc-forming.exch-scale
        ,input new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .

      if error-status:error then do:
        message
          "Ошибка cre-pr-list.4" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.

end.
  end.

end procedure.

procedure create-calc-bc :
define input parameter  v-new-recid as recid no-undo .
define input parameter  p-calc-method  as character no-undo .
define input parameter  p-increase-pc  as decimal   no-undo .
define input parameter  round-method as character no-undo .
define input parameter  round-base   as decimal   no-undo .
define input parameter  p-b-code     as integer   no-undo .
define input parameter  p-gds-code   as integer   no-undo .
define input parameter  p-artic      as character no-undo .
define input parameter  p-prod-type  as character no-undo .
define input parameter  p-prod-code  as integer   no-undo .
define input parameter  v-base-rate  as decimal   no-undo .
define input parameter  v-base-scale as decimal   no-undo .
define input parameter  v-exch-scale as decimal   no-undo .
define input parameter  v-exch-rate  as decimal   no-undo .
define input parameter  v-doc-code   as character no-undo .
define input parameter  v-common-price as decimal   no-undo .
define input parameter  v-copy-type as character no-undo .
define input parameter  v-copy-code as integer   no-undo .
define input-output parameter v-line-num as integer   no-undo .
define input-output parameter v-sec     as integer   no-undo .


define buffer buf_price-doc-forming for ub.price-doc-forming  .

define variable v-price-calc-base as decimal   no-undo .
define variable v-price-calc-doc  as decimal   no-undo .
define variable v-price-calc-rubl as decimal   no-undo .
define variable v-price-prev-base as decimal   no-undo .
define variable v-price-prev-doc  as decimal   no-undo .
define variable v-price-prev-rubl as decimal   no-undo .
define variable v-price-sale-base as decimal   no-undo .
define variable v-price-sale-doc  as decimal   no-undo .
define variable v-price-sale-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-doc    as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-doc      as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .
define variable v-vat-pc          as decimal   no-undo .
define variable v-slt-pc          as decimal   no-undo .
define variable v-prev-doc-code   as character no-undo .
define variable v-d-pcnt as decimal   no-undo .

  do
  on error undo, return error return-value
  :

  find  buf_price-doc-forming no-lock where
        recid(buf_price-doc-forming) = v-new-recid no-error .
   if error-status :error then return error error-status :get-message(1) .
   v-line-num = v-line-num + 1.
   run calc-price-line  in this-procedure (
     input  p-calc-method
   , input  p-increase-pc
   , input  round-method
   , input  round-base
   , input  p-b-code
   , input  p-gds-code
   , input  p-artic
   , input  p-prod-type
   , input  p-prod-code
   , input  v-base-rate
   , input  v-base-scale
   , input  v-exch-scale
   , input  v-exch-rate
   , input  v-doc-code
   , input  v-common-price
   , input  v-copy-type
   , input  v-copy-code
   , output p-calc-method
   , output v-price-calc-base
   , output v-price-calc-doc
   , output v-price-calc-rubl
   , output v-price-prev-base
   , output v-price-prev-doc
   , output v-price-prev-rubl
   , output v-price-sale-base
   , output v-price-sale-doc
   , output v-price-sale-rubl
   , output v-road-tax-base
   , output v-road-tax-doc
   , output v-road-tax-rubl
   , output v-excise-base
   , output v-excise-doc
   , output v-excise-rubl
   , output v-vat-pc
   , output v-slt-pc
   , output v-prev-doc-code
   , output v-d-pcnt
   ) no-error .
   if error-status :error then
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "123calc-price-line"
     "p-calc-method     "  p-calc-method     skip
     "p-increase-pc     "  p-increase-pc     skip
     "round-method      "    round-method    skip
     "round-base        "    round-base      skip
     "p-b-code          "    p-b-code        skip
     "p-gds-code        "    p-gds-code      skip
     "p-artic           "    p-artic         skip
     "p-prod-type       "    p-prod-type     skip
     "p-prod-code       "    p-prod-code     skip
     "v-base-rate       "   v-base-rate     skip
     "v-base-scale      "  v-base-scale    skip
     "v-exch-scale      "  v-exch-scale    skip
     "v-exch-rate       "  v-exch-rate     skip
     "v-doc-code        "  v-doc-code      skip
     "v-common-price    "  v-common-price  skip
     "v-copy-type       "  v-copy-type     skip
     "v-copy-code       "  v-copy-code     skip
     "v-d-pcnt          "  v-d-pcnt
     view-as alert-box error
   .
   /* создать главную цену main-price */
   run create-line  in this-procedure (
     buf_price-doc-forming.plt-db-num
    ,buf_price-doc-forming.plt-id
    ,buf_price-doc-forming.pdf-db
    ,buf_price-doc-forming.pdf-id
    ,v-line-num
    ,p-b-code
    ,p-artic
    ,p-prod-type
    ,p-prod-code
    ,p-calc-method
    ,v-d-pcnt
    ,buf_price-doc-forming.have-start-period
    ,buf_price-doc-forming.start-date
    ,buf_price-doc-forming.start-shift-date
    ,buf_price-doc-forming.start-shift-name
    ,buf_price-doc-forming.start-shift-num
    ,buf_price-doc-forming.start-sys-date
    ,buf_price-doc-forming.start-sys-time
    ,buf_price-doc-forming.have-end-period
    ,buf_price-doc-forming.end-date
    ,buf_price-doc-forming.end-shift-date
    ,buf_price-doc-forming.end-shift-name
    ,buf_price-doc-forming.end-shift-num
    ,buf_price-doc-forming.end-sys-date
    ,buf_price-doc-forming.end-sys-time
    ,v-price-calc-base
    ,v-price-calc-doc
    ,v-price-calc-rubl
    ,v-price-prev-base
    ,v-price-prev-doc
    ,v-price-prev-rubl
    ,v-price-sale-base
    ,v-price-sale-doc
    ,v-price-sale-rubl
    ,v-road-tax-base
    ,v-road-tax-doc
    ,v-road-tax-rubl
    ,v-excise-base
    ,v-excise-doc
    ,v-excise-rubl
    ,v-vat-pc
    ,v-slt-pc
    ,v-prev-doc-code
    ,0
    ,input-output v-sec
     ) no-error  .
     if error-status :error then
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "4567"
       view-as alert-box error
     .

  end.

end procedure. /* create-calc-bc */

procedure re-define :
define input-output parameter p-calc-method      as character no-undo .
define input        parameter p-gds-code         as integer   no-undo .
  do
  on error undo, return error return-value
  :
define buffer buf_goods for ub.goods  .
define buffer buf_gds-grp for ub.gds-grp  .
    case p-calc-method :
      when {&pr-calc-goods} then do:
           find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
                case buf_goods.calc-method:
                  when {&pr-calc-grp} then do:
                    find first buf_gds-grp no-lock where
                               buf_gds-grp.node-code = buf_goods.grp-code no-error .
                    p-calc-method  = buf_gds-grp.calc-method.
                  end.
                otherwise do:
                    p-calc-method  =  buf_goods.calc-method .
                end.
                end case.
           run  re-define in this-procedure (
                      input-output  p-calc-method ,
                      input p-gds-code )  .
      end.
      when {&pr-calc-grp} then do:
           find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
           find first buf_gds-grp no-lock where
                      buf_gds-grp.node-code = buf_goods.grp-code no-error .
           run re-define in this-procedure (
                      input-output buf_gds-grp.calc-method ,
                      input p-gds-code )  .
      end.
      when {&pr-calc-cost} or
      when {&pr-calc-costobj} then do:
           p-calc-method = {&pr-calc-cost-gr} .
      end.
      when {&pr-calc-rsrv} then do:
           p-calc-method = {&pr-calc-rsrv-gr}.
      end.
      when {&pr-calc-last} or
      when {&pr-calc-lastobj} then do:
           p-calc-method = {&pr-calc-last-gr}.
      end.
      when {&pr-calc-cost-novat} then do:
           p-calc-method = {&pr-calc-cost-novat-gr} .
      end.
    end case.

  end.
end procedure. /* re-define */


procedure create-line-pdf-mpl-lib :
/* Создание строки ДНЦ, шапка документа уже есть*/
define input  parameter  p-plt-db-num as integer   no-undo .
define input  parameter  p-plt-id     as integer   no-undo .
define input  parameter  p-pdf-db     as integer   no-undo .
define input  parameter  p-pdf-id     as integer   no-undo .
define input  parameter  p-line-num   as integer   no-undo .
define input  parameter  p-b-code     as integer   no-undo .
define input  parameter  p-artic      as character no-undo .
define input  parameter  p-prod-type  as character no-undo .
define input  parameter  p-prod-code  as integer   no-undo .
define input  parameter  p-met    as character no-undo .
define input  parameter  p-d-pcnt as decimal   no-undo .
define input  parameter  p-price  as decimal   no-undo .
define input  parameter  p-out-code as character no-undo .
define input  parameter  p-stts as integer   no-undo .
define input-output  parameter v-sec   as integer   no-undo .

define variable v-price-calc-base  as decimal   no-undo .
define variable v-price-calc-doc   as decimal   no-undo .
define variable v-price-calc-rubl  as decimal   no-undo .
define variable v-price-prev-base  as decimal   no-undo .
define variable v-price-prev-doc   as decimal   no-undo .
define variable v-price-prev-rubl  as decimal   no-undo .
define variable v-price-sale-base  as decimal   no-undo .
define variable v-price-sale-doc   as decimal   no-undo .
define variable v-price-sale-rubl  as decimal   no-undo .
define variable v-road-tax-base    as decimal   no-undo .
define variable v-road-tax-doc     as decimal   no-undo .
define variable v-road-tax-rubl    as decimal   no-undo .
define variable v-excise-base      as decimal   no-undo .
define variable v-excise-doc       as decimal   no-undo .
define variable v-excise-rubl      as decimal   no-undo .

define variable V-base-rate       as decimal   no-undo .
define variable V-base-scale      as decimal   no-undo .
define variable V-exch-scale      as decimal   no-undo .
define variable V-exch-rate       as decimal   no-undo .
define variable v-curr-abbr as character no-undo .
define variable p-vat-pc as decimal   no-undo .
define variable p-slt-pc as decimal   no-undo .
  do
  on error undo, return error return-value
  :

find first ub.price-list-type  no-lock  where
           ub.price-list-type.plt-db-num = p-plt-db-num  and
           ub.price-list-type.plt-id     = p-plt-id
           no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.

find first ub.price-doc-forming no-lock  where
           ub.price-doc-forming.plt-db-num = p-plt-db-num and
           ub.price-doc-forming.plt-id     = p-plt-id     and
           ub.price-doc-forming.pdf-db     = p-pdf-db     and
           ub.price-doc-forming.pdf-id     = p-pdf-id
            no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.
find first ub.goods no-lock where
 ub.goods.artic = p-artic and
 ub.goods.prod-type = p-prod-type and
 ub.goods.prod-code = p-prod-code no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.

if ub.price-list-type.fix-cource-crc-base = true then do:
    assign
      V-base-rate  = ub.price-doc-forming.base-rate
      V-base-scale = ub.price-doc-forming.base-scale
    .
end.
else do:
/* узнаем на сейчас курс базвал по текущей фирме */
   { gbl/baserate.i
     v-cntxt-host-code-obj
     today
     v-base-rate
     v-base-scale }
end.

if ub.price-list-type.fix-cource-crc-doc = true then do:
    assign
      V-exch-rate  = ub.price-doc-forming.exch-rate
      V-exch-scale = ub.price-doc-forming.exch-scale
    .
end.
else do:
/* узнаем на сейчас курс валюты документа */
   { gbl/exchrate.i
     ub.price-list-type.curr-code
     today
     v-exch-rate
     v-exch-scale
     v-curr-abbr  }
end.

define variable p-new-calc-method as character no-undo .
define variable v-prev-doc-code as character no-undo .
define variable v-d-pcnt as decimal   no-undo .
if ub.price-list-type.main then do:
run calc-price-line in this-procedure (
/* установка заданной продажной цены , так же как и Расчет продажной цены */
 input  {&pr-common}
,input  0
,input  {&pr-round-off} /*price-list-type.calc-round-method*/
,input  0               /*price-list-type.calc-round-base*/
,input  p-b-code
,input  ub.goods.gds-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  V-base-rate
,input  V-base-scale
,input  V-exch-scale
,input  V-exch-rate
,input  ""
,input  p-price
,input  ""
,input  ?
,output p-new-calc-method
,output v-price-calc-base
,output v-price-calc-doc
,output v-price-calc-rubl
,output v-price-prev-base
,output v-price-prev-doc
,output v-price-prev-rubl
,output v-price-sale-base
,output v-price-sale-doc
,output v-price-sale-rubl
,output v-road-tax-base
,output v-road-tax-doc
,output v-road-tax-rubl
,output v-excise-base
,output v-excise-doc
,output v-excise-rubl
,output p-vat-pc
,output p-slt-pc
,output v-prev-doc-code
,output v-d-pcnt
).
end.
else do:
run set-price-line in this-procedure (
/* установка заданной продажной цены  для неглавного ТПЛ  */
 input p-plt-id
,input p-plt-db-num
,input  {&pr-common}
,input  0
,input  {&pr-round-off}
,input  0
,input  p-b-code
,input  ub.goods.gds-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  V-base-rate
,input  V-base-scale
,input  V-exch-scale
,input  V-exch-rate
,input  ""
,input  p-price
,input  ""
,input  ?
,output p-new-calc-method
,output v-price-calc-base
,output v-price-calc-doc
,output v-price-calc-rubl
,output v-price-prev-base
,output v-price-prev-doc
,output v-price-prev-rubl
,output v-price-sale-base
,output v-price-sale-doc
,output v-price-sale-rubl
,output v-road-tax-base
,output v-road-tax-doc
,output v-road-tax-rubl
,output v-excise-base
,output v-excise-doc
,output v-excise-rubl
,output p-vat-pc
,output p-slt-pc
,output v-prev-doc-code
,output v-d-pcnt
) no-error .
if error-status :error then do:
   message
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
end.

end.
run create-line (
 input  p-plt-db-num
,input  p-plt-id
,input  p-pdf-db
,input  p-pdf-id
,input  p-line-num
,input  p-b-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  p-met
,input  p-d-pcnt
,input  price-doc-forming.have-start-period
,input  price-doc-forming.start-date
,input  price-doc-forming.start-shift-date
,input  price-doc-forming.start-shift-name
,input  price-doc-forming.start-shift-num
,input  price-doc-forming.start-sys-date
,input  price-doc-forming.start-sys-time
,input  price-doc-forming.have-end-period
,input  price-doc-forming.end-date
,input  price-doc-forming.end-shift-date
,input  price-doc-forming.end-shift-name
,input  price-doc-forming.end-shift-num
,input  price-doc-forming.end-sys-date
,input  price-doc-forming.end-sys-time
,input  v-price-calc-base
,input  v-price-calc-doc
,input  v-price-calc-rubl
,input  v-price-prev-base
,input  v-price-prev-doc
,input  v-price-prev-rubl
,input  v-price-sale-base
,input  v-price-sale-doc
,input  v-price-sale-rubl
,input  v-road-tax-base
,input  v-road-tax-doc
,input  v-road-tax-rubl
,input  v-excise-base
,input  v-excise-doc
,input  v-excise-rubl
,input  p-vat-pc
,input  p-slt-pc
,input  p-out-code
,input  p-stts
,input-output v-sec   ).


  end.

end procedure. /* create-line-pdf */


procedure main-road-taxs :
define input param p-artic     like ub.gds-obj.artic     no-undo .
define input param p-prod-type like ub.gds-obj.prod-type no-undo .
define input param p-prod-code like ub.gds-obj.prod-code no-undo .
define input-output param p-road-tax-base as decimal no-undo .
define input-output param p-road-tax-rubl as decimal no-undo .
{ str/in-vatp.i def }
  do
  on error undo, return error return-value
  :
define buffer buff-goods   for ub.goods    .
define buffer buf_gds-obj  for ub.gds-obj  .
define buffer buf_parts    for ub.parts    .
define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .

define variable is-petrolium as logical   no-undo .
define variable is-pieces   as  logical   no-undo .
define variable p-in-code   as  character no-undo .
define variable p-obj-type  as  character no-undo .
define variable p-obj-code  as  integer   no-undo .

define variable v-rec as recid no-undo .
define variable t-ret as logical no-undo .
define variable v-total-avrg-base as decimal no-undo .
define variable v-total-avrg-rubl as decimal no-undo .
define variable v-total-avrg-qnty as decimal no-undo .
define variable v-total-road-tax-base     as decimal no-undo .
define variable v-total-road-tax-rubl     as decimal no-undo .
define variable v-all-total-road-tax-base as decimal no-undo .
define variable v-all-total-road-tax-rubl as decimal no-undo .

assign
  p-road-tax-base = 0
  p-road-tax-rubl = 0
  .
  Find first buff-goods no-lock where
             buff-goods.artic     = p-artic and
             buff-goods.prod-type = p-prod-type and
             buff-goods.prod-code = p-prod-code
      no-error .
      if available buff-goods then do:     /* Проверочка наличия Третьего налога */
         v-rec = recid (buff-goods).
         t-ret =  session:SET-WAIT-STATE("GENERAL") .
          { str/is-petrl.i
            p-artic
            p-prod-type
            p-prod-code
            is-petrolium
            is-pieces
           }
           t-ret =  session:SET-WAIT-STATE("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
              assign
                p-road-tax-base = 0
                p-road-tax-rubl = 0
                .
               return.
           end.
      end.

      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .
      /*
        возвращается средняя учетная цена положительных партий свободной зоны по объекту
        не учитываются партии зарезервированные за незакрытыми документами
      */
    for each  x_obj-group ,
        each buf_parts no-lock
        where buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = {&free-code}  /* только партии свободной зоны */
          and buf_parts.qnty      > 0             /* только положительные партии  */
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
         { str/in-vatp.i calc-parts buf_parts. buf_td. g }

        assign
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
     end.
      if v-total-avrg-qnty > 0 then  do :
      assign
          p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
          p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
          .
      end.

      if v-total-avrg-qnty <= 0 then do :
          run last-incom-S in this-procedure
             ( input p-artic
              ,input p-prod-type
              ,input p-prod-code
              ,output p-in-code
              ,output p-obj-type
              ,output p-obj-code ).
            /* состав последнего прихода */
            find first  buf_trn-doc no-lock  where buf_trn-doc.doc-code  = p-in-code no-error .
            find first  buf_doc-line no-lock where  buf_doc-line.doc-code = p-in-code
                    and buf_doc-line.artic     = p-artic
                    and buf_doc-line.prod-type = p-prod-type
                    and buf_doc-line.prod-code = p-prod-code
            no-error.
            if available buf_doc-line then do :
              { str/in-vatp.i calc buf_doc-line. buf_trn-doc. g }
              assign
                p-road-tax-rubl =  road-tax-rubl-loc
                p-road-tax-base =  road-tax-base-loc
                .
            end.
      end.
  end.

end procedure. /* main-road-taxs */

procedure calc-sigma :
 do
 on error undo, return error return-value
 :
define input parameter l-bcode like ub.price-list.b-code no-undo .
define input-output parameter new-price as decimal no-undo .
define input parameter l-host as integer no-undo .
define input parameter l-code as integer no-undo .
define input parameter l-type as character no-undo .
define output parameter p-ret as logical no-undo .

/*define variable par-pr-sigma as character no-undo. */   /* для чтения параметра конфигурации отклонения */
define variable conf-par     as character no-undo.    /* для чтения параметра конфигурации */
define variable par-type     as character no-undo.    /* тип параметра конфигурации        */
define variable i-sigma as decimal no-undo .

define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable old-price as decimal no-undo .


p-ret = true  . /* менять */

if par-pr-sigma <> ? and par-pr-sigma <> "" and par-pr-sigma <> "0" then do:
/* ищем предыдущий прайс-лист для этого объекта */
{ gbl/bcodeprc.i
  l-type
  l-code
  l-bcode
  0
  0
  cur-dn
  cur-pr
  cur-rt
  cur-ex }

old-price = cur-pr .
if old-price =  new-price then do:
   p-ret = true .
   return.
end.
   i-sigma = decimal(par-pr-sigma) .

   if ( 100 * ABSOLUTE( old-price - new-price ) / old-price ) <= i-sigma then do:
       p-ret = false .
       new-price = old-price.
       end.
   else p-ret = true .
end.

 end. /* do */
end procedure. /* calc-sigma */

