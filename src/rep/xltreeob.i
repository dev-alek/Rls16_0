/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет Excel дерево

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

*/
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.

define input parameter xclassify     as character no-undo .
define input parameter xsorttype     as character no-undo .
define input parameter xsumsonly     as logical   no-undo .
define input parameter xshowzero     as logical   no-undo .
define input parameter xshowzero-2   as logical   no-undo .
define input parameter xtog-obj      as logical   no-undo .
define input parameter xshowcost     as logical   no-undo .
define input parameter xshowcostnds  as logical   no-undo .
define input parameter xshowcrsa     as logical   no-undo .
define input parameter xshowcrsands  as logical   no-undo .
define input parameter xshowsale     as logical   no-undo .
define input parameter xshowsalends  as logical   no-undo .
define input parameter xtog-lavel    as logical   no-undo .
define input parameter xvar-lavel    as integer   no-undo .
define input parameter xserv         as character no-undo .
define input parameter xshowmediator as logical   no-undo .
define input parameter xshowsaleslt  as logical   no-undo .
define input parameter x-vat         as logical   no-undo .
define input parameter xlongname     as logical   no-undo .
define input parameter x-tog-wt      as logical   no-undo .
define input parameter x-tog-ms      as logical   no-undo .
define input parameter p-is-petrol   as logical   no-undo .
define input parameter xDens         as logical   no-undo .

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .


define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Оборотная ведомость execl дерево".
 { cmp/vssrevis.i }
&scop e-col 13

/* parameters definitions ---                                           */
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ rep/rep-bt.i   }
{ cmp/r-pril.i    }
{ rep/r-sym.i     }
{ rep/r-gl.i tree }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ gbl/cur-time.i  }




define variable t-time as integer no-undo .

define variable  v-name-type as character no-undo .
define variable  long-p      as logical no-undo .
define work-table temp#sum-type no-undo
    field sum-type as char
    field xi as int
 .

define variable chexcelapplication      as com-handle no-undo .
define variable chworkbook              as com-handle no-undo .
define variable chworksheet             as com-handle no-undo .
define variable m                       as integer no-undo.
define variable l                       as integer no-undo.
define variable i-str                   as integer no-undo.
define variable icolumn                 as integer no-undo.
define variable ccolumn                 as character no-undo.
define variable crange                  as character no-undo.
define variable allcol                  as int no-undo.

&scop max-col-rep   27
&scop const-col-rep 8

define variable  null-str#   as decimal  no-undo.
define variable  null-str2#  as decimal  no-undo.
define variable  tprintrubl  as log      no-undo.

define  stream  outstream  .
define  stream  outstream2 .
define  stream  InStream   .
define  stream  macr_excel .

make-excel-com = false .
make-excel = true  .

define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .

define variable C-c      as integer no-undo .
define variable C-str    as character no-undo .
define variable str--1   as character Format "x(60)" no-undo.
define variable str--2   as integer no-undo .
define variable C-i      as integer no-undo .
define variable p-var    as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1    as integer no-undo .
define variable var-2    as integer no-undo .


define variable    objname           as   char no-undo.
define variable    select-good       as   integer no-undo.
define variable    chosedtype        as   integer no-undo.
define variable    paytype           as   integer no-undo.
define variable    retclassify       as   char  no-undo.
define variable    retsorttype       as   char  no-undo.
define variable    show-negativ      as   logical  no-undo.
define variable    sums-only         as   logical  no-undo.
define variable    valtype           as   integer no-undo.
define variable    line              as   char        no-undo.
define variable    firstline         as   logical     no-undo.
define variable nk as integer no-undo .
define variable lp as int no-undo.
define variable mp as int no-undo.
define variable mp-1 as int no-undo.
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base    no-undo .
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo .
define variable gds-zap-type          like ub.goods.gds-type    no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name    no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name  no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo .
define variable gds-zap-nds           like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-np            like ub.stk-tot.sum-base  no-undo .

define variable f-ostatok-start    as   char  no-undo.
define variable f-ostatok-end      as   char  no-undo.
define variable ostatok-start      as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable ostatok-end        as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.

define variable mediator-host-code as integer no-undo .
define variable f-flag             as logical no-undo .
{ rep/repfrm.i def}


 &glob bef-disc disc
 &glob bef-eff  eff
 &glob bef-prc  prc

 &glob bef-sum-cost sum-cost
 &glob bef-sum-crsa sum-crsa
 &glob bef-sum-sale sum-sale

{ rep/def-ob.i tdedt_pri_vnesh }
{ rep/def-ob.i tdedt_ras_vnesh }
{ rep/def-ob.i tdedt_ras_vnesh_vp   }
{ rep/def-ob.i tdedt_ras_vnesh_kass }
{ rep/def-ob.i tdedt_vozvrat_vnesh  }
{ rep/def-ob.i tdedt_vozvrat_vnesh_kass }
{ rep/def-ob.i tdedt_spi_vnesh          }
{ rep/def-ob.i tdedt_inv                }
{ rep/def-ob.i tdedt_pri_perem     }
{ rep/def-ob.i tdedt_ras_perem     }
{ rep/def-ob.i tdedt_vozvrat_perem }
{ rep/def-ob.i tdedt_ras_prvo }
{ rep/def-ob.i tdedt_spi_prvo }
{ rep/def-ob.i tdedt_pri_prvo }
{ rep/def-ob.i tdedt_overturn }
{ rep/def-ob.i TDEDT_Chg_Purch_Code }
{ rep/def-ob.i TDEDT_Corr_Acc_Price }
{ rep/def-ob.i disc }
{ rep/def-ob.i eff  }
{ rep/def-ob.i prc  }

{ rep/def-ob.i sum-cost }
{ rep/def-ob.i sum-crsa }
{ rep/def-ob.i sum-sale }
{ rep/procobor.i def-tt }
{ rep/procobor.i func-vat }

/* терминальные значения */
define temp-table tmp-gds-tree no-undo
  field id as integer
  field node-code   like ub.gds-grp.node-code
  field lvl         like ub.gds-grp.lvl-num
  field upper-cod   like ub.gds-grp.upper-code
  field f-name      like ub.goods.grp-name
  field {&bef-tdedt_pri_vnesh     }       as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_ras_vnesh     }       as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_ras_vnesh_vp  }       as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_ras_vnesh_kass}       as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_vozvrat_vnesh }       as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_vozvrat_vnesh_kass }  as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_spi_vnesh       }   as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_inv             }    as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_pri_perem       }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_ras_perem       }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_vozvrat_perem   }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_ras_prvo        }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_spi_prvo        }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_pri_prvo        }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_overturn        }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_Chg_Purch_Code  }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_Corr_Acc_Price  }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field disc                             as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field eff                              as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field prc                              as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field ostatok-start                    as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field ostatok-end                      as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field oborot-sum-sale                  as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field oborot-sum-cost                  as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
 index pi id
 index i-name f-name
 index i-code  node-code
.

define variable nn      as     int  no-undo.
define variable report1 as     int no-undo.
define variable report2 as     int no-undo.
define variable errorlevel as  int no-undo.
define variable first-lavel as integer no-undo .
define variable sf1 as handle .
define variable sf2 as handle .
create editor sf1 .
create editor sf2 .

define variable  fact-order-1   like ub.stk-tot.fact-order no-undo.
define variable  quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.

define variable  fact-order-2   like ub.stk-tot.fact-order no-undo.
define variable  quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r2       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v2       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r2         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v2         like ub.stk-tot.sum-rubl   no-undo.


define variable  quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.

define variable  coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable  temp-str-2 as char no-undo.

define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable xlavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
  allcol = num-entries(sizes) - 1 .
