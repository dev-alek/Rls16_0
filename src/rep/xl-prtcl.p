block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xl-prtcl.p $
$Archive: rep/xl-prtcl.p $

Протокол цен - Excel

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter order-rec            as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xl-prtcl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/xl-prtcl.p $":U .
define variable vss-description as character no-undo init "Протокол цен - Excel".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ str/lib-trn.i  }
{ cmp/r-pril.i new  }
{ cmp/r-page1.i new }
{ str/get-pr.i def  }
{ ref/grplibfn.i    }
{ gbl/getcntxt.i def }

define shared variable print-graft as logical no-undo.

define stream outstream.

define variable rec-grp         as character no-undo.
define variable rec-cli         as character no-undo.
define variable cliname         like clients.obj-name   init "" no-undo.
define variable grpname         like goods.grp-name     init "" no-undo.
define variable price           like price-list.price-sale      no-undo.
define variable cost-rubl       like price-list.price-sale      no-undo.
define variable cost-base       like price-list.price-sale      no-undo.
define variable qnty            like stk-tot.fact-qnty          no-undo.
define variable prn-cost-price  as logical              init no no-undo.
define variable coast_r         like stk-line.sum-rubl          no-undo .
define variable coast_v         like stk-line.sum-base          no-undo .
define variable tmp#var         like stk-line.sum-base          no-undo .
define variable fact-order1     like stk-line.fact-order        no-undo .
define variable v-counter       as integer                      no-undo.
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
prn-cost-price = print-graft.
if  prn-cost-price = true
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    prn-cost-price
  }
end.

rec-grp = "".
if order-rec = ? then /* ПРОТОКОЛ ПО СПИСКУ ТОВАРОВ */
    do:
         run ref/gds-grp.w (
                       input p-mainmenu-handle
                      ,input "b-sel"
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input-output rec-grp).
             if rec-grp = "" or rec-grp = ? then  return.

         find gds-grp where recid( gds-grp ) = integer( rec-grp ) no-lock .
         run grplib-get-full-name in this-procedure( input gds-grp.node-code, output grpname ) .
       assign
            rec-cli = ""
        .
        run ref/cli-all.w ( p-mainmenu-handle
                       , input "b-sel"
                       , {&all}
                       , {&all}
                       , {&current}
                       , ?
                       , "yes,yes,yes,,,,ИЛИ"
                       , ?
                       , output rec-cli ) .
        if rec-cli = "" or rec-cli = ? then
            return.
        find clients where recid ( clients ) = integer( rec-cli ) no-lock .
        assign cliname = clients.obj-name .

        for each gds-obj where gds-obj.grp-name begins grpname
                                                     and gds-obj.obj-type = v-cntxt-obj-type
                                                     and gds-obj.obj-code = v-cntxt-obj-code
                                                     and gds-obj.prod-type = clients.obj-type
                                                     and gds-obj.prod-code = clients.obj-code
                                                     no-lock,
                each goods where goods.prod-type = gds-obj.prod-type
                                                   and goods.prod-code = gds-obj.prod-code
                                                   and goods.artic = gds-obj.artic
                                                   no-lock :
            create gds-list.
            buffer-copy goods to gds-list.
        end.
    end.
