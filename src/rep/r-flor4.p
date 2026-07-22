block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-flor4.p $
$Archive: rep/r-flor4.p $

Форма документов заказ для флористов форма № 2

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 01/19/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-flor4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-flor4.p $":U .
define variable vss-description as character no-undo init "Форма документов заказ для флористов форма № 2".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ rep/r-cliprp.i def }
{ cmp/r-page1.i  new}

{ gbl/waitfram.i }
{ str/trdcalib.i }
{ gbl/lineattr.i }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ gbl/getcntxt.i def }

&glob format-sl "X(136)"

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.

def stream OutStream.
define stream  macr_excel .
def var    NAme1   as character no-undo .
def var    Adres1 as character no-undo .
def var    NAme2   as character no-undo .
def var    Adres2  as character no-undo .
def var    Adres3  as character no-undo .
define variable v-time      as character no-undo .
define variable  v-ord_date   as character no-undo .

def     var     PrintScale      as   logical     no-undo.
def     var     CostPrice      as   logical     no-undo.
def buffer This_Object for  ub.clients .
def buffer gds-prt-1 for  ub.gds-prt .
def buffer bar-code-1 for ub.bar-code .

def var LineBuf       as char    no-undo.
def var Line       as char    no-undo.
def var UndLine    as char    no-undo.

def var     Lines_Counter as   int  init 0  no-undo.
def var     Tmp_Counter   as   int  init 0  no-undo.

def var     tdoc-date     like ub.trn-doc.doc-date no-undo.
def var     tdoc-code     like ub.trn-doc.doc-code no-undo.

def var  Control_sUM       as  dec no-undo.
def var  Control_Qnty      as  dec no-undo.
def var  PgQnty            as  dec no-undo.
def var  PgSum             as  dec no-undo.
def var  PgQnty-b          as  dec no-undo.
def var  PgSum-b           as  dec no-undo.
def var  SQnty             as  dec no-undo.
def var  SSum              as  dec no-undo.
def var  SQnty-b           as  dec no-undo.
def var  SSum-b            as  dec no-undo.
def var  PropisQnty        as  char no-undo.
def var  PropisSum         as  char no-undo.
def var  PropisQnty-b      as  char no-undo.
def var  PropisSum-b       as  char no-undo.
def var B-Sum1 as decimal no-undo .
def var B-Sum as decimal no-undo .
def var B-Sum-qnty as decimal no-undo .

def var B-adress like ub.firm.addres1 no-undo .
def var B-phone  like ub.firm.phone no-undo .

def var  Propiscount       as  char no-undo.
def var  PropiscountP      as  char no-undo.
def var  abbr              as  char no-undo.
define variable pp as character no-undo .
def var tt    as int no-undo.
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable store-type      as character    no-undo.
define variable store-code      as integer      no-undo.

define variable v-itoggo      as character no-undo .

DEFINE FRAME sl
       HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Заказ N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 90 format "X(19)"
        string( " Лист " + string( PAGE-NUMBER(OutStream) , ">>9") ) format "X(13)" SKIP
        UndLine format {&format-sl} AT 1
        with width {&A4_CW0} down stream-io use-text NO-BOX.

define buffer nakl_trn-doc for ub.trn-doc.
define buffer buf_trn-doc for ub.trn-doc.

FIND nakl_trn-doc WHERE recid(nakl_trn-doc) = p-recid NO-LOCK .
find first  buf_trn-doc no-lock where buf_trn-doc.doc-code = nakl_trn-doc.out-code no-error .
if error-status :error then return .


assign
    tdoc-date = buf_trn-doc.doc-date
    tdoc-code = nakl_trn-doc.doc-code .

