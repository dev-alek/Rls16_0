/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет оборотка по признакам 2-шкала

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

*/

def input parameter x-store-code like ub.clients.obj-code no-undo.
def input parameter x-store-type like ub.clients.obj-type no-undo.
def input parameter x-base-type  like ub.currency.curr-abbr no-undo.
def input parameter x-base-code  like ub.currency.curr-code no-undo.
def input parameter classify     as int no-undo.
def input parameter itog         as logical no-undo .
def input parameter x-zero  as logical no-undo .
def input parameter x-ost-1 as logical no-undo .
def input parameter x-ost-2 as logical no-undo .

def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Отчет оборотка по признакам 2х. шкала".
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-gl.i     }
{ rep/procobor.i func-vat }
{ trg/factord.i  }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ trg/prdoclib.i }
{ gbl/dtm.i      }

define buffer clients-p for ub.clients .

define variable pp-prih-qnty   as  logical no-undo .
define variable pp-voz-qnty    as  logical no-undo .
define variable pp-rash-qnty   as  logical no-undo .
define variable pp-kassa-qnty   as  logical no-undo .
define variable pp-spis-qnty   as  logical no-undo .
define variable pp-inv-qnty    as  logical no-undo .
define variable pp-perem-qnty  as  logical no-undo .

def var v-var as character no-undo .
def var v-price-sale as decimal no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define buffer buf-tdedt for tdedt  .
/*поля формы*/
def  var     f-fact-date      as char no-undo.

def var  fact-order-1   like ub.stk-tot.fact-order no-undo.
def var  fact-order-2 like ub.stk-tot.fact-order no-undo.
def var  find-str       as char no-undo.
def var  temp-find-str  like find-str no-undo.
def var  tprintrubl    as log no-undo .
def var  startdate     as date no-undo.
def var  enddate       as date no-undo.
def var  xtog-obj as logical no-undo init true .
define variable null-prt as integer no-undo .
define variable good-row as integer no-undo .

define variable first-name as character no-undo .
define variable first-str  as logical no-undo .
define variable last-name  as character no-undo .
define variable last-str   as logical no-undo .




define variable p-file-name as character no-undo .
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable a-name as character no-undo .

def    var    objname           as char no-undo.
def    var    paytype           as   integer no-undo.
def    var    valtype           as   integer no-undo.
def    var    line              as  char     no-undo.


def var tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.

def var break_group as logical no-undo init true.
def var break_group1 as logical no-undo init true.

def    var    ii        as   integer no-undo.
def    var    i         as   integer no-undo .
def    var    j         as   integer no-undo.
def    var    k         as   integer no-undo.
define variable nnn as integer no-undo .
/* local variable definitions ---                                       */

def var stat     as log no-undo .
def var inperror as log no-undo .

def var rid-list as character no-undo .
def var curr-rep as char no-undo.

def var listtd as char no-undo.
def var no-prise as logical no-undo  init true .
def var discnt-base# as decimal init 0  no-undo .
def var n-nn as integer init 0 no-undo .
def var n-nm as integer init 0 no-undo .
def var n-no as integer init 0 no-undo .
def var var-client as character no-undo .
def var prtroot    like ub.gds-prt.node-code no-undo.


def var    nn              as character no-undo .
def var    f-artic         as character no-undo .
def var    f-b-code        as character no-undo .
def var    f-gds-name      as character no-undo .
def var x-time as integer no-undo .
def var fix-doc-code  like ub.ot-tot.doc-code no-undo .
define stream  macr_excel .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1    as integer no-undo .
define variable var-2    as integer no-undo .
define variable  v-prt-level          as integer no-undo .

/* список отобранных товаров */
define temp-table temp-gds no-undo
field gds-code  like  ub.gds-obj.gds-code
field artic     like  ub.gds-obj.artic
field prod-code like  ub.gds-obj.prod-code
field prod-type like  ub.gds-obj.prod-type
field grp-name  like  ub.gds-obj.grp-name
field cli-name  like  ub.gds-obj.grp-name
field gds-name  like  ub.goods.gds-name
field prt-root  like  ub.goods.prt-root
field prt-lvl as integer
index by-artic artic
index by-grp-name grp-name artic
index by-cli-name cli-name artic
.

/* список признаков по одному товару */
define temp-table temp-prt no-undo
field prt-code    as   integer
field ost-1-qnty  as   decimal
field ost-2-qnty  as   decimal
field prih-qnty   as   decimal
field voz-qnty    as   decimal
field rash-qnty   as   decimal
field kassa-qnty   as   decimal
field spis-qnty   as   decimal
field inv-qnty    as   decimal
field perem-qnty  as   decimal
field type-1      as   char
field type-2      as   char
field prt-root  like  ub.goods.prt-root

index pi prt-code
.
/* шапки для признаков */
define temp-table temp-vert no-undo
field type-1 as character
field n as integer

index pi  is unique primary type-1
index pn n
.

define temp-table temp-gor no-undo
field type-2 as character
field n as integer

index pi is unique primary type-2
index pn n

.
/* список признаков по шкалам */
define temp-table temp-type-prt no-undo
field ost-1-qnty  as   decimal
field ost-2-qnty  as   decimal
field prih-qnty   as   decimal
field voz-qnty    as   decimal
field rash-qnty   as   decimal
field kassa-qnty   as   decimal
field spis-qnty   as   decimal
field inv-qnty    as   decimal
field perem-qnty  as   decimal
field type-2      as   char
field prt-root  like  ub.goods.prt-root
index pi is unique primary prt-root type-2
.


