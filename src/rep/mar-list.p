block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mar-list.p $
$Archive: rep/mar-list.p $

Маршрутный лист

Автор: Чернова Светлана Александровна
Дата создания: 08/11/09
Author: Svetlana Chernova
Creation date: 08/11/09

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter order-rec            as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mar-list.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/mar-list.p $":U .
define variable vss-description as character no-undo init "Маршрутный лист".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i new  }
{ cmp/r-page1.i new }
{ str/get-pr.i def  }
{ str/trdcalib.i    }
{ ref/grplibfn.i    }
{ gbl/getcntxt.i def }
{ gbl/rep-clb.i }
{ rep/fmtcli.i  }

my-handle = p-mainmenu-handle .
define temp-table temp-list no-undo
field doc-code as character
field cli-code as integer
field cli-type as character
field cli-name as character
field cli-address as character
field ves as decimal
index pi
 cli-code
 cli-type
 doc-code
.
define shared variable print-graft as logical no-undo.
define variable h-parent   as handle no-undo .      /* d-docm.w    */
define variable h-all-docs as handle no-undo .      /* all-docs.w */
define variable p-list-recid as character no-undo .

p-list-recid = string(order-rec) .


h-parent =  this-procedure:instantiating-procedure .
if lookup ( "get-handle-all-docs" , h-parent:internal-entries ) > 0 then do:
   run get-handle-all-docs in  h-parent (output h-all-docs ) no-error .
   run get-mark-list       in  h-all-docs  (output p-list-recid ) no-error .
   if num-entries(p-list-recid) <= 0 then do:
      message "Не отмечено ни одной накладной. Буду печатать по текущей !" view-as alert-box information .
      p-list-recid = string(order-rec) .
   end.
end.


define stream outstream.

define variable tmp#var         like stk-line.sum-base          no-undo .
define variable v-today         as date                         no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

{ rep/f-fdec.i }
{ gbl/getcntxt.i get " " p-mainmenu-handle }

define variable i as integer   no-undo .
define variable v-ves as decimal   no-undo .
define variable v-all-ves as decimal   no-undo .
define variable v-all-kol as integer   no-undo .
define variable v-kol   as integer   no-undo .
define variable is-hold as logical   no-undo .
define variable v-address as character no-undo .
define variable v-avto  as character no-undo .
define variable v-vodit  as character no-undo .
define variable v-date as date      no-undo .
define variable v-type  as character no-undo .

 find first ub.trn-doc no-lock where recid( ub.trn-doc ) = int(entry(1, p-list-recid)) no-error .
{ str/tdat-val.i
  ub.trn-doc.doc-code
  {&trdcattr-auto}
  v-avto
  v-type
  no-error
  }
{ str/tdat-val.i
  ub.trn-doc.doc-code
  {&trdcattr-driver}
  v-vodit
  v-type
  no-error
  }

v-date = ub.trn-doc.fact-date .


v-all-ves = 0  .
v-all-kol =  0  .

  repeat  i = 1 to num-entries(p-list-recid) :
    find first ub.trn-doc no-lock where recid( ub.trn-doc ) = int(entry(i, p-list-recid)) no-error .
        { gbl/hold-doc.i
          ub.trn-doc.doc-code
          is-hold }
        if not is-hold  then do:
            find first ub.clients no-lock where ub.clients.obj-type = ub.trn-doc.cli-type
                                           and  ub.clients.obj-code = ub.trn-doc.cli-code no-error .
        end.
        else do:
            find first ub.clients no-lock where ub.clients.obj-type = ub.trn-doc.hold-obj-type
                                           and  ub.clients.obj-code = ub.trn-doc.hold-obj-code no-error .
        end.

  RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  ub.clients.obj-type
                                          , INPUT  ub.clients.obj-code
                                          ) .
  assign
    v-address = ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
  .


        v-ves = 0 .
        for each ub.doc-line no-lock where
                 ub.doc-line.doc-code = ub.trn-doc.doc-code ,
                 first ub.goods no-lock  where ub.goods.prod-type = ub.doc-line.prod-type
                                           and ub.goods.prod-code = ub.doc-line.prod-code
                                           and ub.goods.artic = ub.doc-line.artic
                                           :
            v-ves     = if ub.goods.wt-base = 0 or ub.goods.wt-base = ? then ub.doc-line.fact-qnty  else
                           ub.goods.wt-base * ub.doc-line.fact-qnty .
            v-all-ves = v-all-ves + v-ves .
        end.

        create temp-list.
        assign
          temp-list.doc-code       = ub.trn-doc.doc-code
          temp-list.cli-code       = ub.clients.obj-code
          temp-list.cli-type       = ub.clients.obj-type
          temp-list.cli-name       = ub.clients.obj-name
          temp-list.cli-address    = v-address
          temp-list.ves            = v-ves
          .
    end.


   make-excel = true .
   os-delete value( string( session:temp-directory ) +
                              {&df_name} + string( g#report-num ) + ".txt":u ) .
   output stream forexcel to value( string( session:temp-directory ) +
                              {&df_name} + string( g#report-num ) + ".txt":u ) .



reportname   =  "Маршрутный лист" .
reportheader =  "Дата отгрузки : " + string(v-date , "99/99/9999") .
str1 =  "№ авто : "   + v-avto .
str3 =  "Водитель : " + v-vodit .




assign
  sheetf.excel-column-lable =  "№ ,Кол-во накладных,Номер накладной, Клиент и адрес ,Вес/кол-во накладной"
  sheetf.sizes = "3,12,13,44,12,"
  Sheetf.Bas-File = "exe/mar-list.bas"
  .
run rep/extitle.p (1).
Sheetf.Bas-Params = "1" + {&delim-par} + "6".

define variable v-nn as integer   no-undo .
define variable v-kol-cli as integer   no-undo .
define variable v-kol-nakl-cli as integer   no-undo .
define variable v-ves-cli      as decimal   no-undo .

v-nn           = 0 .
v-kol-nakl-cli = 0 .
v-ves-cli      = 0 .
v-kol-cli = 0.

        for each  temp-list break by temp-list.cli-type by temp-list.cli-code:
          if first-of(temp-list.cli-code) then do:
            v-kol-nakl-cli = 0 .
            v-ves-cli      = 0 .
            v-kol-cli = v-kol-cli  + 1.
          end.
          v-nn = v-nn + 1.
          v-kol-nakl-cli = v-kol-nakl-cli +  1 .
          v-ves-cli      = v-ves-cli      + temp-list.ves .
          {&putexcel}
            v-nn                 {&tabulation}
                                 {&tabulation}
            temp-list.doc-code   {&tabulation}
            temp-list.cli-name + ", " temp-list.cli-address  {&tabulation}
            temp-list.ves {&tabulation}
            {&new-line}
            .
          if last-of(temp-list.cli-code) then do:
              {&putexcel}
                 {&tabulation}
                 v-kol-nakl-cli {&tabulation} {&tabulation}  {&tabulation}
                 v-ves-cli
                 {&new-line}
                 .
           end.
        end.

{&putexcel}
    "Итого накладных"  {&tabulation} {&tabulation}
     v-nn {&tabulation}
     "Общий вес/кол-во" {&tabulation}
     v-all-ves
    {&new-line}
    "Итого клиентов"    {&tabulation} {&tabulation}
     v-kol-cli
 {&new-line}.



if session:set-wait-state("") then.
 {&closeexcel}
 run rep/runexcel.p (string( session:temp-directory) + {&df_name} + string( g#report-num ) + ".txt").

os-delete value( string( session:temp-directory ) +
                           {&df_name} + string( g#report-num ) + ".txt":u ) .