&glob f-q "->>>>>>>>>9.999"
&glob f-s "->>>>>>>>>>9.99"
/*----------------------------------------------------------------------------------------------------------------------*/
&scop acc-tree-term  n = n + 1 .                                                                      ~
find first tmp-gds-tree where  tmp-gds-tree.node-code  = b_gds-grp.node-code no-error .               ~
if not available tmp-gds-tree then do:                                                                ~
create tmp-gds-tree.                                                                                  ~
end.                                                                                                  ~
assign                                                                                                ~
tmp-gds-tree.id  = n                                                                                  ~
tmp-gds-tree.f-name     = b_goods.grp-name                                                            ~
tmp-gds-tree.node-code  = b_gds-grp.node-code                                                         ~
tmp-gds-tree.lvl        = b_gds-grp.lvl-num                                                           ~
tmp-gds-tree.upper-cod  = b_gds-grp.upper-code                                                        ~
.                                                                                                     ~
/*  расчет оборотов */                                                                                ~
assign                                                                                                ~
gds-zap-artic      = b_goods.artic                                                                    ~
gds-zap-prod-type  = b_goods.prod-type                                                                ~
gds-zap-prod-code  = b_goods.prod-code                                                                ~
gds-zap-type       = b_goods.gds-type                                                                 ~
.                                                                                                     ~
run foreach  in this-procedure .                                                                      ~
do n-1 = 1 to ~{&e-col} :                                                                             ~
assign                                                                                                ~
tmp-gds-tree.~{&bef-tdedt_pri_vnesh }        [n-1]  = tmp-gds-tree.~{&bef-tdedt_pri_vnesh }        [n-1]  + oborot-~{&bef-tdedt_pri_vnesh }        [n-1]~
tmp-gds-tree.~{&bef-tdedt_ras_vnesh  }       [n-1]  = tmp-gds-tree.~{&bef-tdedt_ras_vnesh  }       [n-1]  + oborot-~{&bef-tdedt_ras_vnesh  }       [n-1]~
tmp-gds-tree.~{&bef-tdedt_ras_vnesh_vp }     [n-1]  = tmp-gds-tree.~{&bef-tdedt_ras_vnesh_vp }     [n-1]  + oborot-~{&bef-tdedt_ras_vnesh_vp }     [n-1]~
tmp-gds-tree.~{&bef-tdedt_ras_vnesh_kass}    [n-1]  = tmp-gds-tree.~{&bef-tdedt_ras_vnesh_kass}    [n-1]  + oborot-~{&bef-tdedt_ras_vnesh_kass}    [n-1]~
tmp-gds-tree.~{&bef-tdedt_vozvrat_vnesh }    [n-1]  = tmp-gds-tree.~{&bef-tdedt_vozvrat_vnesh }    [n-1]  + oborot-~{&bef-tdedt_vozvrat_vnesh }    [n-1]~
tmp-gds-tree.~{&bef-tdedt_vozvrat_vnesh_kass}[n-1] = tmp-gds-tree.~{&bef-tdedt_vozvrat_vnesh_kass} [n-1]  + oborot-~{&bef-tdedt_vozvrat_vnesh_kass}[n-1]~
tmp-gds-tree.~{&bef-tdedt_spi_vnesh         }[n-1]  = tmp-gds-tree.~{&bef-tdedt_spi_vnesh         }[n-1]  + oborot-~{&bef-tdedt_spi_vnesh         }[n-1]~
tmp-gds-tree.~{&bef-tdedt_inv              } [n-1]  = tmp-gds-tree.~{&bef-tdedt_inv              } [n-1]  + oborot-~{&bef-tdedt_inv              } [n-1]~
tmp-gds-tree.~{&bef-tdedt_pri_perem       }  [n-1]  = tmp-gds-tree.~{&bef-tdedt_pri_perem       }  [n-1]  + oborot-~{&bef-tdedt_pri_perem       }  [n-1]~
tmp-gds-tree.~{&bef-tdedt_ras_perem       }  [n-1]  = tmp-gds-tree.~{&bef-tdedt_ras_perem       }  [n-1]  + oborot-~{&bef-tdedt_ras_perem       }  [n-1]~
tmp-gds-tree.~{&bef-tdedt_vozvrat_perem   }  [n-1]  = tmp-gds-tree.~{&bef-tdedt_vozvrat_perem   }  [n-1]  + oborot-~{&bef-tdedt_vozvrat_perem   }  [n-1]~
tmp-gds-tree.~{&bef-tdedt_ras_prvo        }  [n-1]  = tmp-gds-tree.~{&bef-tdedt_ras_prvo        }  [n-1]  + oborot-~{&bef-tdedt_ras_prvo        }  [n-1]~
tmp-gds-tree.~{&bef-tdedt_spi_prvo        }  [n-1]  = tmp-gds-tree.~{&bef-tdedt_spi_prvo        }  [n-1]  + oborot-~{&bef-tdedt_spi_prvo        }  [n-1]~
tmp-gds-tree.~{&bef-tdedt_pri_prvo        }  [n-1]  = tmp-gds-tree.~{&bef-tdedt_pri_prvo        }  [n-1]  + oborot-~{&bef-tdedt_pri_prvo        }  [n-1]~
tmp-gds-tree.~{&bef-tdedt_overturn        }  [n-1]  = tmp-gds-tree.~{&bef-tdedt_overturn        }  [n-1]  + oborot-~{&bef-tdedt_overturn        }  [n-1]~
tmp-gds-tree.~{&bef-tdedt_Chg_Purch_Code}  [n-1]  = tmp-gds-tree.~{&bef-tdedt_Chg_Purch_Code}  [n-1]  + oborot-~{&bef-tdedt_Chg_Purch_Code}  [n-1]~
tmp-gds-tree.~{&bef-tdedt_Corr_Acc_Price}  [n-1]  = tmp-gds-tree.~{&bef-tdedt_Corr_Acc_Price}  [n-1]  + oborot-~{&bef-tdedt_Corr_Acc_Price}  [n-1]~
tmp-gds-tree.disc                           [n-1]  = tmp-gds-tree.disc                           [n-1]  + oborot-disc                           [n-1]   ~
tmp-gds-tree.ostatok-start                  [n-1]  = tmp-gds-tree.ostatok-start                  [n-1]  + ostatok-start                         [n-1]   ~
tmp-gds-tree.ostatok-end                    [n-1]  = tmp-gds-tree.ostatok-end                    [n-1]  + ostatok-end                           [n-1]   ~
tmp-gds-tree.oborot-sum-sale                [n-1]  = tmp-gds-tree.oborot-sum-sale                [n-1]  + oborot-sum-sale                        [1]    ~
tmp-gds-tree.oborot-sum-cost                [n-1]  = tmp-gds-tree.oborot-sum-cost               [n-1]  + oborot-sum-cost                        [1]    ~
.              ~
end.
/*----------------------------------------------------------------------------------------------------------------------*/

{ rep/repfrm.i on 25}
{ rep/repfrm.i disp i-str reportname objname}
t-time = time.
     assign
        number-list    = 1
        i              = 0
        xlavel         = xvar-lavel
        select-good    = x-selectgood
        paytype        = x-set_pay_type
        retclassify    = xclassify
        retsorttype    = xsorttype
        sums-only      = xsumsonly
        show-negativ   = xshowzero
        x-selectobject = "".
        firstline      = false.
        valtype        = if (paytype = 1) then 0  else x-set_val_type.

    if x-vat then x-vat = false .
            else x-vat = true .

    if x-vat then v-name-type = "учет.".
             else  v-name-type = "учет-НДС".

  if  x-date-end  - x-date-start > 100
      then long-p = true    .
      else  long-p = false     .

  find first ub.gds-grp where  ub.gds-grp.upper-code = 0 no-lock no-error .
  if avail ub.gds-grp then  first-lavel = ub.gds-grp.node-code.
                   else first-lavel = 0.

  valtype         = if (paytype = 1) then 0  else x-set_val_type.

  if (valtype=0 and x-base-code=0)  or valtype=1
    then assign tprintrubl = yes .
    else assign tprintrubl = no .

  run make-tt-ed in this-procedure /* какие sum-type */ .
  run find-mediator  in this-procedure
     ( input  v-cntxt-host-code-obj ,
       input  xshowmediator,
       output mediator-host-code,
       output f-flag) .
  if f-flag = false then return.

  g-ll = xlavel .
  if select-good <> {&g-grp} then do:
  run pp in this-procedure (1,first-lavel,"").
  end.
  else do:
  run ppgrp in this-procedure (1,first-lavel,"").
  end.
  run report-execute in this-procedure .

