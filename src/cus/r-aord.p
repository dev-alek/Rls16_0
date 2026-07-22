block-level on error undo, throw.
/*

$Revision: 2a79bf27b012, 291, rls $
$Author: ASMorozov $
$Date: Tue Dec 01 19:11:26 2015 +0300 $
$Workfile: r-aord.p $
$Archive: cus/r-aord.p $

Потребность в товарах , заказы

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/

define input  parameter g#type as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 2a79bf27b012, 291, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:26 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-aord.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-aord.p $":U .
define variable vss-description as character no-undo init "Потребность в товарах , заказы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cus/df-zakaz.i }
{ cmp/r-pril.i  new  }
{ gbl/cur-time.i     }
{ rep/repfrm.i def   }
{ cus/df-ex-za.i     }
{ ref/gdsoattr.i     }
{ rep/rep-bt.i       }
define temp-table temp-abc-day no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.

define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date
.


define buffer   bufff-units for ub.units.
define variable t-ret as logical no-undo .

t-ret =  session:SET-WAIT-STATE("GENERAL") .



define variable p-ord-doc as character no-undo .
define buffer   buf_cli-gds  for ub.cli-gds.
define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define variable kol-obj as integer no-undo .
define variable v-grop-max-stock as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-obj-AssMin as logical   no-undo .
define variable v-obj-igt     as character no-undo .
define variable v-round-m   as character no-undo .
define variable v-round-base as decimal   no-undo .


define variable  p-obj-type like ub.ord-doc.obj-type no-undo .
define variable  p-obj-code like ub.ord-doc.obj-code no-undo .
define variable  p-cli-type like ub.ord-doc.cli-type no-undo .
define variable  p-cli-code like ub.ord-doc.cli-code no-undo .
define variable  p-doc-type as character no-undo .
define variable  p-doc-date as date no-undo .
define variable  p-ship-date like ub.ord-doc.ship-date no-undo .
define variable  p-ship-time like ub.ord-doc.ship-time no-undo .
define variable  p-host-code like ub.ord-doc.host-code no-undo .

define variable is-l         as integer no-undo .
define variable i            as integer no-undo .
define variable R-algoritm   as integer no-undo .
define variable R-min-rest   as integer no-undo .
define variable  date-p-1    as date no-undo .
define variable  date-p-2    as date no-undo .
define variable  R-algoritm2 as integer no-undo .
define variable  R-min-rest3 as logical no-undo .
define variable  p-code      like ub.tmp-sale.tmp-code no-undo .
define variable  t-rv        as logical no-undo .
define variable  t-rvz       as logical no-undo .
define variable  t-rvc       as logical no-undo .
define variable  t-rvzc      as logical no-undo .
define variable  t-sp        as logical no-undo .
define variable  t-sppv      as logical no-undo .
define variable  t-sppv-2    as logical no-undo .
define variable  t-sppv-3    as logical no-undo .
define variable  t-sppv-4    as logical no-undo .
define variable  t-way       as logical no-undo .
define variable  t-rcv       as logical no-undo .
define variable  t-clos      as logical no-undo .
define variable  p-neg-sale  as logical no-undo .
define variable  t-gar       as logical no-undo .
define variable  t-min-zapas as logical no-undo .
define variable  p-val       as character no-undo .
define variable  t-min-ost   as logical no-undo .
define variable  t-deadline  as logical no-undo .
define variable SelectObject as character no-undo .
define variable tog-det-prizn as logical no-undo .

main-block :
do on error undo main-block, return error
:

{ rep/repfrm.i on 50 }
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

assign
loc-store-type = v-cntxt-obj-type
loc-store-code = v-cntxt-obj-code
loc-date-ship  = x-date-alone
date-sale-1    = x-date-start
date-sale-2    = x-date-end
pay-day        = date-sale-2 - date-sale-1 + 1

  p-obj-type  = loc-store-type
  p-obj-code  = loc-store-code
  p-cli-type  = loc-cli-type
  p-cli-code  = loc-cli-code
  p-doc-type  = loc-doc-type
  p-doc-date  = doc-date
  p-ship-date = loc-date-ship
  p-host-code = v-cntxt-host-code-obj
.


  run init-screen.
  run make-tmp#zakz .
  run call-proc-calc. /* -->> z-tot6.p  */

 end.  /* main */

/*-----------------------------------------------------------------------------------------------------------------------*/