{ rep/r-libmcr.i macr_excel  }

/* ************** frame для формы **************** */
{ rep/repfrm.i def }
{ rep/repfrm.i on 100 }
for each tdedt :
   case tdedt.id :
                  when  {&TDEDT_Pri_Vnesh}    then do:
                    pp-prih-qnty = true.
                  end.

                  when {&TDEDT_RAS_Vnesh_VP}  then do:
                    pp-voz-qnty = true.
                  end.

                  when {&TDEDT_Ras_Vnesh}      or
                  when {&TDEDT_Vozvrat_Vnesh}  then
                      pp-rash-qnty = true.

                  when {&TDEDT_Vozvrat_Vnesh_Kass} or
                  when {&TDEDT_Ras_Vnesh_Kass}   then do:
                      pp-kassa-qnty = true .
                  end.

                  when {&TDEDT_Spi_Vnesh}        then do:
                      pp-spis-qnty = true .
                  end.

                  when {&TDEDT_Inv}    or
                  when {&TDEDT_Peresort}   or
                  when {&TDEDT_Corr_Acc_Price}   or
                  when {&TDEDT_Corr_Minus_Parts}             then do:
                      pp-inv-qnty = true.
                  end.

                  when {&TDEDT_Pri_Perem}        or
                  when {&TDEDT_Pri_Prvo}         or
                  when {&TDEDT_Ras_Perem}        or
                  when {&TDEDT_Vozvrat_Perem}    or
                  when {&TDEDT_Ras_Prvo}         or
                  when {&TDEDT_Spi_Prvo}         then do:
                      pp-perem-qnty = true.
                  end.
              end case.
end.
run report-execute in this-procedure .
/*----------------------------------------------------------------------------------------------------------------------*/

procedure report-execute :
 do
 on error undo, return error return-value
 :