/*----internal func & proc ----------------------------------------------------------------------------------------------*/
{ rep/f-flav.i }
procedure report-execute :
  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .
    p-file-name =  string( session:temp-directory +
                                  {&df_name} + string( g#report-num ) + ".txt" ) .

    output stream outstream to value( string( session:temp-directory +
                                  {&df_name} + string( g#report-num ) ) )      .
    output stream outstream2 to value(p-file-name).

    /* создаем временный файл */
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
                put stream  outstream  "1" format "x(100)" skip .
    v-ind = 1    .
    num#str# = 0 .

    num#str# = num#str# + 1 .
    num#col# =  1 .

      run macr_excel_char ( reportname , num#str# , num#col#  ).
      run macr_cell_format
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */

define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-nn as integer   no-undo .

&scop var-print-n  v-nn = num-entries ( ~{&var-str-n} , "~{&new-line}"  ) .  do l-ii = 1 to v-nn :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char (                                                          ~
              substring (entry ( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
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
  run macr_excel_char (
       cur-time-print()  +
      " Цены указаны в " +
      (if tprintrubl then "{&abbr_rub_allshift}" else x-base-type )
      , num#str#
      , num#col#
        ) .
/*Печать шапки */
define variable old-s as integer no-undo .
define variable old-s2 as integer no-undo .
assign
old-s =   num#str#
.

run make-col.
assign
old-s2 =   num#str#
.

   num#str# = old-s + 1.
   run proc-print-header.
   num#str# = old-s2.
   define variable gj as integer no-undo init 0.
   if xtog-obj /* раздельно по объектам */ then do:
      for each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          run report-exec1 in this-procedure .
          gj = gj + 1 .
      end.
      if gj > 1 then   run display-bo in this-procedure .
      end.
   else  run report-exec1 in this-procedure .

   message  " Время составления отчета " + string((time - t-time),"hh:mm:ss" ) .
   output stream outstream close.
   output stream outstream2 close.
  output stream macr_excel  close .
  { rep/repfrm.i off}
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .

  run end-proc .
  { rep/repfrm.i off}
  run rep/runexcel.p (p-file-name ).

end procedure.

procedure report-exec1 :
   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code no-lock no-error.

           if available clients then  objname = clients.obj-name.
                                         else  objname="объект не определен".
  run calcitog in this-procedure .
  run print-header in this-procedure .   /* проход по списку товаров 1 2 3-№ поиска */
  run run2 in this-procedure .
  run print-det in this-procedure .
  run print-footer in this-procedure .
end procedure.

procedure run2 :

  for each tmp-gds-tree :
      delete tmp-gds-tree  .
  end.

  case select-good :
      when {&g-all}   then do: run run21 in this-procedure .  end.
      when {&g-grp}   then do: run run22 in this-procedure .  end.
      when {&g-prod}  then do: run run23 in this-procedure .  end.
      otherwise do:
        run run24 in this-procedure .
      end.

  end case.

end procedure.

procedure run21 : /* cоздается ТТ с терминальными значениями */
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xTog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xTog-obj = true         .

define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     ( o-Tog-obj = false OR
        ( obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ) ) :
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code    and
                not
                (b_gds-obj.last-doc <> date('')     and
                b_gds-obj.last-doc < x-date-start   and
                b_gds-obj.fact-qnty = 0             and
                b_gds-obj.avrg-qnty = 0  ) :

        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            {&acc-tree-term }
          end.
      end. /* gds-obj */
   end. /* obj-list */
assign
   xTog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code

.

end procedure.


procedure run24 : /* cоздается ТТ с терминальными значениями */
define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .

define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xTog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xTog-obj = true         .

   for each obj-list  :
      if  o-tog-obj = true  then   do:
         if not
        ( obj-list.obj-type = x-store-type and obj-list.obj-code = x-store-code ) then next.

      end.
      x-store-type = obj-list.obj-type.
      x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code    and
                not
                (b_gds-obj.last-doc <> date('')     and
                b_gds-obj.last-doc < x-date-start   and
                b_gds-obj.fact-qnty = 0             and
                b_gds-obj.avrg-qnty = 0  ) ,
                first gds-list where gds-list.gds-code = b_gds-obj.gds-code :
        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            {&acc-tree-term }
          end.
      end. /* gds-obj */
   end. /* obj-list */


assign
   xTog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code

.


end procedure.


procedure run22 : /* cоздается ТТ с терминальными значениями */
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xTog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xTog-obj = true         .

define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     ( o-Tog-obj = false OR
        ( obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ))  :
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code    and
                not
                (b_gds-obj.last-doc <> date('')     and
                b_gds-obj.last-doc < x-date-start   and
                b_gds-obj.fact-qnty = 0             and
                b_gds-obj.avrg-qnty = 0  ) ,
         First  tmp#grp  WHERE trim(b_gds-obj.grp-name)   begins  trim(tmp#grp.grp-name)
                :

        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            {&acc-tree-term }
          end.
      end. /* gds-obj */
   end. /* obj-list */
assign
   xTog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code

.

end procedure.


procedure run23 : /* cоздается ТТ с терминальными значениями */
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xTog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xTog-obj = true         .

define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     ( o-Tog-obj = false OR
        ( obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ))  :
  x-store-type = obj-list.obj-type.
  x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code    and
                not
                (b_gds-obj.last-doc <> date('')     and
                b_gds-obj.last-doc < x-date-start   and
                b_gds-obj.fact-qnty = 0             and
                b_gds-obj.avrg-qnty = 0  ) ,
        first g#cli
              where b_gds-obj.prod-code   = g#cli.obj-code
              and   b_gds-obj.prod-type   = g#cli.obj-type
                :

        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            {&acc-tree-term }
          end.
      end. /* gds-obj */
   end. /* obj-list */
assign
   xTog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code

.

end procedure.

procedure print-det :
define variable n-1 as integer no-undo .
/*
for each tmp-gds :
 message "*" skip tmp-gds.f-name  tmp-gds.lvl.
end.

for each tmp-gds-tree :
 message "-*-" skip  tmp-gds-tree.f-name  tmp-gds-tree.lvl.
end.
22         44
*/

{ rep/repfrm.i disp i-str "'Суммирование дерева'" }

   /* для печати */
    for each tmp-gds no-lock   :
        run clear-b1  in this-procedure .
        for each tmp-gds-tree no-lock
            where (trim(tmp-gds-tree.f-name) begins trim(tmp-gds.f-name)  ):

             i-str = i-str + 1 .
              { rep/repfrm.i disp i-str "'Суммирование дерева по группам '" tmp-gds.f-name }
                  do n-1 = 1 to {&e-col} :
                  assign
                    b1-oborot-{&bef-tdedt_pri_vnesh }        [n-1]  = tmp-gds-tree.{&bef-tdedt_pri_vnesh }        [n-1]  + b1-oborot-{&bef-tdedt_pri_vnesh }        [n-1]
                    b1-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]  = tmp-gds-tree.{&bef-tdedt_ras_vnesh  }       [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]
                    b1-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]  = tmp-gds-tree.{&bef-tdedt_ras_vnesh_vp }     [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]
                    b1-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]  = tmp-gds-tree.{&bef-tdedt_ras_vnesh_kass}    [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]
                    b1-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]  = tmp-gds-tree.{&bef-tdedt_vozvrat_vnesh }    [n-1]  + b1-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]
                    b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1] = tmp-gds-tree.{&bef-tdedt_vozvrat_vnesh_kass} [n-1]  + b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1]
                    b1-oborot-{&bef-tdedt_spi_vnesh         }[n-1]  = tmp-gds-tree.{&bef-tdedt_spi_vnesh         }[n-1]  + b1-oborot-{&bef-tdedt_spi_vnesh         }[n-1]
                    b1-oborot-{&bef-tdedt_inv              } [n-1]  = tmp-gds-tree.{&bef-tdedt_inv              } [n-1]  + b1-oborot-{&bef-tdedt_inv              } [n-1]
                    b1-oborot-{&bef-tdedt_pri_perem       }  [n-1]  = tmp-gds-tree.{&bef-tdedt_pri_perem       }  [n-1]  + b1-oborot-{&bef-tdedt_pri_perem       }  [n-1]
                    b1-oborot-{&bef-tdedt_ras_perem       }  [n-1]  = tmp-gds-tree.{&bef-tdedt_ras_perem       }  [n-1]  + b1-oborot-{&bef-tdedt_ras_perem       }  [n-1]
                    b1-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]  = tmp-gds-tree.{&bef-tdedt_vozvrat_perem   }  [n-1]  + b1-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]
                    b1-oborot-{&bef-tdedt_ras_prvo        }  [n-1]  = tmp-gds-tree.{&bef-tdedt_ras_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_ras_prvo        }  [n-1]
                    b1-oborot-{&bef-tdedt_spi_prvo        }  [n-1]  = tmp-gds-tree.{&bef-tdedt_spi_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_spi_prvo        }  [n-1]
                    b1-oborot-{&bef-tdedt_pri_prvo        }  [n-1]  = tmp-gds-tree.{&bef-tdedt_pri_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_pri_prvo        }  [n-1]
                    b1-oborot-{&bef-tdedt_overturn        }  [n-1]  = tmp-gds-tree.{&bef-tdedt_overturn        }  [n-1]  + b1-oborot-{&bef-tdedt_overturn        }  [n-1]
                    b1-oborot-{&bef-tdedt_Chg_Purch_Code  }  [n-1]  = tmp-gds-tree.{&bef-tdedt_Chg_Purch_Code  }  [n-1]  + b1-oborot-{&bef-tdedt_Chg_Purch_Code   } [n-1]
                    b1-oborot-{&bef-tdedt_Corr_Acc_Price  }  [n-1]  = tmp-gds-tree.{&bef-tdedt_Corr_Acc_Price  }  [n-1]  + b1-oborot-{&bef-tdedt_Corr_Acc_Price   } [n-1]
                    b1-oborot-disc                           [n-1]  = tmp-gds-tree.disc                           [n-1]  + b1-oborot-disc                           [n-1]
                    b1-ostatok-start                         [n-1]  = tmp-gds-tree.ostatok-start                  [n-1]  + b1-ostatok-start                         [n-1]
                    b1-ostatok-end                           [n-1]  = tmp-gds-tree.ostatok-end                    [n-1]  + b1-ostatok-end                           [n-1]
                    b1-oborot-sum-sale                       [n-1]  = tmp-gds-tree.oborot-sum-sale                [n-1]  + b1-oborot-sum-sale                       [n-1]
                    b1-oborot-sum-cost                       [n-1]  = tmp-gds-tree.oborot-sum-cost                [n-1]  + b1-oborot-sum-cost                       [n-1]
                  .
                 end.
                 i = i + 1 .
        end.  /* foreach tmp-gds-tree */

        b1-oborot-{&bef-eff}[1 ]  = (b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) .

        if  b1-oborot-sum-cost[2] <>  0 then
            b1-oborot-{&bef-prc}[1] = 100 * (b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) / b1-oborot-sum-cost[2] .
            else b1-oborot-{&bef-prc}[1] = 0.

            if not
            (
              b1-oborot-{&bef-tdedt_pri_vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh_vp }              [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh_kass }            [1]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_vnesh }             [1]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass }        [1]    = 0 and
              b1-oborot-{&bef-tdedt_spi_vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_inv }                       [1]    = 0 and
              b1-oborot-{&bef-tdedt_pri_perem }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_perem }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_perem }             [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_prvo }                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_spi_prvo }                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_pri_prvo }                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_overturn }                  [1]    = 0 and
              b1-oborot-{&bef-disc }                            [1]    = 0 and
              b1-oborot-{&bef-tdedt_Chg_Purch_Code  }           [1]    = 0 and
              b1-oborot-{&bef-tdedt_Corr_Acc_Price  }           [1]    = 0 and
              b1-ostatok-end                                    [1]    = 0 and
              b1-ostatok-start                                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_pri_vnesh }                 [2]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh }                 [2]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh_vp }              [2]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh_kass }            [2]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_vnesh }             [2]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass }        [2]    = 0 and
              b1-oborot-{&bef-tdedt_spi_vnesh }                 [2]    = 0 and
              b1-oborot-{&bef-tdedt_inv }                       [2]    = 0 and
              b1-oborot-{&bef-tdedt_pri_perem }                 [2]    = 0 and
              b1-oborot-{&bef-tdedt_ras_perem }                 [2]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_perem }             [2]    = 0 and
              b1-oborot-{&bef-tdedt_ras_prvo }                  [2]    = 0 and
              b1-oborot-{&bef-tdedt_spi_prvo }                  [2]    = 0 and
              b1-oborot-{&bef-tdedt_pri_prvo }                  [2]    = 0 and
              b1-oborot-{&bef-tdedt_overturn }                  [2]    = 0 and
              b1-oborot-{&bef-disc }                            [2]    = 0 and
              b1-oborot-{&bef-tdedt_Chg_Purch_Code  }           [2]    = 0 and
              b1-oborot-{&bef-tdedt_Corr_Acc_Price  }           [2]    = 0 and
              b1-ostatok-end                                    [2]    = 0 and
              b1-ostatok-start                                  [2]    = 0 and

              b1-oborot-{&bef-tdedt_overturn }                  [2]    = 0
              )  then do:
                  assign
                    tmp-gds.name =  tmp-gds.name
                    s-bar-code       = substring(tmp-gds.name,1,9)
                    sf1:screen-value = substring(tmp-gds.name,10,1)
                    gds-zap-artic    = substring(tmp-gds.name,11,16)
                    sf2:screen-value = substring(tmp-gds.name,27,1)
                    gds-zap-gds-name = substring(tmp-gds.name,28,40)
                    no-error .



                    run display-b1  in this-procedure .
                    if tmp-gds.lvl = 1 then do:
                       run calc-s-itog   in this-procedure .
                    end.
                    run clear-b1  in this-procedure .
                    assign
                      sf1:screen-value =""
                      sf2:screen-value =""
                      no-error .
                end.
   end.