procedure call-proc-calc :
do
on error undo, return error return-value
:
    if G#type = {&f-p}    then  do:
          run cus/qnty-obj.p  ( my-handle,
                          input v-round-m ,
                          input v-round-base ,
                          input e-method ,
                          input "all-ord":U,
                          input "1-" ,
                          input date-p-1,
                          input date-p-2,
                          input "calc":U,
                          input no,
                          input R-algoritm ,
                          input R-algoritm2,
                          input R-min-rest ,
                          input R-min-rest3,
                          input p-code     ,
                          input t-rv       ,
                          input t-rvz      ,
                          input t-rvc      ,
                          input t-rvzc  ,
                          input t-sp    ,
                          input t-sppv  ,
                          input t-sppv-2,
                          input t-sppv-3,
                          input t-sppv-4,
                          input t-way   ,
                          input t-rcv   ,
                          input t-clos  ,
                          input table tt-date ,
                          input table temp-abc-day ,
                          input p-neg-sale    ,
                          input t-gar         ,
                          input t-min-zapas ,
                          input t-min-ost ,
                          input t-deadline ,
                          input v-cntxt-obj-type  ,
                          input v-cntxt-obj-code  ,
                          input g#type            ,
                          input tog-det-prizn
                                ) no-error .
                                  if error-status :error then do:
                                            message  error-status :get-message(1) .
                                  end.
          end.
    else  do:
          run cus/qntysale.p
            ( my-handle,
              input v-round-m ,
              input v-round-base ,
              input e-method ,
              input "all-ord":U,
              input "1-" ,
              input date-p-1,
              input date-p-2,
              input "calc":U,
              input no,
              input R-algoritm,
              input R-algoritm2,
              input R-min-rest,
              input R-min-rest3,
              input p-code,
              input t-rv,
              input t-rvz,
              input t-rvc ,
              input t-rvzc ,
              input t-sp   ,
              input t-sppv ,
              input t-sppv-2,
              input t-sppv-3,
              input t-sppv-4,
              input t-way,
              input t-rcv,
              input t-clos,
              input table tt-date ,
              input table temp-abc-day ,
              input p-neg-sale,
              input t-gar,
              input t-min-zapas    ,
              input t-min-ost    ,
              input t-deadline ,
              input v-cntxt-obj-type  ,
              input v-cntxt-obj-code  ,
              input g#type            ,
              input tog-det-prizn

              ) no-error .
                if error-status :error then do:
                  message error-status :get-message(1) .
                end.
    end.
end. /* do */
end procedure. /* call-proc-calc */




procedure make-tmp#zakz :
  
  define buffer buf_season for ub.season.
  define buffer buf_season-attr for ub.season-attr.
  define buffer buf_gds-season for ub.gds-season.
  define buffer buf_gds-season-attr for ub.gds-season-attr.
  
 do
 on error undo, return error return-value
 :
find first gds-list no-error .
if not available gds-list then  do:
   message "Не выбран ни один товар !!!" view-as alert-box .
   return error.
   end.

/* проверить было ли изменение в выборе товара */

for each tmp#zakaz :
    delete tmp#zakaz.
end. /* for each */

for each tmp#zakaz-prn :
    delete tmp#zakaz-prn.
end. /* for each */

define variable max-num as integer no-undo .
define variable t-type as character no-undo .
/* заполним вр. таблицу заказа */
for each gds-list :
    max-num = max-num + 1 .
  create tmp#zakaz.
  assign
    tmp#zakaz.doc-code        = "1-"
    tmp#zakaz.gds-code        = gds-list.gds-code
    tmp#zakaz.prod-type       = gds-list.prod-type
    tmp#zakaz.prod-code       = gds-list.prod-code
    tmp#zakaz.artic           = gds-list.artic
    tmp#zakaz.gds-name        = gds-list.gds-name
    tmp#zakaz.deadline        = gds-list.deadline
    tmp#zakaz.unit-cli        = gds-list.unit-cli
    tmp#zakaz.unit-base       = gds-list.unit-base
    tmp#zakaz.negative-rest   = gds-list.negative-rest
    tmp#zakaz.cli-base-rate   = gds-list.cli-base-rate
    tmp#zakaz.ms-cart         = gds-list.qnty-cart
    tmp#zakaz.line-num        = max-num + 1
    .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .
/* message R-min-rest tmp#zakaz.gds-code . */
case R-min-rest :
when 1 then do:
        /* на объекте */
      { gbl/gdsobjpr.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        ?
        ?
        ?
        tmp#zakaz.gds-code
        v-obj-AssMin
        v-obj-igt
        tmp#zakaz.min-stock
        tmp#zakaz.max-stock
        tmp#zakaz.service-order
        tmp#zakaz.min-order
        }
 end.
 when 2 then do:
/* на фирме */
      { gbl/gdsobjpr.i
        {&cmp}
        v-cntxt-host-code-obj
        ?
        ?
        ?
        tmp#zakaz.gds-code
        v-obj-AssMin
        v-obj-igt
        tmp#zakaz.min-stock
        tmp#zakaz.max-stock
        tmp#zakaz.service-order
        tmp#zakaz.min-order
        }

