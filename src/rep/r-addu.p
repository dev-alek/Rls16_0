block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-addu.p $
$Archive: rep/r-addu.p $

Печать Документа ДопРасх

Автор: Чернова Светлана Александровна
Дата создания: 04/14/08
Author: Svetlana Chernova
Creation date: 04/14/08

*/
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-addu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-addu.p $":U .
define variable vss-description as character no-undo init "Печать Документа ДопРасх".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new   }
{ rep/r-cliprp.i def }
{ str/out-vatp.i def }
{ gbl/waitfram.i     }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/lineattr.i }
{ str/adddocfn.i }

define variable base-abbr    as character no-undo .
define variable v-exch-code  as integer   no-undo .
define variable v-exch-rate  as integer   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-sum-cli    as decimal   no-undo .
define variable v-sum-vat    as decimal   no-undo .

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .

{ gbl/getcntxt.i get }

define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
define buffer buf_clients for ub.clients  .

{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }


find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num in parParentProc ( output g#report-num ).
run get-gds-engl in parParentProc ( output g#gds-engl ) .

&SCOP f-l Word-Sum,Total-Word,RedLine
{ gbl/std-func.i {&f-l} }


&glob format-sl "X(199)"


DEFINE  SHARED VARIABLE Sort-gr AS LOGICAL
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

DEFINE Shared VARIABLE print-graft AS LOGICAL
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

def stream OutStream.
define variable    NAme1   as character no-undo .
define variable    Adres1 as character no-undo .
define variable    NAme2   as character no-undo .
define variable    Adres2  as character no-undo .


define variable PrintScale      as   logical     no-undo.
define variable CostPrice      as   logical     no-undo.
define buffer This_Object for  ub.clients .
define buffer gds-prt-1 for  ub.gds-prt .
define buffer bar-code-1 for ub.bar-code .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.

define variable     tdoc-date     like ub.add-doc.doc-date no-undo.
define variable     tdoc-code     like ub.add-doc.doc-code no-undo.

define variable  Control_sUM       as  dec no-undo.
define variable  Control_Qnty      as  dec no-undo.
define variable  PgQnty            as  dec no-undo.
define variable  PgSum             as  dec no-undo.
define variable  PgQnty-b          as  dec no-undo.
define variable  PgSum-b           as  dec no-undo.
define variable  SQnty             as  dec no-undo.
define variable  SSum              as  dec no-undo.
define variable  SQnty-b           as  dec no-undo.
define variable  SSum-b            as  dec no-undo.
define variable  PropisQnty        as  char no-undo.
define variable  PropisSum         as  char no-undo.
define variable  PropisQnty-b      as  char no-undo.
define variable  PropisSum-b       as  char no-undo.
define variable b-sum-base1             as decimal no-undo .
define variable B-Sum              as decimal no-undo .
define variable b-sum-rubl1         as decimal no-undo .
define variable B-val  as character no-undo .
define variable B-val-rate  as decimal   no-undo .
define variable b-contr as character no-undo .
define variable B-cli-name as character no-undo .
define variable b-method as character no-undo .


define variable B-adress like ub.firm.addres1 no-undo .
define variable B-phone  like ub.firm.phone no-undo .

define variable  Propiscount       as  char no-undo.
define variable  PropiscountP      as  char no-undo.
define variable  abbr              as  char no-undo.

define variable tt    as int no-undo.

define variable sym1 as char  init ":"   no-undo.
define variable sym2 as char  init ":"   no-undo.
define variable sym3 as char  init ":"   no-undo.
define variable sym4 as char  init ":"   no-undo.
define variable sym5 as char  init ":"   no-undo.
define variable sym6 as char  init ":"   no-undo.
define variable sym7 as char  init ":"   no-undo.
define variable sym8 as char  init ":"   no-undo.
define variable sym9 as char  init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.
define variable sym11 as char init ":"   no-undo.
define variable sym12 as char init ":"   no-undo.
define variable sym13 as char init ":"   no-undo.
define variable sym14 as char init ":"   no-undo.

define variable tb-code       as char    no-undo.
define variable Price         as decimal no-undo.
define variable UBL           as decimal no-undo .
define variable b-sum-cli        as decimal no-undo.
define variable b-sum-base       as decimal no-undo .
define variable b-sum-rubl       as decimal no-undo .
define variable ProdName      as char    no-undo.
define variable pp as character no-undo .


DEFINE FRAME sl
        sym1 column-label ":!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п " format ">>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        ub.goods.artic COLUMN-LABEL "Артикул! " format "X(16)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        ub.goods.gds-name COLUMN-LABEL "Наименование услуги! " format "X(35)" space(0)
        Sym4 column-label ":!:" format "X(1)" space(0)
        B-val COLUMN-LABEL "Вал!юта " format "X(3)" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        B-val-rate COLUMN-LABEL "Курс ! " format "->>>>>>>9.<<<" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        b-contr COLUMN-LABEL "Вн.Код!договора  " format "x(10)" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        B-cli-name COLUMN-LABEL "Поставщик ! " format "x(34)" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        b-sum-cli COLUMN-LABEL "По док-ту  ! " format ">>>>>>>>>9.99" space(0)
        sym9 column-label ":!:" format "X(1)" space(0)
        b-sum-rubl COLUMN-LABEL "В нац.вал. ! " format ">>>>>>>>>9.99" space(0)
        sym10 column-label ":!:" format "X(1)" space(0)
        b-sum-base COLUMN-LABEL "В баз.вал.  ! " format ">>>>>>>>>9.99" space(0)
        sym11 column-label ":!:" format "X(1)" space(0)
        B-method COLUMN-LABEL "Метод включения !в учетную цену  " format "x(35)" space(0)
        sym12 column-label ":!:" format "X(1)" space(0)
       HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "ДопРасход N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 90 format "X(19)"
        string( " Лист " + string( PAGE-NUMBER(OutStream) , ">>9") ) format "X(13)" SKIP
        UndLine format {&format-sl} AT 1
        with width {&DOS_CW_2} down stream-io use-text NO-BOX.

find first ub.add-doc where ub.add-doc.doc-code = p-doc-code no-lock no-error .
if error-status :error then do:
   message "Документ еще не сохранен в БД !" view-as alert-box information .
   return .
end.

assign
    tdoc-date = (if ub.add-doc.status_ <> {&fact} then ub.add-doc.doc-date else ub.add-doc.fact-date)
    tdoc-code = ub.add-doc.doc-code .

if session:set-wait-state("compiler") then.
{ cmp/open-out.i STREAM OutStream " " {&LS_PS_A4} }

assign
  Line    = fill("-", 199 )
  UndLine = fill("_", 199 )
  LineBuf = fill("_", 199 )
  .


run waitfram-show in this-procedure ( {&MyWaitMess} ) .


find this_object  where this_object.obj-type = v-cntxt-obj-type
                    and this_object.obj-code = v-cntxt-obj-code
                    no-lock.

find ub.clients  where ub.clients.obj-type = {&cmp}
                and ub.clients.obj-code = ub.add-doc.host-code
                no-lock.

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
/* ... конец создания заголовка. --- */

 /* PAGE stream OutStream. */
 FORM with frame sl .
 { rep/r-formh.i {&format-sl} {&dos_CW_2}}
/* по строкам документа-------------------------------------------------------------------------------------------- */

   run waitfram-show in this-procedure( {&MyWaitMess} ) .
      { rep/r-addu.i {&format-sl} sl}

/* ... Подвал. --- */
define variable v-p-rubl as decimal   no-undo .
define variable v-p-base as decimal   no-undo .
define variable v-s-rubl as decimal   no-undo .
define variable v-s-base as decimal   no-undo .
define variable v-kol as integer   no-undo .
v-kol = 0 .
 run on-same-page in this-procedure (input 1) .
 HIDE stream OutStream FRAME BottomFrame .
 PUT  STREAM OutStream
     "Суммы в учетных ценах в национальной и базовой валютах "
     skip
     .
 for each ub.add-trn no-lock where
    ub.add-trn.doc-code = p-doc-code :
    find first ub.trn-doc no-lock
    where ub.trn-doc.doc-code = ub.add-trn.trn-doc-code  no-error .
    if available ub.trn-doc then do:
    v-p-rubl = 0 .
    v-p-base = 0 .
    v-kol = v-kol + 1 .
    for each ub.parts no-lock where
             ub.parts.out-code = ub.add-trn.trn-doc-code and
             ub.parts.in-code = ub.add-trn.trn-doc-code
             :
    v-p-rubl = v-p-rubl + ub.parts.qnty * ub.parts.price-rubl .
    v-p-base = v-p-base + ub.parts.qnty * ub.parts.price-base .
    v-s-rubl = v-s-rubl + ub.parts.qnty * ub.parts.price-rubl .
    v-s-base = v-s-base + ub.parts.qnty * ub.parts.price-base .
    end.

     PUT  STREAM OutStream
     "По ПН "
     ub.add-trn.trn-doc-code
     v-p-rubl at 20
     v-p-base
     skip
     .
    end.
 end.

 if v-kol > 1 then do:
    put  stream outstream
        "Итого "
        v-s-rubl at 20
        v-s-base
        skip
        .
 end.

 if v-kol = 0 then do:
    put  stream outstream
        "Нет привязанных ПН "
        skip
        .
 end.

/* ... конец создания Подвал. --- */

output stream OutStream CLOSE .
run waitfram-hide in this-procedure  .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 8 .

run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .

procedure calc-sl :
define input parameter tt as character no-undo .
if tt = "artic":U THEN DO:
End.
if tt = "scala":U THEN DO:
End.
end procedure.
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