/* создаем временный файл */
    p-file-name =  string( session:temp-directory +
                                  {&df_name} + string( g#report-num ) + ".txt" ) .

run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
output stream macr_excel to value(v-file-name)   .
v-ind = 1    .
num#str# = 0 .

  run calcitog in this-procedure.       /* Поиск fact-order */
      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format( reportname , num#str# , num#col#  ).
      run macr_cell_format
          ( 12       ,    /* p-size   */
            true     ,    /* p-bold   */
            false    ,    /* p-italic */
            ?        ,    /* p-color  */
            num#str# ,    /* p-row    */
            num#col# ,    /* p-col    */
            ?        ,    /* p-row-2  */
            ?         ) . /* p-col-2  */

define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .


&scop var-print-n    do l-ii = 1 to num-entries( ~{&var-str-n} , "~{&new-line}"  )    :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format(                                                          ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
&scop var-str-n  reportheader
{&var-print-n }

num#str# = num#str# + 1.
num#col# = 1.

  Find first ub.gds-prt where ub.gds-prt.node-name = {&empty-scale} no-lock no-error.
  If available  ub.gds-prt then   Prtroot = ub.gds-prt.prt-root.
                        Else   Prtroot = 0.

    case classify :
      when 1 then do:
        run foreach1 in this-procedure.
      end.
      when 2 then do:
        run foreach2 in this-procedure.
      end.
      when 3 then do:
        run foreach3 in this-procedure.
      end.
    end case.



  output stream macr_excel  close .
  { rep/repfrm.i off}
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2"
        ) .

  run end-proc .

  run rep/runexcel.p (p-file-name ).

 end. /* do */
end procedure. /* report-execute */


procedure calcitog :
 do
 on error undo, return error return-value
 :
    run day-begin-fact-order(
        input x-date-start ,
        output fact-order-1  ) .
    run day-begin-fact-order(
        input ( x-date-end + 1 ) ,
        output fact-order-2  ) .


 end. /* do */
end procedure. /* calcitog */



procedure print-header :
 do
 on error undo, return error return-value
 :
  define input parameter p-name  as character no-undo .
      num#str# = num#str# + 3 .
      run macr_excel_char_with_format( p-name , num#str# , 1  ).
      run macr_cell_format
          ( 12       ,    /* p-size   */
            true     ,    /* p-bold   */
            true     ,    /* p-italic */
            35        ,    /* p-color  */
            num#str# ,    /* p-row    */
            1 ,           /* p-col    */
            num#str# ,    /* p-row-2  */
            6   ) .      /* p-col-2  */

  first-name = "".
  first-str = false .

 end. /* do */
end procedure. /* print-header */



procedure print-footer :
 do
 on error undo, return error return-value
 :
  define input parameter p-name  as character no-undo .
      num#str# = num#str# + 1 .
      run macr_excel_char_with_format( p-name , num#str# , 1  ).
      run macr_cell_format
          ( 12       ,    /* p-size   */
            true     ,    /* p-bold   */
            true     ,    /* p-italic */
            ?        ,    /* p-color  */
            num#str# ,    /* p-row    */
            1 ,           /* p-col    */
            num#str# ,    /* p-row-2  */
            6   ) .      /* p-col-2  */
  last-name = "".
  last-str = false .

 end. /* do */
end procedure. /* print-footer */



procedure make-gds-list :
 do
 on error undo, return error return-value
 :
/* По товарам  всегда слитно по объектам */
  i = 0 .
   for each obj-list no-lock :
    i = i + 100 .
      { rep/repfrm.i disp i  "'Сбор списка товара'"  Obj-list.obj-name }
             for each ub.gds-obj where
                      ub.gds-obj.obj-type = obj-list.obj-type    and
                      ub.gds-obj.obj-code = obj-list.obj-code
                      {&ver-last-doc}
                &if "{1}" = "gds-list":u  &then
                      no-lock,
                first gds-list  where ub.gds-obj.gds-code  = gds-list.gds-code
                &else
                      no-lock,
                first ub.goods  where ub.gds-obj.gds-code  = ub.goods.gds-code
                      &endif   no-lock :
                      if not can-find(first temp-gds where temp-gds.gds-code = ub.gds-obj.gds-code)
                          and Prtroot <> {1}.prt-root    then do:
                          find first ub.clients where
                                      ub.clients.obj-type = ub.gds-obj.prod-type and
                                      ub.clients.obj-code = ub.gds-obj.prod-code  no-lock no-error .

                            /* определяем уровень шкалы 1- это пустая , учитываем 2 и 3*/
                            find first ub.gds-prt no-lock  where  ub.gds-prt.prt-root =  integer({1}.prt-root) no-error  .
                            if not available ub.gds-prt then next.
                            { gbl/prtlevel.i
                              ub.gds-prt.node-code
                              v-prt-level }
                              if v-prt-level > 3 then next.

                          create temp-gds.
                          assign
                            temp-gds.gds-code  = ub.gds-obj.gds-code
                            temp-gds.artic     = ub.gds-obj.artic
                            temp-gds.prod-code = ub.gds-obj.prod-code
                            temp-gds.prod-type = ub.gds-obj.prod-type
                            temp-gds.grp-name  = ub.gds-obj.grp-name
                            temp-gds.gds-name  = {1}.gds-name
                            temp-gds.prt-root  = {1}.prt-root
                            temp-gds.prt-lvl   = v-prt-level
                            temp-gds.cli-name  = if available ub.clients
                               then ( ub.clients.obj-name + " (" + string(gds-obj.prod-code)
                                                              + ub.gds-obj.prod-type
                                                              + ")" )
                               else ""
                           .
                      end.
             end.
   end.
   i = 0 .

 end. /* do */
end procedure. /* make-gds-list */

procedure foreach1 :
 do
 on error undo, return error return-value
 :
define variable  p-obj-type           like ub.gds-obj.obj-type  no-undo .
define variable  p-obj-code           like ub.gds-obj.obj-code  no-undo .
define variable  p-artic              like ub.gds-obj.artic     no-undo .
define variable  p-prod-type          like ub.gds-obj.prod-type no-undo .
define variable  p-prod-code          like ub.gds-obj.prod-code no-undo .
define variable  p-fact-order         as decimal   no-undo .
define variable  p-include-fact-order as logical   no-undo .
define variable l-pusto as logical no-undo .
first-str = false .

  run make-gds-list.
  for each temp-gds  :      /* ПО ТОВАРУ */
      v-prt-level = temp-gds.prt-lvl .
          /* заполнение */
          run zap
              ( input-output p-obj-type
              ,input-output p-obj-code
              ,input-output p-artic
              ,input-output p-prod-type
              ,input-output p-prod-code
              ,input-output  p-fact-order
              ,input-output p-include-fact-order )        .
          if itog = false then do:
              /* печать матрицы по товару */
              run scan-tt (output l-pusto ).
              run print-tt.
          end.
          run make-type-prt.
  end. /* по товарам */
  run print-type-prt.
 end. /* do */
end procedure. /* foreach1 */


procedure clear-matrix :
 do
 on error undo, return error return-value
 :
  for each temp-prt :
     delete temp-prt .
  end.
  for each temp-vert :
     delete temp-vert.
  end.
  for each temp-gor :
     delete temp-gor.
  end.

 end. /* do */
end procedure. /* clear-matrix */

procedure prt-matrix :
 do
 on error undo, return error return-value
 :
define input parameter p-prt-code   as integer no-undo .
define input parameter p-sum-type   as character no-undo .
define input parameter p-fact-qnty  as decimal no-undo .

if p-fact-qnty = 0 then return.

define variable type-0 as character init "" no-undo .
define variable type-1 as character init "" no-undo .
define variable type-2 as character init "" no-undo .
define variable type-11 as character init "" no-undo .
define variable type-12 as character init "" no-undo .
define buffer   buf_gds-prt    for ub.gds-prt.
define variable p-upper-code-1 as integer no-undo .
define variable p-upper-code-2 as integer no-undo .

 find first temp-prt where temp-prt.prt-code = p-prt-code no-error .
 if not available temp-prt then do:
    /* найдем название у признака */
    find first buf_gds-prt where buf_gds-prt.node-code = p-prt-code no-lock no-error .
    type-1 = buf_gds-prt.node-name.
    p-upper-code-1 = buf_gds-prt.upper-code.
    find first buf_gds-prt where buf_gds-prt.node-code = p-upper-code-1 no-lock no-error .
    if available buf_gds-prt then do:
        type-2 = buf_gds-prt.node-name.
        p-upper-code-2 = buf_gds-prt.upper-code.
        find first buf_gds-prt where buf_gds-prt.node-code = p-upper-code-2 no-lock no-error .
        if available buf_gds-prt then do:
           type-0 = buf_gds-prt.node-name.
        end.
    end.

    if v-prt-level = 3 then do: /* поменяем местами */
        assign
          type-11 = type-1
          type-12 = type-2
          type-1 = type-12
          type-2 = type-11
        .
    end.

      run make-vert-gor (type-1, type-2).
      create temp-prt.
      assign
        temp-prt.prt-code     =  p-prt-code
        temp-prt.type-1       =  type-1
        temp-prt.type-2       =  type-2
        temp-prt.prt-root     =  temp-gds.prt-root

      .
 end. /* if not avail */

 case p-sum-type:
    when "ost-1"      then do:  temp-prt.ost-1-qnty   = temp-prt.ost-1-qnty  + p-fact-qnty  . end.
    when "ost-2"      then do:  temp-prt.ost-2-qnty   = temp-prt.ost-2-qnty  + p-fact-qnty  . end.
    when "prih-qnty"  then do:  temp-prt.prih-qnty    = temp-prt.prih-qnty   + p-fact-qnty  . end.
    when "voz-qnty"   then do:  temp-prt.voz-qnty     = temp-prt.voz-qnty    + p-fact-qnty  . end.
    when "rash-qnty"  then do:  temp-prt.rash-qnty    = temp-prt.rash-qnty   + p-fact-qnty  . end.
    when "kassa-qnty"  then do:  temp-prt.kassa-qnty    = temp-prt.kassa-qnty   + p-fact-qnty  . end.
    when "spis-qnty"  then do:  temp-prt.spis-qnty    = temp-prt.spis-qnty   + p-fact-qnty  . end.
    when "inv-qnty"   then do:  temp-prt.inv-qnty     = temp-prt.inv-qnty    + p-fact-qnty  . end.
    when "perem-qnty" then do:  temp-prt.perem-qnty   = temp-prt.perem-qnty  + p-fact-qnty  . end.
 end case.

 end. /* do */
end procedure. /* prt-matrix */




procedure make-vert-gor :
do
on error undo, return error return-value
:
define input parameter p-type-1    as character no-undo .
define input parameter p-type-2    as character no-undo .


find first temp-vert where temp-vert.type-1 = p-type-1 no-error .
if not available temp-vert then do:
   create temp-vert.
   temp-vert.type-1 = p-type-1.
end.

find first temp-gor where temp-gor.type-2 = p-type-2 no-error .
if not available temp-gor then do:
   create temp-gor.
   temp-gor.type-2 = p-type-2.
end.

end. /* do */
end procedure. /* make-vert-gor */



procedure scan-tt :
 do
 on error undo, return error return-value
 :

define output parameter p-pusto as logical no-undo .
define variable ii as integer no-undo .
define variable ij as integer no-undo .
p-pusto = false .

        .
ii = 2.
for each temp-vert :
    ii = ii + 1 .
    temp-vert.n = ii.

end.

ij = 2.
for each temp-gor :
    ij = ij + 1 .
    temp-gor.n = ij.
end.

if not can-find( first temp-vert)  then  p-pusto = true .

 end. /* do */
end procedure. /* scan-tt */


procedure print-tt :
 do
 on error undo, return error return-value
 :
/* теперь эту матрицу надо распечатать */
define variable loc-str as integer no-undo .
define variable hh as integer no-undo .
define variable lh as integer no-undo .
define variable max-loc-str as integer no-undo .
define variable l-row as integer no-undo .
define variable l-col as integer no-undo .
define variable p-row as integer no-undo .
define variable p-col as integer no-undo .
define variable s-ost-1       as   decimal  no-undo .
define variable s-ost-2       as   decimal  no-undo .
define variable s-prih-qnty   as   decimal  no-undo .
define variable s-voz-qnty    as   decimal  no-undo .
define variable s-rash-qnty   as   decimal  no-undo .
define variable s-kassa-qnty   as   decimal  no-undo .
define variable s-spis-qnty   as   decimal  no-undo .
define variable s-inv-qnty    as   decimal  no-undo .
define variable s-perem-qnty  as   decimal  no-undo .

i = i +  50 .
{ rep/repfrm.i disp i  "'Вывод в файл'"   }
define variable ll-i as integer no-undo .
  ll-i        = 0.

for each temp-vert:
ll-i  = ll-i + 1.
if ll-i = 1 then  do:
     if first-str = true  then do:
        run print-header ( first-name ).
     end.
     /* первая строчка */
      num#col# =  1 .
      num#str# = num#str# + 1 .
      good-row = num#str#.
      run print-goods (good-row , 1 ).
      num#str# = num#str# + 1 .
      l-row    = num#str# .
      l-col    = 1.
      run macr_excel_char_with_format( "данные" , num#str# , 2  ).
      end.

     run macr_excel_char_with_format( temp-vert.type-1 , num#str# , temp-vert.n  ).
     p-col = temp-vert.n.
end.

if ll-i = 0 then return.      /* нет в матрице колонок --- на выход */

for each temp-gor :
    assign
        s-ost-1     = 0
        s-ost-2     = 0
        s-prih-qnty = 0
        s-voz-qnty  = 0
        s-rash-qnty = 0
        s-kassa-qnty = 0
        s-spis-qnty = 0
        s-inv-qnty  = 0
        s-perem-qnty= 0
    .

  num#str# = num#str# + 1 .
  run macr_excel_char_with_format( temp-gor.type-2 , num#str# , 1 ).
  hh = 0 .
  for each temp-vert:

    loc-str = num#str# .

    find first  temp-prt where
                temp-prt.type-1  = temp-vert.type-1 and
                temp-prt.type-2  = temp-gor.type-2  no-error .

      if available temp-prt then do:
      hh = hh + 1 .
      lh = 0 .
        if x-ost-1 = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "нач.остаток" , loc-str , 2  ) .
                                 run macr_excel_dec ( temp-prt.ost-1 , loc-str , temp-vert.n  ).
                             end.
        if pp-prih-qnty = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "приход" , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.prih-qnty , loc-str , temp-vert.n  ).
                             end.
        if pp-voz-qnty = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "возврат пост." , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.voz-qnty , loc-str , temp-vert.n  ).
                             end.
        if pp-rash-qnty = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "расход внеш." , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.rash-qnty , loc-str , temp-vert.n  ).
                             end.
        if pp-kassa-qnty = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "касса" , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.kassa-qnty , loc-str , temp-vert.n  ).
                             end.

        if pp-inv-qnty = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "инвентаризация" , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.inv-qnty , loc-str , temp-vert.n  ).
                             end.
        if pp-spis-qnty = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "списание" , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.spis-qnty , loc-str , temp-vert.n  ).
                             end.
        if pp-perem-qnty = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "перемещение" , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.perem-qnty , loc-str , temp-vert.n  ).
                             end.


        if x-ost-2 = true then do:
                                 lh = lh + 1 .
                                 if lh > 1 then loc-str = loc-str + 1 .
                                 if hh = 1 then run macr_excel_char_with_format( "кон.остаток" , loc-str , 2  ) .
                                 run macr_excel_dec( temp-prt.ost-2 , loc-str , temp-vert.n  ).
                             end.

        if max-loc-str < loc-str then max-loc-str = loc-str.
        assign
            s-ost-1     =  s-ost-1       + temp-prt.ost-1
            s-ost-2     =  s-ost-2       + temp-prt.ost-2
            s-prih-qnty =  s-prih-qnty   + temp-prt.prih-qnty
            s-voz-qnty  =  s-voz-qnty    + temp-prt.voz-qnty
            s-rash-qnty =  s-rash-qnty   + temp-prt.rash-qnty
            s-kassa-qnty =  s-kassa-qnty   + temp-prt.kassa-qnty
            s-spis-qnty =  s-spis-qnty   + temp-prt.spis-qnty
            s-inv-qnty  =  s-inv-qnty    + temp-prt.inv-qnty
            s-perem-qnty=  s-perem-qnty  + temp-prt.perem-qnty
        .
      end.
  end.

  /* ИТОГО ПО ВЕРХНЕМУ УРОВНЮ */
   define variable f-col as decimal no-undo .
   define variable f-row as decimal no-undo .
   f-col = p-col + 1 .
   f-row = num#str# - 1 .
    if l-row = f-row then run macr_excel_char_with_format( " Итого" , f-row   , f-col  ) .

    if x-ost-1 = true then do:
                            f-row = f-row + 1.  run macr_excel_dec ( s-ost-1 , f-row , f-col  ).
                          end.
    if pp-prih-qnty = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-prih-qnty , f-row , f-col  ).
                          end.
    if pp-voz-qnty = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-voz-qnty , f-row , f-col  ).
                          end.
    if pp-rash-qnty = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-rash-qnty , f-row , f-col  ).
                          end.
    if pp-kassa-qnty = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-kassa-qnty , f-row , f-col  ).
                          end.
    if pp-inv-qnty = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-inv-qnty , f-row , f-col  ).
                          end.
    if pp-spis-qnty = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-spis-qnty , f-row , f-col  ).
                          end.
    if pp-perem-qnty = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-perem-qnty , f-row ,f-col  ).
                          end.
    if x-ost-2 = true then do:
                            f-row = f-row + 1.  run macr_excel_dec( s-ost-2 , f-row , f-col  ).
                          end.

    nnn = nnn + 1  .
    if (nnn modulo 2) = 0  /* четное покрасим в голубенький 34 */  then do:
    run macr_cell_format
          ( ?    ,      /* p-size     */
            ?  ,        /* p-bold     */
            ?  ,        /* p-italic   */
            34    ,     /* p-color-bg */
            num#str#,   /* p-row      */
            2 ,         /* p-col      */
            max-loc-str ,     /* p-row-2    */
            p-col + 1 ) .         /* p-col-2    */
    end.
    num#str# =  max-loc-str .

 end.