end procedure. /* print-det */

procedure foreach :

  assign
    p-price-med = 0
    null-str# = 1
    i-str = i-str + 1
  .

  /* Найдем цену посредника по этому товару */
  if xshowmediator = true then do :
       run find-last-prise-med in this-procedure (
          input gds-zap-artic ,
          input gds-zap-prod-type ,
          input gds-zap-prod-code ,
          input mediator-host-code ,
          output p-price-med   )
          .
    end.

 { rep/repfrm.i disp i-str reportname objname }

/* на начало  остатки */
  run clear-item  in this-procedure .
{ rep/io-tree.i fact-order-1 arh-cost 0 start }
if xshowcrsa or xshowcrsands or use-column[23] or use-column[24] or xshowmediator then do :
   { rep/io-tree.i fact-order-1 arh-crsa 3 start}
   end.
if xshowsale or xshowsalends or xshowsaleslt then do:
   { rep/io-tree.i fact-order-1 arh-crsa 6 start}
   end.


/* на конец  остатки */
{ rep/io-tree.i fact-order-2 arh-cost 0 end }
if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator then do :
   { rep/io-tree.i fact-order-2 arh-crsa 3 end}
   end.
if xshowsale or xshowsalends or xshowsaleslt then do :
   { rep/io-tree.i fact-order-2 arh-crsa 6 end}
   end.

 /* Обороты */
   if gds-zap-type = {&gds-goods} then { rep/r-ob-ln.i {&arh-cost} ''}
                                  else { rep/r-ob-ln.i {&arh-cost-service} ''}

   if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator   then do:
      if gds-zap-type = {&gds-goods}  then { rep/r-ob-ln.i {&arh-crsa} ''}
                                      else { rep/r-ob-ln.i {&arh-crsa-service} ''}
   end.

   if xshowsale or xshowsalends
      or use-column[21] or use-column[23] or use-column[24]   or xshowmediator  then do:
      if gds-zap-type = {&gds-goods}  then { rep/r-ob-ln.i {&arh-sale} ''}
                                      else { rep/r-ob-ln.i {&arh-sale-service} ''}

   end.