else
    do:
        find trn-doc where recid( trn-doc ) = order-rec no-lock.
        for each doc-line where doc-line.doc-code = trn-doc.doc-code no-lock,
                each clients where clients.obj-type = doc-line.prod-type
                                                    and clients.obj-code = doc-line.prod-code no-lock,
                each goods where goods.prod-type = doc-line.prod-type
                                                   and goods.prod-code = doc-line.prod-code
                                                   and goods.artic = doc-line.artic
                                                   no-lock :
            if cliname = "" then
                assign cliname = clients.obj-name .
            else
                do:
                    if not can-do(cliname, clients.obj-name) then
                        assign cliname = cliname + "," + clients.obj-name .
                end.

            create gds-list.
            buffer-copy goods to gds-list.
        end.
    end.
   make-excel = true .
   os-delete value( string( session:temp-directory ) +
                              {&df_name} + string( g#report-num ) + ".txt":u ) .
   output stream forexcel to value( string( session:temp-directory ) +
                              {&df_name} + string( g#report-num ) + ".txt":u ) .

reportname =  "П Р О Т О К О Л   Ц Е Н   n________" .
if prn-cost-price then  reportheader =   "(Для внутреннего пользования)" .
define variable V-NN as integer   no-undo .
v-nn = num-entries( cliname, "," ) .
do v-counter = 1 to v-nn :
    reportheader =  "Фирма:" + entry( v-counter, cliname, "," ) .
end.

str1 =  "Сезон:  " + grpname .
str3 =   'Протокол вступает в силу с "__"_________20___г.' .
str4 =   "Курс $" .


if prn-cost-price then
    do:  assign  sheetf.excel-column-lable =
            "Артикул,Наименование товара, Кол-во, Ед. изм., " +
              string( "Цена фирмы (" + "баз.вал" + ")" ) + "," +
              string( "Цена реализации (" + (if var-report-r-b = "rubl" then "{&abbr_rub_allshift}" else "баз.вал" ) + ")" )  + "," +
              "Коэфф надбавки" + ","
           sheetf.sizes = "16,60,15,6,15,15,15,"    .
    end.
else do:
    assign sheetf.excel-column-lable =
            "Артикул , Наименование товара, Кол-во ,Ед. изм.," +
            string( "Цена реализации (" + (if var-report-r-b = "rubl" then "{&abbr_rub_allshift}" else "баз.вал" ) + ")" ) + ","
             sheetf.sizes = "16,60,15,6,15,"    .
    end.
run rep/extitle.p (1).

  { cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code }
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
  run ostatok  (    input  ? ,    input  ? ,    input  false   ,    input  v-today ,    input  ""        ,
    input  ?          ,    input  ?          ,    input  {&arh-crsa} ,    input  {&root-cat-id} ,    input  false     ,
    output  tmp#var  ,    output  tmp#var  ,    output  tmp#var  ,    output  tmp#var  ,    output  tmp#var  ,
    output  fact-order1 ).

for each gds-list no-lock,
        each goods where goods.prod-type = gds-list.prod-type
                                           and goods.prod-code = gds-list.prod-code
                                           and goods.artic = gds-list.artic
                                           no-lock:

    if order-rec = ? then
        do:
         run ost-line (  input   v-cntxt-obj-code  ,
                 input   v-cntxt-obj-type  ,
                 input   gds-list.artic     ,
                 input   gds-list.prod-code ,
                 input   gds-list.prod-type ,
                 input   false     ,
                 input   fact-order1    ,
                 input   {&arh-crsa}            ,
                 input   {&root-cat-id}    ,
                 input   true      ,
                 output  qnty       ,
                 output  coast_r     ,
                 output  coast_v     ,
                 output  tmp#var     ,
                 output  tmp#var     ,
                 output  tmp#var     ,
                 output  tmp#var     ).
             assign
                    cost-rubl = round( coast_r / qnty , 2 )
                    cost-base = round( coast_v / qnty , 2 ) .
        end.
    else do:
            find doc-line where doc-line.prod-type = gds-list.prod-type
                                                 and doc-line.prod-code = gds-list.prod-code
                                                 and doc-line.artic = gds-list.artic
                                                 and doc-line.doc-code = trn-doc.doc-code
                                                 no-lock.
            assign
                cost-rubl = doc-line.price-rubl
                cost-base = doc-line.price-base
                qnty = doc-line.doc-qnty
                .
        end.

    find gds-prt where gds-prt.upper-code = gds-list.prt-root no-lock.
    { str/get-pr.i calc v-cntxt-obj-type v-cntxt-obj-code goods.gds-code gds-prt.node-code}

        price = gp-price-sale .

    if prn-cost-price then
        do:
            {&putexcel}
                gds-list.artic     {&tabulation}
                gds-list.gds-name  {&tabulation}
                excel-format-dec-to-char(qnty)               {&tabulation}
                gds-list.unit-base                           {&tabulation}
                excel-format-dec-to-char(cost-base)          {&tabulation}
                excel-format-dec-to-char(price)              {&tabulation}
                round( price /
                              (if var-report-r-b = "rubl" then cost-rubl else cost-base )  , 2 )
                       {&new-line}
                .
        end.
    else
        do:
            {&putexcel}
                gds-list.artic     {&tabulation}
                gds-list.gds-name  {&tabulation}
                excel-format-dec-to-char(qnty)               {&tabulation}
                gds-list.unit-base                           {&tabulation}
                excel-format-dec-to-char(price)              {&new-line}
                .
        end.
end .
define variable v-host-code    as integer      no-undo.
define variable v-host-name    as character    no-undo.
{ gbl/hostname.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-host-code
    v-host-name
}
{&putexcel} {&new-line} {&new-line} {&tabulation} "Утверждаю," {&new-line}  {&new-line}
 {&tabulation} "Финансовый директор" {&new-line}
 {&tabulation} v-host-name {&tabulation}  "___________" {&tabulation} '"__"_________20___г.'  {&new-line}
 {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} "М.П."  {&new-line}.

if session:set-wait-state("") then.
 {&closeexcel}
 run rep/runexcel.p (string( session:temp-directory) + {&df_name} + string( g#report-num ) + ".txt").

os-delete value( string( session:temp-directory ) +
                           {&df_name} + string( g#report-num ) + ".txt":u ) .
{ rep/ostatok.i }
{ rep/ost-line.i }