p-row    = num#str# .

if ll-i > 0  then do:
   run bord-tt (l-row , l-col , p-row , p-col , 33 , true ) . /* темно голубой */
   end.

 end. /* do */
end procedure. /* print-tt */



procedure print-goods :
 do
 on error undo, return error return-value
 :
 define input parameter p-row as integer no-undo .
 define input parameter p-col as integer no-undo .
  run macr_excel_char_with_format( temp-gds.artic
      , p-row
      , p-col ) .

  run macr_excel_char_with_format( temp-gds.gds-name
      , p-row
      , p-col + 1 ) .

   run macr_cell_format
          ( 10       ,      /* p-size   */
            true     ,      /* p-bold   */
            false    ,      /* p-italic */
            ?        ,      /* p-color  */
            p-row ,         /* p-row    */
            p-col ,         /* p-col    */
            p-row  ,        /* p-row-2  */
            p-col + 1   ) . /* p-col-2  */


 end. /* do */
end procedure. /* print-goods */


procedure bord-tt :
 do
 on error undo, return error return-value
 :
define input parameter row-1 as integer no-undo .
define input parameter col-1 as integer no-undo .
define input parameter row-2 as integer no-undo .
define input parameter col-2 as integer no-undo .
define input parameter p-color as integer no-undo .
define input parameter p-sdvig as logical no-undo .