end procedure.


procedure display-line :
end procedure.


procedure print-header :
  assign
     firstline = true
     num#str#  = num#str#  + 1
     num#col# = 1
  .

    if xtog-obj and x-selectobject <> "currency":u   then  do :
       run macr_excel_char( string("ПО ОБЪЕКТУ : " + caps(objname) )  , num#str# , num#col#  ) .
    end.

      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
      run clear-bi in this-procedure .
      break_group = true.
      break_group1 = true.
   end procedure.


procedure print-footer :
     num#str# = num#str# + 1.
     num#col# = 1.
     run macr_excel_char( string("ИТОГО"  )  , num#str# , num#col#  ) .
     run display-bi in this-procedure .

end procedure.

procedure calcitog :
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start - 1 ,
        input date('')      , ?, ?,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xtog-obj ,

        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-1 ).
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start  ,
        input x-date-end    ,  ?, ?,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xtog-obj ,

        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-2 ).
/*эти не нужны*/
          quantity1  = 0.
          coast_r1   = 0.
          coast_v1   = 0.
          vat_r1     = 0.
          vat_v1     = 0.

end procedure.
procedure display-str1  :
 end procedure.


procedure display-bi  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  num#col#  = 0 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .

  run macr_cell_format
                              ( 10    ,      /* p-size     */
                                true  ,      /* p-bold     */
                                false ,      /* p-italic   */
                                ?    ,       /* p-color-bg */
                                num#str# ,   /* p-row      */
                                1 ,          /* p-col      */
                                num#str# ,   /* p-row-2    */
                                (mp + ll + (kk * ({&max-col-rep} - {&const-col-rep})))   /* p-col-2    */
                                ) .

{ rep/xl-obstr.i bi-}
run clear-bi  in this-procedure .

end procedure.