define variable  v-ord_time   as character no-undo .
define variable  v-dchek      as character no-undo .
define variable  v-befpay     as character no-undo .
define variable  v-ord_nchek  as character no-undo .
define variable  v-deliv      as character no-undo .
define variable  v-sumwrk     as character no-undo .
define variable  v-ord_adr    as character no-undo .
define variable  v-ord_hwo    as character no-undo .
define variable  v-type       as character no-undo .
define variable  v-postdchek  as character no-undo .
define variable  v-postpay    as character no-undo .
define variable  v-postNchek  as character no-undo .
define variable  v-ord_phone  as character no-undo .
define variable  v-ord_dl     as character no-undo .
define variable v-ord_contact as character no-undo .

&scop attr-temp-full-code ~{&v-code~} = "" . ~
~{ str/tdat-val.i ~
     nakl_trn-doc.doc-code  ~
     ~{&attr-code~}    ~
     ~{&v-code~}    ~
     v-type ~
~}

&scop attr-code {&trdcattr-frsrv-date}
&scop v-code           v-ord_date
{&attr-temp-full-code}

&scop attr-code {&trdcattr-ord_time}
&scop v-code           v-ord_time
{&attr-temp-full-code}
&scop attr-code {&trdcattr-dchek}
&scop v-code           v-dchek
{&attr-temp-full-code}
&scop attr-code {&trdcattr-befpay}
&scop v-code           v-befpay
{&attr-temp-full-code}
&scop attr-code {&trdcattr-ord_nchek}
&scop v-code           v-ord_nchek
{&attr-temp-full-code}
&scop attr-code {&trdcattr-deliv}
&scop v-code           v-deliv
{&attr-temp-full-code}
&scop attr-code {&trdcattr-sumwrk}
&scop v-code           v-sumwrk
{&attr-temp-full-code}
&scop attr-code {&trdcattr-ord_adr}
&scop v-code           v-ord_adr
{&attr-temp-full-code}
&scop attr-code {&trdcattr-ord_hwo}
&scop v-code           v-ord_hwo
{&attr-temp-full-code}

&scop attr-code {&trdcattr-postdchek}
&scop v-code v-postdchek
{&attr-temp-full-code}

&scop attr-code {&trdcattr-postpay}
&scop v-code v-postpay
{&attr-temp-full-code}

&scop attr-code {&trdcattr-postNchek}
&scop v-code v-postNchek
{&attr-temp-full-code}

&scop attr-code {&trdcattr-ord_phone}
&scop v-code    v-ord_phone
{&attr-temp-full-code}

&scop attr-code {&trdcattr-ord_dl}
&scop v-code    v-ord_dl
{&attr-temp-full-code}

&scop attr-code {&trdcattr-ord_contact}
&scop v-code    v-ord_contact
{&attr-temp-full-code}

&scop attr-code {&trdcattr-discnt-stop}
&scop v-code    v-itoggo
{&attr-temp-full-code}