define variable var-col-1 as integer no-undo .
define variable var-col-2 as integer no-undo .

if p-sdvig then
assign
  var-col-1  = col-1 + 2
  var-col-2  = col-2 + 1
 .
 else
 assign
  var-col-1  = col-1
  var-col-2  = col-2

 .


  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , row-1 + 1 , var-col-1 , row-2 , var-col-2  ) + {&new-line}  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
   run macr_cell_format
        ( ?    ,       /* p-size     */
          ?  ,         /* p-bold     */
          ?  ,         /* p-italic   */
          p-color    ,  /* p-color-bg */
          row-1 ,      /* p-row      */
          2 ,          /* p-col      */
          row-1 ,      /* p-row-2    */
          var-col-2 ) .    /* p-col-2    */

   run macr_cell_format
        ( ?    ,      /* p-size     */
          ?  ,        /* p-bold     */
          ?  ,        /* p-italic   */
          p-color   ,     /* p-color-bg */
          row-1 + 1,  /* p-row      */
          1 ,         /* p-col      */
          row-2 ,     /* p-row-2    */
          1 ) .       /* p-col-2    */

   run macr_cell_size ( 12 , ? , row-1 , 1 , row-2, 1 ) .
   run macr_cell_size ( 14 , ? , row-1 , 2 , row-2, 2 ) .


 end. /* do */