procedure display-bo  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char ( string("ИТОГО ПО ОБЪЕКТАМ")  , num#str# , num#col#  ) .

  num#col#  = 0 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .
  run macr_cell_format
      ( 10    ,      /* p-size     */
        true  ,      /* p-bold     */
        false ,      /* p-italic   */
        ?    ,       /* p-color-bg */
        num#str# ,   /* p-row      */
        1 ,          /* p-col      */
        num#str# ,   /* p-row-2    */
        (mp + ll + (kk * ({&max-col-rep} - {&const-col-rep})))   /* p-col-2    */
        ) .

   { rep/xl-obstr.i bo-}

   run clear-bo  in this-procedure .
end procedure.


procedure display-b1  :

define variable ll as int no-undo.
define variable kk as int no-undo.
  num#str#  = num#str#  + 1     .
  num#col# = 2              .
  if substitute( "&1", sf1:screen-value )  <> "?" then do:
      run macr_excel_char (  caps(  s-bar-code +
                                  sf1:screen-value +
                                  gds-zap-artic +
                                  sf2:screen-value +
                                  gds-zap-gds-name +
                                  temp-str-2         )  , num#str# , num#col#  ) .

                       end.

   else do:
       run macr_excel_char (  caps(  s-bar-code +
                                                      gds-zap-artic +
                                                      gds-zap-gds-name +
                                                      temp-str-2         )  , num#str# , num#col#  ) .
                       end.

   num#col# = 0  .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .


  { rep/xl-obstr.i b1-}
  run macr_cell_format
  ( 10    ,      /* p-size     */
    true  ,      /* p-bold     */
    true  ,      /* p-italic   */
    36    ,      /* p-color-bg */
    num#str# ,      /* p-row      */
    1 ,      /* p-col      */
    num#str# ,      /* p-row-2    */
    num#col# ) .           /* p-col-2    */

  run new-tmp-page .
end procedure.

procedure display-b2  :
end procedure.
procedure clear-b1  :
 { rep/o-clear.i b1}
end procedure.
procedure clear-b2  :
 { rep/o-clear.i b2}
end procedure.
procedure clear-bi  :
 { rep/o-clear.i bi}
end procedure.
procedure clear-bo  :
 { rep/o-clear.i bo}
end procedure.



procedure ob-line  :
 { rep/ob-line.i }
end procedure.

 { rep/ost-line.i }
 { rep/ostatok.i }


procedure calc-sub-itog :
def input parameter tt as int no-undo.
define variable tt2 as integer no-undo .

  if tt = 6 then tt2 = 7 .
            else tt2 = tt.

repeat i# = 1 + tt to 3 + tt2 :
  { rep/run-ii.i tdedt_inv           tdedt_pri_vnesh tt }
  { rep/run-ii.i tdedt_pri_perem     tdedt_ras_vnesh tt }
  { rep/run-ii.i tdedt_ras_perem     tdedt_ras_vnesh_vp tt }
  { rep/run-ii.i tdedt_vozvrat_perem tdedt_ras_vnesh_kass tt }
  { rep/run-ii.i tdedt_ras_prvo tdedt_vozvrat_vnesh tt }
  { rep/run-ii.i tdedt_pri_prvo tdedt_vozvrat_vnesh_kass tt }
  { rep/run-ii.i tdedt_overturn tdedt_spi_vnesh tt }
  { rep/run-ii.i TDEDT_Corr_Acc_Price      TDEDT_Chg_Purch_Code tt }

  b1-oborot-{&bef-tdedt_ras_prvo}[ i#] = b1-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].
  b2-oborot-{&bef-tdedt_ras_prvo}[ i#] = b2-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].
  if tmp-gds.lvl <= 1 then do:
    bi-oborot-{&bef-tdedt_ras_prvo}[ i#] = bi-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].
    bo-oborot-{&bef-tdedt_ras_prvo}[ i#] = bo-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].
  end.

  if i# = 8 then
    assign
      bi-oborot-sum-sale[ i#]  = bi-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              bi-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              bi-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              bi-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]

      b1-oborot-sum-sale[ i#]  = b1-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              b1-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              b1-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]

      b2-oborot-sum-sale[ i#]  = b2-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              b2-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              b2-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
      bo-oborot-sum-sale[ i#]  = bo-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              bo-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              bo-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              bo-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
      .
  if  xshowmediator = true  then do:
      if i# = 8 then b1-oborot-sum-cost[2 ]  = b1-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then b2-oborot-sum-cost[2 ]  = b2-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then bi-oborot-sum-cost[2 ]  = bi-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then bo-oborot-sum-cost[2 ]  = bo-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  end.


  if i# = 2 and  xshowmediator = false  then
      assign
        bi-oborot-sum-cost[ i#]  = bi-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                bi-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                bi-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                bi-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]


        b1-oborot-sum-cost[ i#]  = b1-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                b1-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                b1-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]

        b2-oborot-sum-cost[ i#]  = b2-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                b2-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                b2-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
        bo-oborot-sum-cost[ i#]  = bo-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                bo-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                bo-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                bo-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
        .

  if i# = 7 then b1-oborot-{&bef-disc}[ 1]  = b1-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .
  if i# = 7 then b2-oborot-{&bef-disc}[ 1]  = b2-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .
  if tmp-gds.lvl <= 1 then do:
      if i# = 7 then bi-oborot-{&bef-disc}[ 1]  = bi-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .
      if i# = 7 then bo-oborot-{&bef-disc}[ 1]  = bo-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .

      if i# = 8 then bi-oborot-{&bef-eff}[1 ]  = bi-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .
      if i# = 8 then bo-oborot-{&bef-eff}[1 ]  = bo-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .


          if i# = 8 then    if  bi-oborot-sum-cost[2] <>  0 then
                                bi-oborot-{&bef-prc}[1] = 100 * (bi-oborot-sum-sale[8] - bi-oborot-sum-cost[2] ) / bi-oborot-sum-cost[2] .
                                else bi-oborot-{&bef-prc}[1] = 0.

          if i# = 8 then    if  bo-oborot-sum-cost[2] <>  0 then
                                bo-oborot-{&bef-prc}[1] = 100 * (bo-oborot-sum-sale[8] - bo-oborot-sum-cost[2] ) / bo-oborot-sum-cost[2] .
                                else bo-oborot-{&bef-prc}[1] = 0.


      bo-ostatok-start[ i#]  = bo-ostatok-start[i#]  + ostatok-start[ i#]  .
      bo-ostatok-end[ i#]    = bo-ostatok-end[i#]    + ostatok-end[ i#]    .

  end.
  if i# = 8 then b1-oborot-{&bef-eff}[1 ]  = b1-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .
  if i# = 8 then b2-oborot-{&bef-eff}[1 ]  = b2-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .

          if i# = 8 then    if  b1-oborot-sum-cost[2] <>  0 then
                                b1-oborot-{&bef-prc}[1] = 100 * (b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) / b1-oborot-sum-cost[2] .
                                else b1-oborot-{&bef-prc}[1] = 0.
          if i# = 8 then    if  b2-oborot-sum-cost[2] <>  0 then
                                b2-oborot-{&bef-prc}[1] = 100 * (b2-oborot-sum-sale[8] - b2-oborot-sum-cost[2] ) / b2-oborot-sum-cost[2] .
                                else b2-oborot-{&bef-prc}[1] = 0.
 end.
end procedure.


procedure sum-i :
def input parameter ob like oborot-{&bef-tdedt_overturn}[1] no-undo.
def input parameter tt as int  no-undo.
def input-output parameter b1 like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
def input-output parameter b2 like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
def input-output parameter bi like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
def input-output parameter bo like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
def input parameter ob2 like oborot-{&bef-tdedt_overturn}[1] no-undo.
def input-output parameter b1- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
def input-output parameter b2- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
def input-output parameter bi- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
def input-output parameter bo- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
assign
 b1  = b1 + ob
 b2  = b2 + ob
 b1- = b1- + ob2
 b2- = b2- + ob2
 .

if tmp-gds.lvl <= 1 then do:
    assign
    bi = bi + ob
    bo = bo + ob
    bi- = bi- + ob2
    bo- = bo- + ob2
    .
end.
end procedure.

procedure clear-item :
define variable kk as int no-undo.
 repeat kk = 1 to {&e-col} :
 assign
    oborot-{&bef-tdedt_pri_vnesh }                 [kk]    = 0
    oborot-{&bef-tdedt_ras_vnesh }                 [kk]    = 0
    oborot-{&bef-tdedt_ras_vnesh_vp }              [kk]    = 0
    oborot-{&bef-tdedt_ras_vnesh_kass }            [kk]    = 0
    oborot-{&bef-tdedt_vozvrat_vnesh }             [kk]    = 0
    oborot-{&bef-tdedt_vozvrat_vnesh_kass }        [kk]    = 0
    oborot-{&bef-tdedt_spi_vnesh }                 [kk]    = 0
    oborot-{&bef-tdedt_inv }                       [kk]    = 0
    oborot-{&bef-tdedt_pri_perem }                 [kk]    = 0
    oborot-{&bef-tdedt_ras_perem }                 [kk]    = 0
    oborot-{&bef-tdedt_vozvrat_perem }             [kk]    = 0
    oborot-{&bef-tdedt_ras_prvo }                  [kk]    = 0
    oborot-{&bef-tdedt_spi_prvo }                  [kk]    = 0
    oborot-{&bef-tdedt_pri_prvo }                  [kk]    = 0
    oborot-{&bef-tdedt_overturn }                  [kk]    = 0
    oborot-{&bef-tdedt_Chg_Purch_Code  }           [kk]    = 0
    oborot-{&bef-tdedt_Corr_Acc_Price  }           [kk]    = 0

    oborot-{&bef-disc}                             [kk]    = 0
    oborot-{&bef-eff}                             [kk]    = 0
    oborot-{&bef-prc}                             [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       end.
 end procedure.

procedure item-goods :
 def input parameter  par-3 as char no-undo.
 def input parameter  par-4 as char no-undo.
     if par-4 = "goods":u  then  assign
                                    gds-zap-unit-base  = goods.unit-base
                                    gds-zap-prt-root   = goods.prt-root
                                    gds-zap-prod-type  = goods.prod-type
                                    gds-zap-prod-code  = goods.prod-code
                                    gds-zap-artic      = goods.artic
                                    gds-zap-type       = goods.gds-type
                                    gds-zap-grp-name   = goods.grp-name
                                    gds-zap-b-code     = goods.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then goods.engl-name
                                                                       else goods.gds-name.
     if par-4 = "gds-list":u  then  assign
                                    gds-zap-unit-base  = gds-list.unit-base
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-type       = gds-list.gds-type
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then gds-list.engl-name
                                                                       else gds-list.gds-name.
    run foreach in this-procedure .
    { rep/r-obreak.i &par1=1 }
    run display-line in this-procedure .
 end procedure.


 procedure null-str-pr :
 if (
     oborot-{&bef-tdedt_pri_vnesh}                 [1] = 0  and
     oborot-{&bef-tdedt_ras_vnesh}                 [1] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_vp}              [1] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_kass}            [1] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh}             [1] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [1] = 0  and
     oborot-{&bef-tdedt_spi_vnesh}                 [1] = 0  and
     oborot-{&bef-tdedt_inv}                       [1] = 0  and
     oborot-{&bef-tdedt_pri_perem }                [1] = 0  and
     oborot-{&bef-tdedt_ras_perem }                [1] = 0  and
     oborot-{&bef-tdedt_vozvrat_perem }            [1] = 0  and
     oborot-{&bef-tdedt_overturn }                 [2] = 0  and
     oborot-{&bef-tdedt_Chg_Purch_Code  }          [1] = 0 and
     oborot-{&bef-tdedt_Corr_Acc_Price  }          [1] = 0 and
     ostatok-end[1]                                    = 0  and
     ostatok-start[1]                                  = 0 and
     oborot-{&bef-tdedt_pri_vnesh}                 [2] = 0  and
     oborot-{&bef-tdedt_ras_vnesh}                 [2] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_vp}              [2] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_kass}            [2] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh}             [2] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [2] = 0  and
     oborot-{&bef-tdedt_spi_vnesh}                 [2] = 0  and
     oborot-{&bef-tdedt_inv}                       [2] = 0  and
     oborot-{&bef-tdedt_pri_perem }                [2] = 0  and
     oborot-{&bef-tdedt_ras_perem }                [2] = 0  and
     oborot-{&bef-tdedt_vozvrat_perem }            [2] = 0  and
     oborot-{&bef-tdedt_Chg_Purch_Code  }          [2] = 0 and
     oborot-{&bef-tdedt_Corr_Acc_Price  }          [2] = 0 and
     ostatok-end[2]                                    = 0  and
     ostatok-start[2]                                  = 0

     ) then   null-str# = 0    .
    end procedure.
 procedure null-str-pr2 :
 if (
     oborot-{&bef-tdedt_pri_vnesh}     [1]         = 0  and
     oborot-{&bef-tdedt_ras_vnesh}                 [1] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_vp}              [1] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_kass}            [1] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh}             [1] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [1] = 0  and
     oborot-{&bef-tdedt_spi_vnesh}                 [1] = 0  and
     oborot-{&bef-tdedt_inv}                       [1] = 0  and
     oborot-{&bef-tdedt_pri_perem }                [1] = 0  and
     oborot-{&bef-tdedt_ras_perem }                [1] = 0  and
     oborot-{&bef-tdedt_vozvrat_perem }            [1] = 0  and
     oborot-{&bef-tdedt_Chg_Purch_Code  }           [1]    = 0 and
     oborot-{&bef-tdedt_Corr_Acc_Price  }           [1]    = 0 and
     oborot-{&bef-tdedt_pri_vnesh}     [2]         = 0  and
     oborot-{&bef-tdedt_ras_vnesh}                 [2] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_vp}              [2] = 0  and
     oborot-{&bef-tdedt_ras_vnesh_kass}            [2] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh}             [2] = 0  and
     oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [2] = 0  and
     oborot-{&bef-tdedt_spi_vnesh}                 [2] = 0  and
     oborot-{&bef-tdedt_inv}                       [2] = 0  and
     oborot-{&bef-tdedt_pri_perem }                [2] = 0  and
     oborot-{&bef-tdedt_ras_perem }                [2] = 0  and
     oborot-{&bef-tdedt_vozvrat_perem }            [2] = 0  and
     oborot-{&bef-tdedt_Chg_Purch_Code  }           [2]    = 0 and
     oborot-{&bef-tdedt_Corr_Acc_Price  }           [2]    = 0 and
     oborot-{&bef-tdedt_overturn }                 [2] = 0
     ) then   null-str2# = 0    .
    end procedure.

procedure ex-display :
def input parameter par-1 as int no-undo.
def input parameter par-2 like  ostatok-start[1] no-undo.
def input parameter par-i as int no-undo.
  assign num#col#  = par-1.

  if par-i = 1 then do: /* количества */
    run macr_excel_dec ( round (par-2 ,3)  , num#str# , num#col#   ).
    run macr_cell_format
                    ( 10    ,         /* p-size     */
                      false   ,       /* p-bold     */
                      false   ,       /* p-italic   */
                      15    ,         /* p-color-bg */
                      num#str# ,      /* p-row      */
                      num#col# ,      /* p-col      */
                      num#str# ,      /* p-row-2    */
                      num#col#  ) .   /* p-col-2    */
  end.
  else do:
     run macr_excel_dec ( round (par-2 ,2)  , num#str# , num#col#   ).
  end.


end procedure.

procedure u-line:
end procedure.
procedure p-line:
end procedure.


procedure make-col :
 define variable l#1 as int  no-undo.
 define variable l#2 as int  no-undo.
 define variable l as int  no-undo.

      nk = 0.
      kk = 0.
         if xshowcost    then do: kk = kk + 1. end.
         if xshowcostnds then do: kk = kk + 1. end.
         if xshowcrsa    then do: kk = kk + 1. end.
         if xshowcrsands then do: kk = kk + 1. end.
         if xshowsale    then do: kk = kk + 1. end.
         if xshowsalends then do: kk = kk + 1. end.
         if xshowsaleslt then do: kk = kk + 1. end.
         if xshowmediator then do: kk = kk + 1. end.


   /* Шапка таблицы */
    num#str# = num#str# + 1.
    num#col#  = 0 .
 if use-column[1]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "Код "            , num#str# , num#col# ) . run macr_cell_size (10, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[2]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "Артикул"         , num#str# , num#col# ) . run macr_cell_size (16, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[3]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "Название товара" , num#str# , num#col# ) . run macr_cell_size (60, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[4]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "Ед.изм "         , num#str# , num#col# ) . run macr_cell_size (7 , ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[5]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "т/у"             , num#str# , num#col# ) . run macr_cell_size (4 , ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[21] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "Скидка"          , num#str# , num#col# ) . run macr_cell_size (15, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[23] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "Эффективность"   , num#str# , num#col# ) . run macr_cell_size (16, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[24] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ( "% наценки"       , num#str# , num#col# ) . run macr_cell_size (13, ? , num#str# , num#col# , num#str# , num#col# ). end.

    mp = num#col#  + 1.
    mp-1 = num#col#  .
 if use-column[6]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Остаток на начало "               , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[7]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот приход внешний"            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[8]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот приход перемещение"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[9]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот приход производство"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[10] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот расход внешний"            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[11] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот расход перемещение"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[12] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот расход производство"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[13] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот  списание"                 , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[14] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот касса продажа "            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[15] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот касса возврат"             , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[16] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот возврат внешний"           , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[17] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот возврат поставщику"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[18] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот возврат перемещение"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[19] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот  инвентаризация"           , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[20] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Оборот  переоценка"               , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[22] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char ("Остаток на конец "                , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[25] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format ({&TDEDT_Corr_Acc_Price-full}       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[26] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format ({&TDEDT_Chg_Purch_Code-full}       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[27] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format ("Расход-Возврат"                   , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
    run macr_cell_size (16, ? , num#str# , mp, num#str# , (num#col#  + (kk * (num#col#  - mp)) + kk) ).

   num#str# = num#str# + 1.
   repeat l#1 = mp to nk :
         l#2 = 0.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "количество"  , num#str# , num#col#  ) .
         if xshowcost    then do:
             l#2 = l#2 + 1.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "учетн. сумма"  , num#str# , num#col#  ) .
             end.
         if xshowcostnds then do:
             l#2 = l#2 + 1.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "учетн.НДС"  , num#str# , num#col#  ) .
            end.

         if xshowmediator then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "цены поср."  , num#str# , num#col#  ) .
            end.

         if xshowcrsa    then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "продаж. сумма"  , num#str# , num#col#  ) .
            end.
         if xshowcrsands then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "продаж.НДС"  , num#str# , num#col#  ) .
            end.
          if xshowsale    then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "док. сумма"  , num#str# , num#col#  ) .
            end.
         if xshowsalends then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "док.НДС"  , num#str# , num#col#  ) .
            end.

         if xshowsaleslt then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char ( "док.НсП"  , num#str# , num#col#  ) .
            end.

     end.
end procedure .


procedure make-tt-ed :
/* 0 */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 1 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 2 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 3 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 4 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 5 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 6 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 7 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Inv               } temp#sum-type.xi = 8 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 9 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 10. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 11. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 12. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 12. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 13. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Overturn          } temp#sum-type.xi = 14.
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Corr_Acc_Price         } temp#sum-type.xi = 15 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Chg_Purch_Code   } temp#sum-type.xi = 16 .

/* 100  crsa */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 101 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 102 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 103 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 104 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 105 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 106 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 107 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Inv               } temp#sum-type.xi = 108 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 109 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 110. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 111. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 112. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 112. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 113. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Overturn          } temp#sum-type.xi = 114.

create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Corr_Acc_Price         } temp#sum-type.xi = 115 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Chg_Purch_Code   } temp#sum-type.xi = 116 .

/* 200 sale */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 201 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 202 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 203 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 204 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 205 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 206 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 207 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Inv               } temp#sum-type.xi = 208 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 209 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 210. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 211. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 213. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Overturn          } temp#sum-type.xi = 214.
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Corr_Acc_Price         } temp#sum-type.xi = 215 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Chg_Purch_Code   } temp#sum-type.xi = 216 .

end procedure.


procedure calc-s-itog :


define variable n-1 as integer no-undo .

    do n-1 = 1 to {&e-col} :
    assign
      bi-oborot-{&bef-tdedt_pri_vnesh }        [n-1]  =bi-oborot-{&bef-tdedt_pri_vnesh }        [n-1]  + b1-oborot-{&bef-tdedt_pri_vnesh }        [n-1]
      bi-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]  =bi-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]
      bi-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]  =bi-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]
      bi-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]  =bi-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]
      bi-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]  =bi-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]  + b1-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]
      bi-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1] = bi-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1]  + b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1]
      bi-oborot-{&bef-tdedt_spi_vnesh         }[n-1]  =bi-oborot-{&bef-tdedt_spi_vnesh         }[n-1]  + b1-oborot-{&bef-tdedt_spi_vnesh         }[n-1]
      bi-oborot-{&bef-tdedt_inv              } [n-1]  =bi-oborot-{&bef-tdedt_inv              } [n-1]  + b1-oborot-{&bef-tdedt_inv              } [n-1]
      bi-oborot-{&bef-tdedt_pri_perem       }  [n-1]  =bi-oborot-{&bef-tdedt_pri_perem       }  [n-1]  + b1-oborot-{&bef-tdedt_pri_perem       }  [n-1]
      bi-oborot-{&bef-tdedt_ras_perem       }  [n-1]  =bi-oborot-{&bef-tdedt_ras_perem       }  [n-1]  + b1-oborot-{&bef-tdedt_ras_perem       }  [n-1]
      bi-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]  =bi-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]  + b1-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]
      bi-oborot-{&bef-tdedt_ras_prvo        }  [n-1]  =bi-oborot-{&bef-tdedt_ras_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_ras_prvo        }  [n-1]
      bi-oborot-{&bef-tdedt_spi_prvo        }  [n-1]  =bi-oborot-{&bef-tdedt_spi_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_spi_prvo        }  [n-1]
      bi-oborot-{&bef-tdedt_pri_prvo        }  [n-1]  =bi-oborot-{&bef-tdedt_pri_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_pri_prvo        }  [n-1]
      bi-oborot-{&bef-tdedt_overturn        }  [n-1]  =bi-oborot-{&bef-tdedt_overturn        }  [n-1]  + b1-oborot-{&bef-tdedt_overturn        }  [n-1]
      bi-oborot-{&bef-tdedt_Chg_Purch_Code  }  [n-1]  =bi-oborot-{&bef-tdedt_Chg_Purch_Code  }  [n-1]  + b1-oborot-{&bef-tdedt_Chg_Purch_Code   } [n-1]
      bi-oborot-{&bef-tdedt_Corr_Acc_Price  }  [n-1]  =bi-oborot-{&bef-tdedt_Corr_Acc_Price  }  [n-1]  + b1-oborot-{&bef-tdedt_Corr_Acc_Price   } [n-1]

      bi-oborot-disc                           [n-1]  =bi-oborot-disc                           [n-1]  + b1-oborot-disc                           [n-1]
      bi-oborot-sum-sale                       [n-1]  =bi-oborot-sum-sale                       [n-1]  + b1-oborot-sum-sale                       [n-1]
      bi-oborot-sum-cost                       [n-1]  =bi-oborot-sum-cost                       [n-1]  + b1-oborot-sum-cost                       [n-1]
      bi-ostatok-start                         [n-1]  =bi-ostatok-start                     [n-1]  + b1-ostatok-start                         [n-1]
      bi-ostatok-end                           [n-1]  =bi-ostatok-end                       [n-1]  + b1-ostatok-end                           [n-1]


      bo-oborot-{&bef-tdedt_pri_vnesh }        [n-1]  =bo-oborot-{&bef-tdedt_pri_vnesh }        [n-1]  + b1-oborot-{&bef-tdedt_pri_vnesh }        [n-1]
      bo-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]  =bo-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh  }       [n-1]
      bo-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]  =bo-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh_vp }     [n-1]
      bo-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]  =bo-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]  + b1-oborot-{&bef-tdedt_ras_vnesh_kass}    [n-1]
      bo-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]  =bo-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]  + b1-oborot-{&bef-tdedt_vozvrat_vnesh }    [n-1]
      bo-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1] = bo-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1]  + b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[n-1]
      bo-oborot-{&bef-tdedt_spi_vnesh         }[n-1]  =bo-oborot-{&bef-tdedt_spi_vnesh         }[n-1]  + b1-oborot-{&bef-tdedt_spi_vnesh         }[n-1]
      bo-oborot-{&bef-tdedt_inv              } [n-1]  =bo-oborot-{&bef-tdedt_inv              } [n-1]  + b1-oborot-{&bef-tdedt_inv              } [n-1]
      bo-oborot-{&bef-tdedt_pri_perem       }  [n-1]  =bo-oborot-{&bef-tdedt_pri_perem       }  [n-1]  + b1-oborot-{&bef-tdedt_pri_perem       }  [n-1]
      bo-oborot-{&bef-tdedt_ras_perem       }  [n-1]  =bo-oborot-{&bef-tdedt_ras_perem       }  [n-1]  + b1-oborot-{&bef-tdedt_ras_perem       }  [n-1]
      bo-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]  =bo-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]  + b1-oborot-{&bef-tdedt_vozvrat_perem   }  [n-1]
      bo-oborot-{&bef-tdedt_ras_prvo        }  [n-1]  =bo-oborot-{&bef-tdedt_ras_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_ras_prvo        }  [n-1]
      bo-oborot-{&bef-tdedt_spi_prvo        }  [n-1]  =bo-oborot-{&bef-tdedt_spi_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_spi_prvo        }  [n-1]
      bo-oborot-{&bef-tdedt_pri_prvo        }  [n-1]  =bo-oborot-{&bef-tdedt_pri_prvo        }  [n-1]  + b1-oborot-{&bef-tdedt_pri_prvo        }  [n-1]
      bo-oborot-{&bef-tdedt_overturn        }  [n-1]  =bo-oborot-{&bef-tdedt_overturn        }  [n-1]  + b1-oborot-{&bef-tdedt_overturn        }  [n-1]
      bo-oborot-{&bef-tdedt_Chg_Purch_Code  }  [n-1]  =bo-oborot-{&bef-tdedt_Chg_Purch_Code  }  [n-1]  + b1-oborot-{&bef-tdedt_Chg_Purch_Code   } [n-1]
      bo-oborot-{&bef-tdedt_Corr_Acc_Price  }  [n-1]  =bo-oborot-{&bef-tdedt_Corr_Acc_Price  }  [n-1]  + b1-oborot-{&bef-tdedt_Corr_Acc_Price   } [n-1]

      bo-oborot-disc                           [n-1]  =bo-oborot-disc                           [n-1]  + b1-oborot-disc                           [n-1]
      bo-oborot-sum-sale                       [n-1]  =bo-oborot-sum-sale                       [n-1]  + b1-oborot-sum-sale                       [n-1]
      bo-oborot-sum-cost                       [n-1]  =bo-oborot-sum-cost                       [n-1]  + b1-oborot-sum-cost                       [n-1]
      bo-ostatok-start                         [n-1]  =bo-ostatok-start                     [n-1]  + b1-ostatok-start                         [n-1]
      bo-ostatok-end                           [n-1]  =bo-ostatok-end                       [n-1]  + b1-ostatok-end                           [n-1]

    .
    end.
end procedure. /* calc-itog */

{ rep/procobor.i pp tree  }
{ rep/procobor.i pp tree grp }
{ rep/procobor.i find-last-prise-med }
{ rep/procobor.i find-mediator }
{ rep/procobor.i ob-line-stk }
{ rep/r-libmcr.i macr_excel         }

procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >=  63000  then do:

        output stream macr_excel  close .
        /*Запишем в файл параметров */
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
        output stream  macr_excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
         /* снова шапку */
/*Печать шапки */
define variable old-s as integer no-undo .
define variable old-s2 as integer no-undo .
    assign
      old-s =   num#str#
    .

    run make-col.
    assign
       old-s2 =   num#str#
    .

   num#str# = old-s + 1 .
   run proc-print-header.
   num#str# = old-s2 .

    end.

 end. /* do */
end procedure. /* new-tmp-page */

/* $Workfile$ e n d */