{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
assign
    store-type = v-cntxt-obj-type
    store-code = v-cntxt-obj-code
.

if session:set-wait-state("compiler") then.
{ cmp/open-out.i STREAM OutStream " " {&CS_PS} }

assign
  Line    = fill("-", 136)
  UndLine = fill("_", 136)
  LineBuf = fill("_", 136) .
 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.

if buf_trn-doc.exch-code = 0 then
    assign
        PrintRubl = true
        pp = "{&abbr_rub}"
    .
else do:
   FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = buf_trn-doc.exch-code.
   assign
        PrintRubl = false
        pp = ub.currency.curr-abbr
        .
        end.

.

run waitfram-show ( {&mywaitmess} ) .


FIND This_Object  WHERE This_Object.obj-type = store-type
                    AND This_Object.obj-code = store-code NO-LOCK.

FIND ub.clients  WHERE ub.clients.obj-type = {&cmp}
                AND ub.clients.obj-code = buf_trn-doc.host-code NO-LOCK.

Case buf_trn-doc.cli-type :
    when  {&cmp} then do :
        FIND ub.firm  WHERE ub.firm.firm-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.firm.addres1
          b-phone  = ub.firm.phone .
        end.

    when  {&prs} then do :
        FIND ub.person  WHERE ub.person.psn-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.person.address
          b-phone  = ub.person.phone1 .
        end.

    when  {&shop} then do :
        FIND ub.shop  WHERE ub.shop.obj-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.shop.addres1
          b-phone  = ub.shop.phone .
        end.

    when  {&stock} then do :
        FIND ub.store  WHERE ub.store.obj-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.store.addres1
          b-phone  = ub.store.phone .
        end.
 End case.

define variable v-manag    as character no-undo init "".
define variable v-type-pay as character no-undo init "".

define buffer mn_clients for ub.clients.
find first mn_clients no-lock where mn_clients.obj-code = buf_trn-doc.boss and
                                    mn_clients.obj-type = {&prs} no-error .
if available mn_clients then v-manag  = mn_clients.obj-name.

find first ub.pay-type no-lock where ub.pay-type.obj-code = buf_trn-doc.pay-code no-error .
if available ub.pay-type then v-type-pay  = ub.pay-type.obj-name.



define buffer cl_clients for  ub.clients.
FIND cl_clients  WHERE cl_clients.obj-type = buf_trn-doc.cli-type
                   AND cl_clients.obj-code = buf_trn-doc.cli-code NO-LOCK.

{ rep/r-cliprp.i }
assign
  t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
  t-addres = t-addres
      + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
          then ""
          else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) + ", ")
        )
  t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
  t-addres = t-addres
      + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
      + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( trim( ub.firm.addres2 ) ) )
  t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
  t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else "" )
      + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
  t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
  t-addres = t-addres   + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
.

  Assign
   NAme1   = "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name )
   NAme2   = cl_clients.obj-name
   Adres1  = t-addres + "  " + t-phone
   Adres2  = b-adress + "  " + b-phone
   .

  Adres1  = " Адрес: " + t-addres + "  тел. " + t-phone .

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */

run macr_cell_size
( input   5 ,
 input   0 ,
 input   1 ,
 input   1 ,
 input   14,
 input   14).

num#str# = 1.    num#col# = 1.    run macr_excel_char ("Бланк заказа № 2"     , num#str# , num#col#   ) .
num#str# = 1.    num#col# = 10.   run macr_excel_char (cur-time-print()        , num#str# , num#col#   ) .
num#str# = 2.    num#col# = 1.    run macr_excel_char (string( Name1  )       , num#str# , num#col#   ) .
num#str# = 3.    num#col# = 1.    run macr_excel_char (substring(string( CAPS( This_Object.obj-name )  + Adres1 ) ,1,90)                           , num#str# , num#col#   ) .
num#str# = 4.    num#col# = 1.    run macr_excel_char (substring(string( CAPS( This_Object.obj-name )  + Adres1 ) ,91,255 )                           , num#str# , num#col#   ) .
run macr_cell_format ( 8 , false  , false, ?, 1, 1, 4 ,14 ).
put  stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4 ")' ,  4 , 1 , 4 ,  14 ) + {&new-line}  +
      'BORDER( 0,0,0,0,1, ,0,0,0,0,0) '  + {&new-line}
      .