end procedure. /* bord-tt */


procedure ob-line :
 do
 on error undo, return error return-value
 :

define input parameter p-fact-order-1   as decimal no-undo .
define input parameter p-fact-order-2   as decimal no-undo .
define input parameter p-artic        as character no-undo .
define input parameter p-prod-type    as character no-undo .
define input parameter p-prod-code    as integer no-undo .
define input parameter p-obj-type    as character no-undo .
define input parameter p-obj-code    as integer no-undo .


define buffer buf_gds-dtl for ub.gds-dtl .
define buffer buf_trn-doc for ub.trn-doc .

   for each buf_gds-dtl no-lock where
       buf_gds-dtl.artic = p-artic and
       buf_gds-dtl.prod-type = p-prod-type and
       buf_gds-dtl.prod-code = p-prod-code and
       buf_gds-dtl.obj-code  = p-obj-code and
       buf_gds-dtl.obj-type  = p-obj-type ,
            first buf_trn-doc no-lock where  buf_trn-doc.doc-code = buf_gds-dtl.doc-code and
                                             buf_trn-doc.fact-order >= p-fact-order-1 and
                                             buf_trn-doc.fact-order <= p-fact-order-2 and
                                             buf_trn-doc.status_     = {&fact}    and
               can-find( first tdedt where tdedt.id = buf_trn-doc.ext-doc-type) :

   case buf_trn-doc.ext-doc-type :
                  when  {&TDEDT_Pri_Vnesh}    then do:
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "prih-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty    /* fact-qnty */
                        ) .

                  end.

                  when {&TDEDT_RAS_Vnesh_VP}  then do:
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "voz-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty * (-1)    /* fact-qnty */
                        ) .

                  end.

                  when {&TDEDT_Ras_Vnesh}      then
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "rash-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty * (-1)   /* fact-qnty */
                        ) .
                  when {&TDEDT_Vozvrat_Vnesh}  then
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "rash-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty    /* fact-qnty */
                        ) .


                  when {&TDEDT_Vozvrat_Vnesh_Kass} then
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "kassa-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty    /* fact-qnty */
                        ) .


                  when {&TDEDT_Ras_Vnesh_Kass}   then do:
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "kassa-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty * (-1)   /* fact-qnty */
                        ) .

                  end.

                  when {&TDEDT_Spi_Vnesh}        then do:
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "spis-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty * (-1)   /* fact-qnty */
                        ) .

                  end.

                  when {&TDEDT_Inv}              or
                  when {&TDEDT_Peresort}        or
                  when {&TDEDT_corr_minus_parts} or
                  when {&TDEDT_Corr_Acc_Price}
                  then do:
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "inv-qnty"               /* sum-type  */
                            , buf_gds-dtl.doc-qnty    /* fact-qnty  для инвентаризации DOC-QNTY */
                        ) .

                  end.

                  when {&TDEDT_Pri_Perem}        or
                  when {&TDEDT_Pri_Prvo}         then do:
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "perem-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty    /* fact-qnty */
                        ) .

                  end.

                  when {&TDEDT_Ras_Perem}        or
                  when {&TDEDT_Vozvrat_Perem}    or
                  when {&TDEDT_Ras_Prvo}         or
                  when {&TDEDT_Spi_Prvo}         then do:
                        run prt-matrix (
                            buf_gds-dtl.prt-code       /* prt-code  */
                            , "perem-qnty"               /* sum-type  */
                            , buf_gds-dtl.fact-qnty * (-1)   /* fact-qnty */
                        ) .

                  end.
              end case.

   end.
 end. /* do */
end procedure. /* ob-line */


