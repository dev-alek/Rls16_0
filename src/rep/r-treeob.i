/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет  дерево


Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

created: 19/01/01

*/

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Оборотная ведомость - дерево".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ rep/rep-bt.i    }
{ cmp/r-pril.i    }
{ rep/r-sym.i     }
{ rep/r-gl.i tree }
{ rep/procobor.i func-vat }

&scop e-col 10

/* дерево все равно строится по всем группам так что здесь v-show-all-goods не нужен */
&scop loc-last-doc ~
and (  b_gds-obj.last-doc = ? ~
or b_gds-obj.last-doc >= x-date-start ~
or b_gds-obj.fact-qnty <> 0 ~
or b_gds-obj.avrg-qnty <> 0 ~
or b_gds-obj.fact-sale <> 0 ~
or b_gds-obj.fact-base <> 0 )

/* parameters definitions ---                                           */
define work-table temp#sum-type no-undo
    field sum-type as char
    field xi as int.

define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xclassify  as char no-undo.
define input parameter xsorttype  as char no-undo.
define input parameter xsumsonly  as log  no-undo.
define input parameter xshowzero  as log  no-undo.
define input parameter xshowzero-2  as log  no-undo.
define input parameter xtog-obj   as log no-undo.
define input parameter xshowcost  as log no-undo.
define input parameter xshowcostnds  as log no-undo.
define input parameter xshowcrsa     as log no-undo.
define input parameter xshowcrsands  as log no-undo.
define input parameter xshowsale     as log no-undo.
define input parameter xshowsalends  as log no-undo.
define input parameter xtog-lavel   as log  no-undo.
define input parameter xvar-lavel   as int  no-undo.
define input parameter xserv        as char no-undo.
define input parameter print-o      as char no-undo.
define input parameter xshowmediator as log no-undo.
define input parameter xshowsaleslt  as log no-undo.
define input parameter x-vat         as log no-undo.
define input  parameter xlongname as logical   no-undo .
define input  parameter x-tog-wt  as logical   no-undo .
define input  parameter x-tog-ms  as logical   no-undo .
define input parameter p-is-petrol    as logical   no-undo .

define variable v-name-type as character no-undo .
if x-vat then x-vat = false .
         else x-vat = true .

if x-vat then v-name-type = "учет.".
else  v-name-type = "учет-НДС".


&scop l-frame 340
&scop l-frame-1 319

define  variable  long-p as logical no-undo .
define  variable  null-str#   as decimal  no-undo.
define  variable  null-str2#   as decimal  no-undo.
define  variable  tprintrubl as log no-undo.

define  stream  outstream.
define variable    objname           as   char no-undo.
define variable    select-good       as   integer no-undo.
define variable    chosedtype        as   integer no-undo.
define variable    paytype           as   integer no-undo.
define variable    retclassify       as   char  no-undo.
define variable    retsorttype       as   char  no-undo.
define variable    show-negativ      as   logical  no-undo.
define variable    show-negativ-2    as   logical  no-undo.
define variable    sums-only         as   logical  no-undo.
define variable    valtype           as   integer no-undo.
define variable    line              as   char        no-undo.
define variable    line2             as   char        no-undo.
define variable    firstline         as   logical     no-undo.

define variable mediator-host-code as integer no-undo .
define variable f-flag             as logical no-undo .

define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

define variable stat      as log        no-undo .
define variable inperror  as log        no-undo .
define variable i         as integer    no-undo .
define variable p         as integer    no-undo init 0 .
define variable kk        as integer    no-undo init 0 .
define variable old-page  as integer    no-undo .
define variable new-page  as integer    no-undo .
define variable rid-list  as character  no-undo .


define variable t-time as integer no-undo .

define variable m                       as integer no-undo.
define variable l                       as integer no-undo.
define variable i-str                   as integer no-undo.
define variable allcol                  as int no-undo.
define variable num#str                 as int no-undo.


define  stream  outstream.
define  stream  outstream2.

define variable nk as integer no-undo .
define variable lp as int no-undo.
define variable mp as int no-undo.
define variable mp-1 as int no-undo.


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