num#str# = 5.    num#col# = 4.    run macr_excel_char ( string( "ЗАКАЗ № ") +  tdoc-code    + " от " + string(tdoc-date)  , num#str# , num#col#   ) .
run macr_cell_format ( 15 , true , false, ?, num#str#, num#col#, num#str#, num#col# ).

num#str# = 6.    num#col# = 1.    run macr_excel_char ("Срок исполнения"                                     , num#str# , num#col#   ) .
num#str# = 6.    num#col# = 5.    run macr_excel_char ( ":" + v-ord_date , num#str# , num#col#   ) .
num#str# = 7.    num#col# = 1.    run macr_excel_char ("Время "                                    , num#str# , num#col#   ) .
num#str# = 7.    num#col# = 5.    run macr_excel_char (":" + v-ord_time                            , num#str# , num#col#   ) .
num#str# = 8.    num#col# = 1.    run macr_excel_char ("Заказчик "                                 , num#str# , num#col#   ) .
num#str# = 8.    num#col# = 5.    run macr_excel_char ( ":" + name2                                , num#str# , num#col#   ) .
num#str# = 8.    num#col# = 10.   run macr_excel_char ("Тел."                                     , num#str# , num#col#   ) .
num#str# = 8.    num#col# = 12.   run macr_excel_char ( ":" + b-phone                             , num#str# , num#col#   ) .
num#str# = 9.    num#col# = 1.    run macr_excel_char ("№ клиента или карты"   , num#str# , num#col#   ) .
num#str# = 9.    num#col# = 5.    run macr_excel_char (":" +  string(cl_clients.obj-code) + " " + string(nakl_trn-doc.d-card)  , num#str# , num#col#   ) .
num#str# = 10.   num#col# = 1.    run macr_excel_char ("Контактное лицо "                                                        , num#str# , num#col#   ) .
num#str# = 10.   num#col# = 5.    run macr_excel_char ( ":" + v-ord_contact                                                              , num#str# , num#col#   ) .
num#str# = 10.   num#col# = 10.   run macr_excel_char ("Тел."                                      , num#str# , num#col#   ) .
num#str# = 10.   num#col# = 12.   run macr_excel_char (":" + v-ord_phone                           , num#str# , num#col#   ) .
num#str# = 11.   num#col# = 1.    run macr_excel_char ("Менеджер по заказам"                       , num#str# , num#col#   ) .
num#str# = 11.   num#col# = 5.    run macr_excel_char (":" + v-manag                               , num#str# , num#col#   ) .

num#str# = 12.   num#col# = 1.    run macr_excel_char ("Оплата "                                   , num#str# , num#col#   ) .
num#str# = 13.   num#col# = 1.    run macr_excel_char ("Вид "                                      , num#str# , num#col#   ) .
num#str# = 13.   num#col# = 5.    run macr_excel_char (":" + v-type-pay                  , num#str# , num#col#   ) .
num#str# = 14.   num#col# = 1.    run macr_excel_char ("Валюта "                         , num#str# , num#col#   ) .
num#str# = 14.   num#col# = 5.    run macr_excel_char (":" + pp                       , num#str# , num#col#   ) .
num#str# = 12.   num#col# = 10.    run macr_excel_char ("Предоплата "                              , num#str# , num#col#   ) .
num#str# = 12.   num#col# = 12.    run macr_excel_char (":" + v-befpay                             , num#str# , num#col#   ) .
num#str# = 13.   num#col# = 10.    run macr_excel_char ("Чек № " + ":" + v-ord_nchek + " от " + v-dchek                                   , num#str# , num#col#   ) .

num#str# = 14.   num#col# = 10.    run macr_excel_char ("Доплата "                              , num#str# , num#col#   ) .
num#str# = 14.   num#col# = 12.    run macr_excel_char (":" + v-postpay                             , num#str# , num#col#   ) .
num#str# = 15.   num#col# = 10.    run macr_excel_char ("Чек № " + ":" + v-postNchek + " от " + v-postdchek                                   , num#str# , num#col#   ) .

num#str# = 16.   num#col# = 1.    run macr_excel_char ("С доставкой? "             , num#str# , num#col#   ) .
num#str# = 16.   num#col# = 5.    run macr_excel_char ( ":" + ( if v-ord_dl = "yes"  then "ДА" else "НЕТ")   , num#str# , num#col#   ) .
num#str# = 17.   num#col# = 1.    run macr_excel_char ("Стоимость доставки   "                                             , num#str# , num#col#   ) .
num#str# = 17.   num#col# = 5.    run macr_excel_char (":" + v-deliv                                            , num#str# , num#col#   ) .


num#str# = 18.  num#col# = 5.    run macr_excel_char (":" + substring(v-ord_adr ,1 ,50)                        , num#str# , num#col#   ) .

if LENGTH(v-ord_adr) > 50 then do:
 num#str# = num#str# + 1.  num#col# = 5.    run macr_excel_char (      substring(v-ord_adr ,51,50)                      , num#str# , num#col#   ) .
end.
if LENGTH(v-ord_adr) > 100 then do:
 num#str# = num#str# + 1.  num#col# = 5.    run macr_excel_char (      substring(v-ord_adr ,101,50)                      , num#str# , num#col#   ) .
end.
if LENGTH(v-ord_adr) > 150 then do:
 num#str# = num#str# + 1.  num#col# = 5.    run macr_excel_char (      substring(v-ord_adr ,151,50)                      , num#str# , num#col#   ) .
end.
if LENGTH(v-ord_adr) > 200 then do:
 num#str# = num#str# + 1.  num#col# = 5.    run macr_excel_char (      substring(v-ord_adr ,201,50)                      , num#str# , num#col#   ) .
end.
if LENGTH(v-ord_adr) > 250 then do:
 num#str# = num#str# + 1.  num#col# = 5.    run macr_excel_char (      substring(v-ord_adr ,251,50)                      , num#str# , num#col#   ) .
end.

num#str# = 21.  num#col# = 1.    run macr_excel_char ("Кому   "                                        , num#str# , num#col#   ) .
num#str# = 21.  num#col# = 5.    run macr_excel_char (":" + v-ord_hwo                                          , num#str# , num#col#   ) .

num#str# = 22.  num#col# = 1.    run macr_excel_char ("Наценка за работу   "                                           , num#str# , num#col#   ) .
num#str# = 22.  num#col# = 5.    run macr_excel_char ("%:" + v-sumwrk                                           , num#str# , num#col#   ) .
num#str# = 23.  num#col# = 1.    run macr_excel_char ("Скидка клиента  "                        , num#str# , num#col#   ) .
num#str# = 23.  num#col# = 5.    run macr_excel_char ("%:" + string(nakl_trn-doc.discnt-pc)                        , num#str# , num#col#   ) .


/* ... конец создания заголовка. --- */
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define variable v-str as integer   no-undo .
define variable pos-start as integer   no-undo init 1 .
define variable v-i as integer   no-undo .
define variable v-all-sum as decimal   no-undo .
define variable v-sum as decimal   no-undo .

for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
find first buf_goods no-lock
     where buf_goods.artic      = buf_doc-line.artic
       and buf_goods.prod-type  = buf_doc-line.prod-type
       and buf_goods.prod-code  = buf_doc-line.prod-code .


    num#str# = num#str# + 1.  num#col# = 5 .
    run macr_excel_char (caps(buf_goods.gds-name), num#str# , num#col# ) .
    run macr_cell_format ( 15 , true , false, ?, num#str#, num#col#, num#str#, num#col# ) .
    num#str# = num#str# + 1.  num#col# = 1 .
    run macr_excel_char ("Описание:", num#str# , num#col# ) .

    find first buf_doc-line-attr no-lock where
            buf_doc-line-attr.doc-code = buf_doc-line.doc-code
        and buf_doc-line-attr.gds-code = buf_goods.gds-code
        and buf_doc-line-attr.attr-code = {&lineattr-flora_ps} no-error .
      if available buf_doc-line-attr then do:
    pos-start = 1 .
&scop dl_ 80
    v-str = integer(length (buf_doc-line-attr.attr-value) / {&dl_} ) + 1.
       repeat v-i = 1 to v-str :
        num#str# = num#str# + 1.  num#col# = 1.
        run macr_excel_char (substring (buf_doc-line-attr.attr-value , pos-start, {&dl_}), num#str# , num#col# ).
        pos-start = pos-start + {&dl_} .
       end.

    end.

num#str# = num#str# + 1.
/* ALIGNMENT(horiz_align, wrap, vert_align, orientation, add_indent) */
put  stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 1 , num#str#  ,  2 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line} +
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line} +
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 3 , num#str#  ,  8 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}   +
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line} +
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 9 , num#str#  , 10 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}      +
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line} +
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 11 , num#str#  , 12 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}         +
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line}  +
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 13 , num#str#  , 14 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line} +
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line}
      .
      run macr_excel_char ("Артикул", num#str# , 1 ) .
      run macr_excel_char ("Наименование товара", num#str# , 3 ) .
      run macr_excel_char ("Кол-во", num#str# , 9 ) .
      run macr_excel_char ("Цена", num#str# , 11 ) .
      run macr_excel_char ("Сумма", num#str# , 13 ) .

    run sost (input buf_goods.gds-code , output v-sum) .
    v-all-sum = v-all-sum  + v-sum .
end.




define variable v-proc as decimal   no-undo .
define variable v-procs as decimal   no-undo .
define variable v-proci as decimal   no-undo .
v-proc =  decimal (v-sumwrk) no-error .
if error-status :error then v-proc = 0.
v-procs = v-proc * v-all-sum / 100 .
v-proci = v-procS  + v-all-sum     .

/* ... Подвал. --- */
if nakl_trn-doc.status_ = {&fact} then do:
num#str# = num#str# + 1.
num#col# = 1.

 num#str# = num#str# + 1.  run macr_excel_char ( "Итого с учетом наценки"  , num#str# , num#col# ).
                           run macr_excel_char ( ":" + string( nakl_trn-doc.tot-sale - decimal(v-deliv), ">>>>>>>>>9.99")    , num#str# , 5 ).
 num#str# = num#str# + 1.  run macr_excel_char ( "Скидка клиента"      , num#str# , num#col# ).
                           run macr_excel_char ( ":" + string( nakl_trn-doc.discnt-rubl, ">>>>>>>>>9.99")                    , num#str# , 5 ).
 num#str# = num#str# + 1.   run macr_excel_char ("Стоимость доставки   "                                             , num#str# , num#col#   ) .
                            run macr_excel_char (":" + v-deliv                                            , num#str# ,5  ) .
 num#str# = num#str# + 1.  run macr_excel_char ( "ИТОГО ПО ЗАКАЗУ"             , num#str# , num#col# ).
                           run macr_excel_char ( ":" + string(round( decimal (v-itoggo),2 ) , ">>>>>>>>>9.99")                       , num#str# , 5 ).


end.
else do:
num#str# = num#str# + 1.
num#col# = 1.
num#str# = num#str# + 1.  run macr_excel_char ( "Итого со скидкой"   , num#str# , num#col# ).
run macr_excel_char ( ":" + string(v-all-sum , ">>>>>>>>>9.99")      , num#str# , 5).
num#str# = num#str# + 1.  run macr_excel_char ( "Наценка"            , num#str# , num#col# ).
run macr_excel_char ( ":" + string(v-procs, ">>>>>>>>>9.99")         , num#str# , 5 ).
num#str# = num#str# + 1.  run macr_excel_char ( "Итого с учетом наценки" , num#str# , num#col# ).
run macr_excel_char ( ":" + string(v-proci, ">>>>>>>>>9.99")             , num#str# , 5 ).
num#str# = num#str# + 1.  run macr_excel_char ( "Стоимость доставки  "   , num#str# , num#col#   ) .
run macr_excel_char ( ":" +  v-deliv                                     , num#str# , 5   ) .
num#str# = num#str# + 1.  run macr_excel_char ( "ИТОГО ПО ЗАКАЗУ "       , num#str# , num#col# ).
run macr_excel_char ( ":" + string(round( decimal (v-itoggo),2 ), ">>>>>>>>>9.99")         , num#str# , 5 ).

end.

/* ... конец создания Подвал. --- */

output stream OutStream CLOSE .
RUN waitfram-hide .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .

run end-proc in this-procedure .
Output stream Macr_Excel  close .
    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3,4,5"
        ) .

/*{ rep/q-print.i 0 }*/
def var v-user-action as character no-undo .
def var v-printed     as logical   no-undo .
 make-excel = true      .
 make-excel-com = false  .


run rep/runexcel.p ( v-file-name).


PROCEDURE on-same-page :
/* позволяет перейти к следующей странице (если это необходимо)  */
  /* необходимо применять, перед выводом блок из нескольких строк, */
  /* который должен быть размещен в предлах одной страницы         */
  define input parameter p-line-number as integer  no-undo .

  if p-line-number > page-size( OutStream ) then do:
    /* запрошенное количество строк - превышает размер страницы */
    /* не переходим на следующую страницу */
    return .
  end.

  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.

end procedure. /* on-same-page */

procedure sost :

  do
  on error undo, return error return-value
  :
define input  parameter p-bk-gds-code as integer   no-undo .
define output parameter v-all-sum as decimal   no-undo .
define variable v-cost as decimal   no-undo .
define variable v-dis as decimal   no-undo .

v-all-sum = 0 .
define variable v-qnty       as    decimal   no-undo .
define variable v-exist as logical   no-undo .

for each buf_gds-dtl no-lock where buf_gds-dtl.doc-code = nakl_trn-doc.doc-code :
    find first buf_goods no-lock
        where buf_goods.artic      = buf_gds-dtl.artic
          and buf_goods.prod-type  = buf_gds-dtl.prod-type
          and buf_goods.prod-code  = buf_gds-dtl.prod-code .

run lineattr-exist-flora-gds (
    input  buf_gds-dtl.doc-code    ,
    input  buf_goods.gds-code      ,
    input  buf_gds-dtl.prt-code    ,
    input  p-bk-gds-code           ,
    output v-exist                 ).

if v-exist = false then next.

run lineattr-value-flora-gds    (
    input  buf_gds-dtl.doc-code    ,
    input  buf_goods.gds-code      ,
    input  buf_gds-dtl.prt-code    ,
    input  p-bk-gds-code           ,
    input  {&lineattr-flora_gds-code} ,
    output v-qnty                      ).

    if v-qnty < 0 then next.


    find first ub.gds-prt where ub.gds-prt.node-code = buf_gds-dtl.prt-code no-error .

    if buf_trn-doc.exch-code = 0 then  assign
                                         v-cost = buf_gds-dtl.price-rubl
                                         v-dis  = buf_gds-dtl.discnt-rubl * v-qnty
                                         .
                                 else
                                        assign
                                          v-cost = buf_gds-dtl.price-base
                                          v-dis  = buf_gds-dtl.discnt-base * v-qnty
                                        .

     num#str# = num#str# + 1.
/* ALIGNMENT(horiz_align, wrap, vert_align, orientation, add_indent) */
put  stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 1 , num#str#  ,  2 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line}
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 3 , num#str#  ,  8 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line}  +
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 9 , num#str#  , 10 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line}  +
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 11 , num#str#  , 12 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line}  +
      substitute('select("r&1c&2:r&3c&4 ")' ,  num#str# , 13 , num#str#  , 14 ) + {&new-line}  +
      'ALIGNMENT( 7, ,4,4, ) '  + {&new-line}   +
      'BORDER(2,0,0,0,0, ,0,0,0,0,0) '  + {&new-line}
      .
      run macr_excel_char (buf_goods.artic, num#str# , 1 ) .
      run macr_excel_char (caps(buf_goods.gds-name) + "-" + ub.gds-prt.f-name, num#str# , 3 ) .
      run macr_excel_dec (  v-qnty, num#str# , 9 ) .
      run macr_excel_dec (  round(v-cost,2), num#str# , 11 ) .
      run macr_excel_dec (  round((v-cost * v-qnty) , 2 ) , num#str# , 13 ) .


    v-all-sum =  v-all-sum + ( v-qnty * v-cost ) - v-dis .

end.

  end.

end procedure. /* sost */

{ rep/r-libmcr.i macr_excel         }