procedure make-type-prt :
 do
 on error undo, return error return-value
 :
    for each temp-prt :
    find first temp-type-prt  where
          temp-type-prt.prt-root    =   temp-prt.prt-root and
          temp-type-prt.type-2      =   temp-prt.type-2  no-error .
          if not available temp-type-prt then   create temp-type-prt.
        assign
          temp-type-prt.ost-1-qnty  =   temp-type-prt.ost-1-qnty +  temp-prt.ost-1-qnty
          temp-type-prt.ost-2-qnty  =   temp-type-prt.ost-2-qnty +  temp-prt.ost-2-qnty
          temp-type-prt.prih-qnty   =   temp-type-prt.prih-qnty  +  temp-prt.prih-qnty
          temp-type-prt.voz-qnty    =   temp-type-prt.voz-qnty   +  temp-prt.voz-qnty
          temp-type-prt.rash-qnty   =   temp-type-prt.rash-qnty  +  temp-prt.rash-qnty
          temp-type-prt.kassa-qnty   =   temp-type-prt.kassa-qnty  +  temp-prt.kassa-qnty
          temp-type-prt.spis-qnty   =   temp-type-prt.spis-qnty  +  temp-prt.spis-qnty
          temp-type-prt.inv-qnty    =   temp-type-prt.inv-qnty   +  temp-prt.inv-qnty
          temp-type-prt.perem-qnty  =   temp-type-prt.perem-qnty +  temp-prt.perem-qnty
          temp-type-prt.prt-root    =   temp-prt.prt-root
          temp-type-prt.type-2      =   temp-prt.type-2
        .
    find first temp-type-prt  where
          temp-type-prt.prt-root    =   temp-prt.prt-root and
          temp-type-prt.type-2      =   "_Итого"  no-error .
          if not available temp-type-prt then   create temp-type-prt.
        assign
          temp-type-prt.ost-1-qnty  =   temp-type-prt.ost-1-qnty +  temp-prt.ost-1-qnty
          temp-type-prt.ost-2-qnty  =   temp-type-prt.ost-2-qnty +  temp-prt.ost-2-qnty
          temp-type-prt.prih-qnty   =   temp-type-prt.prih-qnty  +  temp-prt.prih-qnty
          temp-type-prt.voz-qnty    =   temp-type-prt.voz-qnty   +  temp-prt.voz-qnty
          temp-type-prt.rash-qnty   =   temp-type-prt.rash-qnty  +  temp-prt.rash-qnty
          temp-type-prt.kassa-qnty   =   temp-type-prt.kassa-qnty  +  temp-prt.kassa-qnty
          temp-type-prt.spis-qnty   =   temp-type-prt.spis-qnty  +  temp-prt.spis-qnty
          temp-type-prt.inv-qnty    =   temp-type-prt.inv-qnty   +  temp-prt.inv-qnty
          temp-type-prt.perem-qnty  =   temp-type-prt.perem-qnty +  temp-prt.perem-qnty
          temp-type-prt.prt-root    =   temp-prt.prt-root
          temp-type-prt.type-2      =   "_Итого"
        .

    end.

 end. /* do */
end procedure. /* make-type-prt */



procedure print-type-prt :
 do
 on error undo, return error return-value
 :
define variable start-row as integer no-undo .
define variable f-row as integer no-undo .
define variable f-col as integer no-undo .
define buffer buf_gds-prt for ub.gds-prt.
 f-col = 1.

    for each temp-type-prt break by  temp-type-prt.prt-root  by temp-type-prt.type-2 :
    if last-str then run print-footer (last-name ) .
    if first-of (temp-type-prt.prt-root) then do:
        /* Печать шапки шкалы */
        find first buf_gds-prt no-lock  where  buf_gds-prt.prt-root =  integer(temp-type-prt.prt-root) no-error  .
        num#str# = num#str# + 1 .
        run macr_excel_char_with_format( "Шкала"              , num#str#    , 1 ) .
        run macr_excel_char_with_format( buf_gds-prt.node-name   , num#str#    , 2 ) .
        run macr_cell_format ( 12       ,
            true     ,    /* p-bold   */
            false    ,    /* p-italic */
            ?        ,    /* p-color  */
            num#str# ,    /* p-row    */
            1 ,           /* p-col    */
            num#str#  ,   /* p-row-2  */
            2   ) .       /* p-col-2  */

        start-row = num#str# + 1 .
        end.

          f-col = f-col + 1.
          f-row = start-row.
          run macr_excel_char_with_format( temp-type-prt.type-2    , f-row    , f-col ) .
          if x-ost-1 = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec ( temp-type-prt.ost-1-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "нач.остаток" ,  f-row , 1  ) .
                                end.
          if pp-prih-qnty = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.prih-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "приход" ,  f-row , 1  ) .
                                end.
          if pp-voz-qnty = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.voz-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "возврат пост." ,  f-row , 1  ) .
                                end.
          if pp-rash-qnty = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.rash-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "расход внеш" ,  f-row , 1  ) .
                                end.
          if pp-kassa-qnty = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.kassa-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "касса" ,  f-row , 1  ) .
                                end.
          if pp-inv-qnty = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.inv-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "инвентар." ,  f-row , 1  ) .
                                end.
          if pp-spis-qnty = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.spis-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "списание" ,  f-row , 1  ) .
                                end.
          if pp-perem-qnty = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.perem-qnty , f-row ,f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "перемещ" ,  f-row , 1  ) .
                                end.
          if x-ost-2 = true then do:
                                  f-row = f-row + 1.  run macr_excel_dec( temp-type-prt.ost-2-qnty , f-row , f-col  ).
                                  if f-col = 2 then run macr_excel_char_with_format( "кон.остаток" ,  f-row , 1  ) .
                                end.

        if last-of (temp-type-prt.prt-root) then do:
           run bord-tt (start-row  , 1 , f-row , f-col , 39 , false  ) . /* фиол  */
           num#str# = f-row .
           f-col = 1.
        end.

    end.

    for each temp-type-prt : delete temp-type-prt . end.

 end. /* do */
end procedure. /* print-type-pr */

procedure foreach2 :
 do
 on error undo, return error return-value
 :