define variable c-s-bar-code        AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-artic     AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-gds-name  AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-unit-base AS   WIDGET-HANDLE  no-undo.
define variable c-gds-type          AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-start    AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-End      AS   WIDGET-HANDLE  no-undo.
define variable c-str-num          AS   WIDGET-HANDLE  no-undo.


{ rep/repfrm.i def}


 &glob bef-disc disc
 &glob bef-eff  eff
 &glob bef-prc  prc
 &glob bef-r-v  r-v

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
{ rep/def-ob.i tdedt_chg_purch_code }
{ rep/def-ob.i tdedt_corr_acc_price }
{ rep/def-ob.i disc }
{ rep/def-ob.i eff  }
{ rep/def-ob.i prc  }
{ rep/def-ob.i r-v  }

{ rep/def-ob.i sum-cost }
{ rep/def-ob.i sum-crsa }
{ rep/def-ob.i sum-sale }
{ rep/procobor.i def-tt }

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
  field {&bef-tdedt_spi_vnesh       }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
  field {&bef-tdedt_inv             }     as decimal extent {&e-col} format "->>>>>>>>>>>9.<<<"
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
define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .
/*
define variable sf1 as handle .
define variable sf2 as handle .
create editor sf1 .
create editor sf2 .
*/
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
  allcol = num-entries( sizes) - 1 .
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

define new shared variable t-1 as character initial "|||"
     view-as editor
     size 1 by 4 no-undo.


define new shared frame top-frame
    t-1       at row 1 col 1 no-label
    header
        string(  "Дата печати : " + string( today,"99.99.9999") +  " , " + string( time, "hh:mm") ) at 5 format "x(35)"
        "Цены указаны в" ( if tprintrubl then "{&abbr_rub_allshift}" else x-base-type )
        string(  "Страница " + string(  page-number(  outstream ), ">>>>>>9") ) at 110 format "x(16)" skip
     with {&l-frame} down stream-io
         no-underline use-text no-box no-label
         at col 1 row 1
         size {&l-frame} by 35  .


define new shared  frame zapas
   with width {&l-frame} down stream-io use-text no-box no-label.

t-time = time.
 { rep/r-ob1cr.i def 1     s-bar-code                 "new shared" }
 { rep/r-ob1cr.i def  2    gds-zap-artic              "new shared"  }
 { rep/r-ob1cr.i def  3    gds-zap-gds-name           "new shared"  }
 { rep/r-ob1cr.i def  4    gds-zap-unit-base          "new shared"  }
 { rep/r-ob1cr.i def  5    gds-type                   "new shared"  }
{ rep/r-ob1cr.i def  6    ostatok-start                "new shared" }
{ rep/r-ob1cr.i def  7    oborot-{&bef-TDEDT_Pri_Vnesh} "new shared" }
{ rep/r-ob1cr.i def  8    oborot-{&bef-TDEDT_Pri_Perem} "new shared" }
{ rep/r-ob1cr.i def  9    oborot-{&bef-TDEDT_Pri_Prvo}  "new shared" }
{ rep/r-ob1cr.i def  10   oborot-{&bef-TDEDT_Ras_Vnesh} "new shared" }
{ rep/r-ob1cr.i def  11   oborot-{&bef-TDEDT_Ras_Perem} "new shared" }
{ rep/r-ob1cr.i def  12   oborot-{&bef-TDEDT_Ras_Prvo}  "new shared" }
{ rep/r-ob1cr.i def  13   oborot-{&bef-TDEDT_Spi_Vnesh} "new shared" }
{ rep/r-ob1cr.i def  14   oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    "new shared" }
{ rep/r-ob1cr.i def  15   oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass} "new shared" }
{ rep/r-ob1cr.i def  16   oborot-{&bef-TDEDT_Vozvrat_Vnesh}     "new shared" }
{ rep/r-ob1cr.i def  17   oborot-{&bef-TDEDT_RAS_Vnesh_VP}      "new shared" }
{ rep/r-ob1cr.i def  18   oborot-{&bef-TDEDT_Vozvrat_Perem}     "new shared" }
{ rep/r-ob1cr.i def  19   oborot-{&bef-TDEDT_Inv}               "new shared" }
{ rep/r-ob1cr.i def  20   oborot-{&bef-TDEDT_Overturn}          "new shared" }
{ rep/r-ob1cr.i def  21   oborot-{&bef-disc}                    "new shared" }
{ rep/r-ob1cr.i def  22   ostatok-end                           "new shared" }
{ rep/r-ob1cr.i def  23   oborot-{&bef-eff}                     "new shared" }
{ rep/r-ob1cr.i def  24   oborot-{&bef-prc}                     "new shared" }
{ rep/r-ob1cr.i def  25   oborot-{&bef-TDEDT_Corr_Acc_Price}    "new shared" }
{ rep/r-ob1cr.i def  26   oborot-{&bef-TDEDT_Chg_Purch_Code}    "new shared" }
{ rep/r-ob1cr.i def  27   oborot-{&bef-r-v}                     "new shared" }
{ rep/r-ob1cr.i def  28   str-num                               "new shared" }