end.
end case.
if R-min-rest3 then do:  /* сезон */
  
  for each buf_season no-lock where 
              buf_season.sea-month-1 <= integer (DATE-sale-2) and
              buf_season.sea-month-2 >= integer (DATE-sale-1):
    find first buf_season-attr where buf_season-attr.sea-code = buf_season.sea-code
      and buf_season-attr.db-num = buf_season.db-num
      and buf_season-attr.attr-code = {&seaattr-obj}
      and buf_season-attr.attr-value = obj-list.obj-type + string (obj-list.obj-code) no-error.

    find first buf_gds-season no-lock where
      buf_gds-season.gds-code = tmp#zakaz.gds-code and
      buf_gds-season.sea-code = buf_season.sea-code and
      buf_gds-season.db-num   = buf_season.db-num
        no-error .
    if available buf_season-attr and available buf_gds-season 
    then do:
      find first buf_gds-season-attr no-lock where buf_gds-season-attr.sea-code = buf_gds-season.sea-code
        and buf_gds-season-attr.db-num = buf_gds-season.db-num
        and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
        and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef}
          no-error .
      if available buf_gds-season-attr then tmp#zakaz.season-coef = decimal (buf_gds-season-attr.attr-value).
      tmp#zakaz.min-stock = buf_gds-season.min-stock .
      leave.
    end.
    else do:
      if available buf_gds-season then do:
        find first buf_gds-season-attr no-lock where buf_gds-season-attr.sea-code = buf_gds-season.sea-code
          and buf_gds-season-attr.db-num = buf_gds-season.db-num
          and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
          and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef}
          no-error.
        if available buf_gds-season-attr then tmp#zakaz.season-coef = decimal (buf_gds-season-attr.attr-value).
          tmp#zakaz.min-stock = buf_gds-season.min-stock .
        end.
    end.
  end.
  if tmp#zakaz.season-coef = ? or tmp#zakaz.season-coef = 0 then assign tmp#zakaz.season-coef = 1.

end.
/*
 message error-status :get-message(1)
 return-value skip
  tmp#zakaz.min-order
  tmp#zakaz.min-stock
  .
  */

end. /* for each */

 end. /* do */
end procedure. /* make-tmp#zakz */




procedure init-screen :
 do
 on error undo, return error return-value
 :
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name    = v-cntxt-userid and
         ubflt.usr-flt.call-point   = "all-ord":U    no-error .
         if not avail ubflt.usr-flt  then do:
            message error-status :get-message(1) .
         end.

p-val = ubflt.usr-flt.list_ .
define variable v-nn as integer   no-undo .
v-nn = num-entries(p-val) .

  do i = 1 to v-nn :
     case  entry(1,(entry(i,p-val)), "=" ) :
        when string( "v-round-m" )              then v-round-m = entry(2,(entry(i,p-val)), "=" )           .
        when string( "v-round-base" )           then v-round-base = decimal(entry(2,(entry(i,p-val)), "=" ) )          .
        when string( "R-min-rest" )             then R-min-rest = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm" )             then R-algoritm = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm2" )            then R-algoritm2 = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "tmp-sale.tmp-code" )      then do:
             find first ub.tmp-sale no-lock where ub.tmp-sale.tmp-code = entry(2,(entry(i,p-val)), "=" ) no-error.
             if available ub.tmp-sale then do:
              p-code = ub.tmp-sale.tmp-code.
             end.
             else do:
             end.
        end.

        when string( "SelectObject" ) then  do:
                SelectObject = string(entry(2,(entry(i,p-val)), "=" )) no-error .
             end.

        when string( "date-p-1" )     then  date-p-1   = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "date-p-2" )     then  date-p-2   = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "t-way"   )      then  t-way      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rcv"   )      then  t-rcv      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-clos"   )     then  t-clos     = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rv"   )       then  t-rv       = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rvz"  )       then  t-rvz      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvc"  )       then  t-rvc      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-rvzc" )       then  t-rvzc     = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sp"   )       then  t-sp       = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sppv" )       then  t-sppv     = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sppv-2")      then  t-sppv-2   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-sppv-3")      then  t-sppv-3   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-4")      then  t-sppv-4   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "p-neg-sale")    then  p-neg-sale = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-gar")         then  t-gar      = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-min-ost")     then  t-min-ost  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-deadline")    then  t-deadline  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-min-zapas")   then  t-min-zapas = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "R-min-rest3")   then  R-min-rest3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        otherwise do:
        end.
     end case.
  end.
date-1 = date-p-1 .
date-2 = date-p-2 .

  kol-obj = num-entries( entry(2,ubflt.usr-flt.list_,"&" ) , ",") - 1 .
     if kol-obj  = ? then kol-obj  = 0 .

find first ubflt.usr-flt where
            ubflt.usr-flt.user-name    = v-cntxt-userid and
            ubflt.usr-flt.call-point   = "selrdallo":U
            no-error .
    if available ubflt.usr-flt then do:
                    tog-det-prizn = logical(entry(5, ubflt.usr-flt.list_, {&delim-par})) .
    end.
if R-algoritm <> 1 then tog-det-prizn = false.

 end. /* do */
end procedure. /* init-screen */