define variable  p-obj-type           like ub.gds-obj.obj-type  no-undo .
define variable  p-obj-code           like ub.gds-obj.obj-code  no-undo .
define variable  p-artic              like ub.gds-obj.artic     no-undo .
define variable  p-prod-type          like ub.gds-obj.prod-type no-undo .
define variable  p-prod-code          like ub.gds-obj.prod-code no-undo .
define variable  p-fact-order         as decimal   no-undo .
define variable  p-include-fact-order as logical   no-undo .
define variable l-pusto as logical no-undo .
  run make-gds-list.
  for each temp-gds  break by  temp-gds.cli-name :      /* ПО ТОВАРУ */
            v-prt-level = temp-gds.prt-lvl .
            run zap /* заполнение */
               (input-output p-obj-type
              ,input-output p-obj-code
              ,input-output p-artic
              ,input-output p-prod-type
              ,input-output p-prod-code
              ,input-output  p-fact-order
              ,input-output p-include-fact-order )        .

            run scan-tt (output l-pusto ).
                if itog = false then do:
                    if first-of( temp-gds.cli-name ) then do:
                        assign
                            first-str = true
                            first-name = temp-gds.cli-name
                        .
                    end.
                    /* печать матрицы по товару */
                    run print-tt.
                end.
                run make-type-prt.
                if last-of( temp-gds.cli-name ) then do:
                    assign
                        last-str = true
                        last-name = "Итоги по производителю " + temp-gds.cli-name
                    .
                    run print-type-prt.
                end.

  end. /* по товарам */
 end. /* do */
end procedure. /* foreach2 */

procedure foreach3 :
 do
 on error undo, return error return-value
 :
define variable  p-obj-type           like ub.gds-obj.obj-type  no-undo .
define variable  p-obj-code           like ub.gds-obj.obj-code  no-undo .
define variable  p-artic              like ub.gds-obj.artic     no-undo .
define variable  p-prod-type          like ub.gds-obj.prod-type no-undo .
define variable  p-prod-code          like ub.gds-obj.prod-code no-undo .
define variable  p-fact-order         as decimal   no-undo .
define variable  p-include-fact-order as logical   no-undo .
define variable l-pusto as logical no-undo .
  run make-gds-list.
  for each temp-gds  break by  temp-gds.grp-name :      /* ПО ТОВАРУ */
      v-prt-level = temp-gds.prt-lvl .
            run zap /* заполнение */
              ( input-output p-obj-type
              ,input-output p-obj-code
              ,input-output p-artic
              ,input-output p-prod-type
              ,input-output p-prod-code
              ,input-output  p-fact-order
              ,input-output p-include-fact-order )        .

            run scan-tt (output l-pusto ).

                if itog = false then do:
                    if first-of( temp-gds.grp-name ) then do:
                        assign
                            first-str = true
                            first-name = temp-gds.grp-name
                        .
                    end.
                    /* печать матрицы по товару */
                    run print-tt.
                end.
                run make-type-prt.
                if last-of( temp-gds.grp-name ) then do:
                    assign
                        last-str = true
                        last-name = "Итоги по группе " +  temp-gds.grp-name
                    .
                    run print-type-prt.
                end.
  end. /* по товарам */
 end. /* do */
end procedure. /* foreach3 */



procedure zap :
 do
 on error undo, return error return-value
 :
define input-output parameter   p-obj-type           like ub.gds-obj.obj-type  no-undo .
define input-output parameter   p-obj-code           like ub.gds-obj.obj-code  no-undo .
define input-output parameter   p-artic              like ub.gds-obj.artic     no-undo .
define input-output parameter   p-prod-type          like ub.gds-obj.prod-type no-undo .
define input-output parameter   p-prod-code          like ub.gds-obj.prod-code no-undo .
define input-output parameter   p-fact-order         as decimal   no-undo .
define input-output parameter   p-include-fact-order as logical   no-undo .

 run clear-matrix .
      for each obj-list :
          assign
            p-obj-type                = obj-list.obj-type
            p-obj-code                = obj-list.obj-code
            p-artic                   = temp-gds.artic
            p-prod-type               = temp-gds.prod-type
            p-prod-code               = temp-gds.prod-code
            p-include-fact-order      = false
          .
          /* ost-1 */
          if x-ost-1 = true then do:
              run prdoclib-clear-temp-prt-obj .
              run prdoclib-init-prt-obj-by-factord
                (input  p-obj-type
                ,input  p-obj-code
                ,input  p-artic
                ,input  p-prod-type
                ,input  p-prod-code
                ,input  fact-order-1
                ,input  p-include-fact-order ) .

                for each temp-prt-obj :
                /* заполнение матрици признаков */
                run prt-matrix (
                    temp-prt-obj.prt-code       /* prt-code  */
                    , "ost-1"                   /* sum-type  */
                    , temp-prt-obj.fact-qnty    /* fact-qnty */
                ) .
                end.
          end.  /*ost-1*/

          if x-ost-2 = true then do:
          /* ost-2 */
              run prdoclib-clear-temp-prt-obj .
              run prdoclib-init-prt-obj-by-factord
                (input  p-obj-type
                ,input  p-obj-code
                ,input  p-artic
                ,input  p-prod-type
                ,input  p-prod-code
                ,input  fact-order-2
                ,input  p-include-fact-order ) .
                for each temp-prt-obj :
                /* заполнение матрици признаков */
                run prt-matrix (
                    temp-prt-obj.prt-code       /* prt-code  */
                    , "ost-2"                   /* sum-type  */
                    , temp-prt-obj.fact-qnty    /* fact-qnty */
                ) .
                end.
          end.  /*ost-2*/
          /* ОБОРОТЫ */
          run ob-line(  input   fact-order-1
                      , input   fact-order-2
                      , input   p-artic
                      , input   p-prod-type
                      , input   p-prod-code
                      , input   p-obj-type
                      , input   p-obj-code    ).

      end. /* for each obj-list */

 end. /* do */
end procedure. /* zap */

/* $Workfile$ e n d */