run rep/r-in-ob.p (
   input          x-base-type
 , input          x-base-code
 , input          tprintrubl
 , input-output   c-s-bar-code
 , input-output   c-gds-zap-artic
 , input-output   c-gds-zap-gds-name
 , input-output   c-gds-zap-unit-base
 , input-output   c-gds-type
 , input-output   c-ostatok-start
 , input-output   c-ostatok-end
 , input-output   c-oborot-{&bef-tdedt_pri_vnesh            }
 , input-output   c-oborot-{&bef-tdedt_ras_vnesh            }
 , input-output   c-oborot-{&bef-tdedt_ras_vnesh_vp         }
 , input-output   c-oborot-{&bef-tdedt_ras_vnesh_kass       }
 , input-output   c-oborot-{&bef-tdedt_vozvrat_vnesh        }
 , input-output   c-oborot-{&bef-tdedt_vozvrat_vnesh_kass   }
 , input-output   c-oborot-{&bef-tdedt_spi_vnesh            }
 , input-output   c-oborot-{&bef-tdedt_inv                  }
 , input-output   c-oborot-{&bef-tdedt_pri_perem            }
 , input-output   c-oborot-{&bef-tdedt_ras_perem            }
 , input-output   c-oborot-{&bef-tdedt_vozvrat_perem        }
 , input-output   c-oborot-{&bef-tdedt_ras_prvo             }
 , input-output   c-oborot-{&bef-tdedt_spi_prvo             }
 , input-output   c-oborot-{&bef-tdedt_pri_prvo             }
 , input-output   c-oborot-{&bef-tdedt_overturn             }
 , input-output   c-oborot-{&bef-tdedt_chg_purch_code       }
 , input-output   c-oborot-{&bef-tdedt_corr_acc_price       }
 , input-output   c-oborot-{&bef-disc                       }
 , input-output   c-oborot-{&bef-eff                        }
 , input-output   c-oborot-{&bef-prc                        }
 , input-output   c-oborot-{&bef-r-v                        }
 , input-output   c-str-num
 , input-output   l-col-type
 , input-output   l-col-pos
 , input-output   l-col-len
 , input-output   l-col-format
 , input-output   l-col-lable
  ).


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
        valtype        = if ( paytype = 1) then 0  else x-set_val_type.

    assign
      line  = fill( '-', minimum( l-col-pos,189))
      line2 = fill( '-', l-col-pos)
      .
  if  x-date-end  - x-date-start > 100
      then long-p = true    .
      else  long-p = false     .

  find first ub.gds-grp where  ub.gds-grp.upper-code = 0 no-lock no-error .
  if avail ub.gds-grp then  first-lavel = ub.gds-grp.node-code.
                   else first-lavel = 0.

  valtype         = if ( paytype = 1) then 0  else x-set_val_type.

  if ( valtype=0 and x-base-code=0)  or valtype=1
    then assign tprintrubl = yes .
    else assign tprintrubl = no .

  run make-tt-ed in this-procedure /* какие sum-type */ .
  run find-mediator  in this-procedure
     (  input  v-cntxt-host-code-obj ,
       input  xshowmediator,
       output mediator-host-code,
       output f-flag) .
  if f-flag = false then return.

  g-ll = xlavel .
  run pp in this-procedure ( 1,first-lavel,"").
  run report-execute in this-procedure .

/*----internal func & proc ----------------------------------------------------------------------------------------------*/
{ rep/f-flav.i   }
{ rep/ost-line.i }
{ rep/ostatok.i  }

procedure report-execute :
  if ( valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .

  case print-o :
  when "a4-lansc":u then do:
     { cmp/open-out.i stream outstream  " " {&ls_ps_a4}} end.
  when "a4-port":u then do:
     { cmp/open-out.i stream outstream  " " {&cp_ps}} end.
  when "a3-lansc":u then do:
     { cmp/open-out.i stream outstream  " " {&cp_ps}} end.
  otherwise do:
     { cmp/open-out.i stream outstream  " " {&ls_ps_a4}} end.
  end case.



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

  put stream outstream " Время составления отчета " string( ( time - t-time),"hh:mm:ss" ) .

  hide   stream outstream frame zapas .
  hide   stream outstream frame top-frame .
  output stream outstream close.
  { rep/repfrm.i off}

  delete widget-pool "my-pool".

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .

  case print-o :
      when "a4-lansc":u then do:
        DisabledOptions = 8 .
        end.
      when "a4-port":u then do:
        DisabledOptions = 0 .
        end.
      when "a3-lansc":u then do:
        DisabledOptions = 8 .
                          end.
      otherwise do:
        DisabledOptions = 1 .
          end.
   end case.


   run gbl/prnfilen.w
     ( input  ""
     ,input  DisabledOptions
     ,input  string( session :temp-directory) + {&DF_Name} + string(  g#report-num )
     ,input 7
     ,output v-user-action
     ,output v-printed
     ) .
end procedure.


procedure report-exec1 :
   find first ub.clients where x-store-type = ub.clients.obj-type and
                            x-store-code = ub.clients.obj-code no-lock no-error.

           if available ub.clients then  objname = ub.clients.obj-name.
                                         else  objname="объект не определен".
  form with frame zapas .
  { rep/r-formh.i x(197) {&l-frame}}
  run calcitog in this-procedure .
  run print-header in this-procedure .   /* проход по списку товаров 1 2 3-№ поиска */
  run run2 in this-procedure .
  run print-det in this-procedure .
  hide stream outstream frame bottomframe .
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
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .

define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     (  o-tog-obj = false or
        (  obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ) ) :
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                {&loc-last-doc}
                :

        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            {&acc-tree-term }
          end.
      end. /* gds-obj */
   end. /* obj-list */
assign
   xtog-obj     = o-tog-obj
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
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .

   for each obj-list  :
      if  o-tog-obj = true  then   do:
         if not
        (  obj-list.obj-type = x-store-type and obj-list.obj-code = x-store-code ) then next.

      end.
      x-store-type = obj-list.obj-type.
      x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                {&loc-last-doc}
                ,
                first gds-list where gds-list.gds-code = b_gds-obj.gds-code :
        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            {&acc-tree-term }
          end.
      end. /* gds-obj */
   end. /* obj-list */


assign
   xtog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code

.


end procedure.


procedure run22 : /* cоздается ТТ с терминальными значениями */
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .

define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     (  o-tog-obj = false or
        (  obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ))  :
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                {&loc-last-doc}
                ,
         first  tmp#grp  where trim( b_gds-obj.grp-name) begins trim( tmp#grp.grp-name)
                :

        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            {&acc-tree-term }
          end.
      end. /* gds-obj */
   end. /* obj-list */
assign
   xtog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code

.

end procedure.


procedure run23 : /* cоздается ТТ с терминальными значениями */
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .

define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     (  o-tog-obj = false or
        (  obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ))  :
  x-store-type = obj-list.obj-type.
  x-store-code = obj-list.obj-code.

      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                {&loc-last-doc}
                ,
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
   xtog-obj     = o-tog-obj
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
*/

{ rep/repfrm.i disp i-str "'Суммирование дерева'" }
   /* для печати */
    for each tmp-gds no-lock   :
        run clear-b1  in this-procedure .
        for each tmp-gds-tree no-lock
            where (  (  trim( tmp-gds-tree.f-name)  ) begins ( trim( tmp-gds.f-name) ) ) :
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

        b1-oborot-{&bef-eff}[1 ]  = ( b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) .

        if  b1-oborot-sum-cost[2] <>  0 then
            b1-oborot-{&bef-prc}[1] = 100 * ( b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) / b1-oborot-sum-cost[2] .
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
              b1-oborot-{&bef-tdedt_Chg_Purch_Code  }           [1]    = 0 and
              b1-oborot-{&bef-tdedt_Corr_Acc_Price  }           [1]    = 0 and
              b1-oborot-{&bef-disc }                            [1]    = 0 and
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
              b1-oborot-{&bef-tdedt_Chg_Purch_Code  }           [2]    = 0 and
              b1-oborot-{&bef-tdedt_Corr_Acc_Price  }           [2]    = 0 and
              b1-oborot-{&bef-disc }                            [2]    = 0 and
              b1-ostatok-end                                    [2]    = 0 and
              b1-ostatok-start                                  [2]    = 0 and

              b1-oborot-{&bef-tdedt_overturn }                  [2]    = 0
              )  then do:
                  assign
                    s-bar-code       = substring( tmp-gds.name,1,9)
                    sf1:screen-value = substring( tmp-gds.name,10,1)
                    gds-zap-artic    = substring( tmp-gds.name,11,16)
                    sf2:screen-value = substring( tmp-gds.name,27,1)
                    gds-zap-gds-name = substring( tmp-gds.name,28,40)
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


procedure print-header :
if not firstline then  run display-title  in this-procedure .
    firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
          {&put-u1}  "ПО ОБЪЕКТУ : " + caps( objname)  at 30 format "x(170)" skip.
          end.
          form {&wfz} .   {&frame-d} .

      run clear-b1  in this-procedure .
      run clear-bi  in this-procedure .
      break_group = true.
      break_group1 = true.
      display stream outstream     with frame top-frame .
      display stream outstream     with frame top-2 .

end procedure.


procedure print-footer :
    gds-zap-artic = "ИТОГО" .
    run display-bi  in this-procedure .
    run u-line      in this-procedure .

end procedure.

procedure calcitog :
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start - 1 ,
        input date( '')      , ?, ?,
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
  { rep/di-qnty.i "кол-во" 1  "''" gds-zap-artic     "''"  "''"  bi- 0 {3} }
if xshowcost    then do:  run price-vat in this-procedure ( 'bi').  end.
if xshowcostnds then do: { rep/di-qnty.i "НДС учет."  3 "''"  "''"  "''"  "''"  bi- 0 {3} } end.
if xshowcrsa    then do: { rep/di-qnty.i "прод."  5     "''"  "''"  "''"  "''"  bi- 0 {3} } end.
if xshowcrsands then do: { rep/di-qnty.i "НДС прод."  6 "''"  "''"  "''"  "''"  bi- 0 {3} } end.
if xshowsale    then do: { rep/di-qnty.i "док."  8      "''"  "''"  "''"  "''"  bi- 0 {3} } end.
if xshowsalends then do: { rep/di-qnty.i "НДС док."  9  "''"  "''"  "''"  "''"  bi- 0 {3} } end.
if xshowsaleslt then do: { rep/di-qnty.i "НсП док."  10  "''"  "''"  "''"  "''"  bi- 0 {3} } end.
if xshowmediator then do: { rep/di-qnty.i "поср."  4  "''"  "''"  "''"  "''"  bi- 0 {3} } end.
run clear-bi  in this-procedure .
end procedure.

procedure display-bo  :
  { rep/di-qnty.i "кол-во" 1  "''" "'ИТОГО ПО'"  "'ОБЪЕКТАМ'"  "''"  bo- 0 {3}}

if xshowcost    then do:  run price-vat in this-procedure ( 'bo').  end.
if xshowcostnds then do: { rep/di-qnty.i "НДС учет."  3 "''"  "''"  "''"  "''"  bo-  0 {3}} end.
if xshowcrsa    then do: { rep/di-qnty.i "прод."  5     "''"  "''"  "''"  "''"  bo-  0 {3}} end.
if xshowcrsands then do: { rep/di-qnty.i "НДС прод."  6 "''"  "''"  "''"  "''"  bo-  0 {3}} end.
if xshowsale    then do: { rep/di-qnty.i "док."  8      "''"  "''"  "''"  "''"  bo-  0 {3}} end.
if xshowsalends then do: { rep/di-qnty.i "НДС док."  9  "''"  "''"  "''"  "''"  bo-  0 {3}} end.
if xshowsaleslt then do: { rep/di-qnty.i "НсП док."  10  "''"  "''"  "''"  "''"  bo- 0 {3}} end.
if xshowmediator then do: { rep/di-qnty.i "поср."  4  "''"  "''"  "''"  "''"  bo-    0 {3}} end.
run clear-bo  in this-procedure .
end procedure.


procedure display-b1  :
  { rep/di-qnty.i "кол-во" 1  s-bar-code gds-zap-artic gds-zap-gds-name "''" b1- 0 {3}}
  assign
      sf1:screen-value = ""
      sf2:screen-value = ""
      no-error .
  if xshowcost    then do:  run price-vat in this-procedure ( 'b1').  end.
  if xshowcostnds then do: { rep/di-qnty.i "НДС учет."  3 "''" "''" "''" "''" b1- 0 {3}} end.
  if xshowcrsa    then do: { rep/di-qnty.i "прод."  5     "''" "''" "''" "''" b1- 0 {3}} end.
  if xshowcrsands then do: { rep/di-qnty.i "НДС прод."  6 "''" "''" "''" "''" b1- 0 {3}} end.
  if xshowsale    then do: { rep/di-qnty.i "док."  8      "''" "''" "''" "''" b1- 0 {3}} end.
  if xshowsalends then do: { rep/di-qnty.i "НДС док."  9  "''" "''" "''" "''" b1- 0 {3}} end.
  if xshowsaleslt then do: { rep/di-qnty.i "НсП док."  10  "''" "''" "''" "''" b1- 0 {3}} end.
  if xshowmediator then do: { rep/di-qnty.i "поср."  4  "''" "''" "''" "''" b1- 0 {3}} end.
end procedure.

procedure clear-b1  :
 { rep/o-clear.i b1}
end procedure.


procedure clear-bi  :
 { rep/o-clear.i bi}
end procedure.


procedure clear-bo  :
 { rep/o-clear.i bo}
end procedure.

procedure display-title :
   {&put-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + objname) at 50 format "x(85)" skip( 2)
          reportname  at 1 format "x(133)" skip
          trim( str1)  at 35 format "x(75)" skip.
     repeat i = 1 to num-entries( str2,chr( 10)) :
      {&put-u1}  entry( i,str2,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries( str3,chr( 10)) :
      {&put-u1}  entry( i,str3,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries( str4,chr( 10)) :
      {&put-u1}  entry( i,str4,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries( reportheader,chr( 10)) :
      {&put-u1}  entry( i,reportheader,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
 end procedure.


procedure ob-line  :
 { rep/ob-line.i }
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


procedure null-str-pr :
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
     oborot-{&bef-tdedt_overturn }                 [2] = 0  and
     oborot-{&bef-tdedt_Chg_Purch_Code  }           [1]    = 0 and
     oborot-{&bef-tdedt_Corr_Acc_Price  }           [1]    = 0 and
     ostatok-end[1]                                    = 0  and
     ostatok-start[1]                                  = 0 and
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


procedure u-line:
        {&put-u1}  line2 format "x({&l-frame-1})" skip.
end procedure.


procedure p-line:
end procedure.

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

{ rep/procobor.i pp tree }
{ rep/procobor.i find-last-prise-med }
{ rep/procobor.i find-mediator }
{ rep/procobor.i ob-line-stk }

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
PROCEDURE PRICE-VAT :
define input parameter PP as character no-undo .
if pp = '' THEN DO:
      { rep/di-qnty3.i v-name-type  2  " " " " " " " " " " {3} }  End.
run price-vat-1 ( pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-1 :
define input parameter PP as character no-undo .
if pp = 'Bi' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  Bi- {3} } End.
run PRICE-VAT-2 ( pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-2 :
define input parameter PP as character no-undo .
if pp = 'Bo' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  Bo- {3} } End.
run PRICE-VAT-3 ( pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-3 :
define input parameter PP as character no-undo .
if pp =  'B1' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  B1- {3} } End.
run PRICE-VAT-4 ( pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-4 :
define input parameter PP as character no-undo .
if pp =   'B2' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  B2- {3} } End.
    DISPLAY stream  OutStream  {&WFz} .  {&FRAME-d}.
END PROCEDURE.

/* $workfile: xloborot.i $ e n d */