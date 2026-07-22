/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет оборота по строке в отчете по всем типам документов

Автор: Чернова Светлана Александровна
Дата создания: 10/18/01
Author: Svetlana Chernova
Creation date: 10/18/01

факт количество         1
смма в учет ценах       2
НДС  в учетных ценах    3

цены посредника         4
смма в прод ценах       5
НДС  в прод ценах       6

Скидка в ценах док      7
смма в док ценах        8
НДС  в док ценах        9

НсП в ценах док         10
ВЕС                     11
Объем                   12


Creation date: 10/18/01 12:44

*/
&scop run-ob-line-stk run ob-line-stk (~
 input   x-store-code    ~
,input   x-store-type    ~
,input   x-artic         ~
,input   x-prod-code     ~
,input   x-prod-type     ~
,input   x-fact-order-1  ~
,input   x-fact-order-2  ~
,input   x-sum-type      ~
,input   x-cat-id        ~
,input   x-ext-doc-type  ~
,input   xtog-obj        ~
,input   xi              ~
,output  oborot-~{&n-p} [1 + tt#] ~
,output  oborot-~{&n-p} [2 + tt#] ~
,output  oborot-~{&n-p} [3 + tt#] ~
,output  slt      ~
,output  disc ).  ~
  if tt# = 6 then ~
  assign          ~
    oborot-{&bef-disc}[1] = oborot-{&bef-disc}[1] + disc ~
    oborot-~{&n-p}[10]    = oborot-~{&n-p}[10]    + slt  .
/*-----------------------------------------------------------------------------------------------------------------------*/
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define input  parameter x-artic          like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj           as log no-undo.

define variable  quantity#    like ub.ot-line.fact-qnty   no-undo.
define variable  coast_r#     like ub.ot-line.sum-rubl    no-undo.
define variable  coast_v#     like ub.ot-line.sum-rubl    no-undo.
define variable  vat_r#       like ub.ot-line.sum-rubl    no-undo.
define variable  vat_v#       like ub.ot-line.sum-rubl    no-undo.
define variable  slt_r#       like ub.ot-line.sum-rubl    no-undo.
define variable  slt_v#       like ub.ot-line.sum-rubl    no-undo.
define variable  v-summa  as decimal extent 4 no-undo .
define variable  tt#          as int no-undo.
define variable v-ii as integer no-undo .
define variable slt  as decimal no-undo .
define variable disc  as decimal no-undo .
define variable xi as integer no-undo .
define variable v-tt as integer no-undo .

 if (x-sum-type = {&arh-cost}  or x-sum-type = {&arh-cost-service}) then assign tt# = 0 v-tt = 0.
    else
    if (x-sum-type = {&arh-crsa}  or x-sum-type = {&arh-crsa-service}) then assign tt# = 3  v-tt = 100.
    else
    assign tt# = 6  v-tt = 200.

  if long-p = false then do :
  for each obj-list no-lock:
   if  xtog-obj then
       if   not(x-store-type     = obj-list.obj-type
            and x-store-code    = obj-list.obj-code ) then next.
        for each ub.ot-line where
                  ub.ot-line.artic         = x-artic
            and   ub.ot-line.prod-code    = x-prod-code
            and   ub.ot-line.prod-type    = x-prod-type
            and   ub.ot-line.fact-order   <= x-fact-order-2
            and   ub.ot-line.fact-order   >= x-fact-order-1
            and   ub.ot-line.obj-code     = obj-list.obj-code
            and   ub.ot-line.obj-type     = obj-list.obj-type
            and   ub.ot-line.sum-type     = x-sum-type
            no-lock :
            case ub.ot-line.ext-doc-type:
              { rep/ob-case.i  tdedt_pri_vnesh           0 }
              { rep/ob-case.i  tdedt_ras_vnesh           0 }
              { rep/ob-case.i  tdedt_ras_vnesh_vp        0 }
              { rep/ob-case.i  tdedt_ras_vnesh_kass      0 }
              { rep/ob-case.i  tdedt_vozvrat_vnesh       0 }
              { rep/ob-case.i  tdedt_vozvrat_vnesh_kass  0 }
              { rep/ob-case.i  tdedt_spi_vnesh           0 }
              { rep/ob-case.i  tdedt_inv                 0 }
              { rep/ob-case.i  tdedt_pri_perem           0 }
              { rep/ob-case.i  tdedt_ras_perem           0 }
              { rep/ob-case.i  tdedt_vozvrat_perem       0 }
              { rep/ob-case.i  tdedt_ras_prvo            0 }
              { rep/ob-case.i  tdedt_pri_prvo            0 }
              { rep/ob-case.i  tdedt_overturn            0 }
              { rep/ob-case.i  tdedt_corr_acc_price      0 }
              { rep/ob-case.i  tdedt_chg_purch_code      0 }
            end case.
        end.
   end.
end.
/*-------------------------------------------------*/
else do: /* большой период времени */
&scop  n-p {&bef-tdedt_pri_vnesh}
xi = 1 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_ras_vnesh}
xi = 2 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_ras_vnesh_vp}
xi = 3 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_ras_vnesh_kass}
xi = 4 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_vozvrat_vnesh}
xi = 5 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_vozvrat_vnesh_kass}
xi = 6 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_spi_vnesh}
xi = 7 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_inv}
xi = 8 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_pri_perem}
xi = 9 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_ras_perem}
xi = 10 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_vozvrat_perem}
xi = 11 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_ras_prvo}
xi = 12 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_pri_prvo}
xi = 13 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_overturn}
xi = 14 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_corr_acc_price}
xi = 15 + v-tt. {&run-ob-line-stk}
&scop  n-p {&bef-tdedt_chg_purch_code}
xi = 16 + v-tt. {&run-ob-line-stk}



end.
/*-----------------------------------------------------------------------------------------------------------------------*/
  if tt# = 6 then do:
  if  xshowmediator = false then
      oborot-sum-cost[1] =
      oborot-{&bef-tdedt_ras_vnesh}[2]      +
      oborot-{&bef-tdedt_ras_vnesh_kass}[2] +
      oborot-{&bef-tdedt_vozvrat_vnesh}[2]  +
      oborot-{&bef-tdedt_vozvrat_vnesh_kass}[2]
      .
      else
      oborot-sum-cost[1] =
      oborot-{&bef-tdedt_ras_vnesh}[4]      +
      oborot-{&bef-tdedt_ras_vnesh_kass}[4] +
      oborot-{&bef-tdedt_vozvrat_vnesh}[4]  +
      oborot-{&bef-tdedt_vozvrat_vnesh_kass}[4]
      .
     repeat v-ii = 1 to 1 :
     v-summa[v-ii ]  =
        oborot-{&bef-tdedt_pri_vnesh}[v-ii ] + oborot-{&bef-tdedt_ras_vnesh}[v-ii ] + oborot-{&bef-tdedt_ras_vnesh_vp}[v-ii ] +
        oborot-{&bef-tdedt_ras_vnesh_kass}[v-ii ] + oborot-{&bef-tdedt_vozvrat_vnesh}[v-ii ] + oborot-{&bef-tdedt_vozvrat_vnesh_kass}[v-ii ] +
        oborot-{&bef-tdedt_spi_vnesh}[v-ii ] + oborot-{&bef-tdedt_inv}[v-ii ] + oborot-{&bef-tdedt_pri_perem}[v-ii ] +
        oborot-{&bef-tdedt_ras_perem}[v-ii ] + oborot-{&bef-tdedt_vozvrat_perem}[v-ii ] + oborot-{&bef-tdedt_ras_prvo}[v-ii ] +
        oborot-{&bef-tdedt_pri_prvo}[v-ii ] .
     end.

     repeat v-ii = 2 to 4 :
     v-summa[v-ii ]  =
        oborot-{&bef-tdedt_pri_vnesh}[v-ii + tt#] + oborot-{&bef-tdedt_ras_vnesh}[v-ii + tt#] + oborot-{&bef-tdedt_ras_vnesh_vp}[v-ii + tt#] +
        oborot-{&bef-tdedt_ras_vnesh_kass}[v-ii + tt#] + oborot-{&bef-tdedt_vozvrat_vnesh}[v-ii + tt#] + oborot-{&bef-tdedt_vozvrat_vnesh_kass}[v-ii + tt#] +
        oborot-{&bef-tdedt_spi_vnesh}[v-ii + tt#] + oborot-{&bef-tdedt_inv}[v-ii + tt#] + oborot-{&bef-tdedt_pri_perem}[v-ii + tt#] +
        oborot-{&bef-tdedt_ras_perem}[v-ii + tt#] + oborot-{&bef-tdedt_vozvrat_perem}[v-ii + tt#] + oborot-{&bef-tdedt_ras_prvo}[v-ii + tt#] +
        oborot-{&bef-tdedt_pri_prvo}[v-ii + tt#] .
     end.

      oborot-sum-sale[1] =
      oborot-{&bef-tdedt_ras_vnesh}[2 + tt#] +
      oborot-{&bef-tdedt_ras_vnesh_kass}[2 + tt#] +
      oborot-{&bef-tdedt_vozvrat_vnesh}[2 + tt#] +
      oborot-{&bef-tdedt_vozvrat_vnesh_kass}[2 + tt#]
      .

       assign oborot-{&bef-tdedt_overturn}[1 + tt#] = (ostatok-end[1 + tt#]  - ostatok-start[1 + tt#])  -  (v-summa[1]) /* кол-во*/
        oborot-{&bef-tdedt_overturn}[2 + tt#] = (ostatok-end[2 + tt#]  - ostatok-start[2 + tt#])  -  (v-summa[2])
                                                                                                  -  oborot-{&bef-disc}[1] /* сумма */
        oborot-{&bef-tdedt_overturn}[3 + tt#] = (ostatok-end[3 + tt#]  - ostatok-start[3 + tt#])  -  (v-summa[3]) /* ндс   */
        oborot-{&bef-tdedt_overturn}[10] = (ostatok-end[10]  - ostatok-start[10])                 -  (v-summa[4]) /* нсп   */
        .


        oborot-{&bef-eff}[1] = -1 * (oborot-sum-sale[1] - oborot-sum-cost[1]) .

        if oborot-sum-cost[1] <>  0 then
          oborot-{&bef-prc}[1] = 100 * (oborot-sum-sale[1] - oborot-sum-cost[1] ) / oborot-sum-cost[1].
          else oborot-{&bef-prc}[1] = 0.
  end. /* = 6 */
{ rep/procobor.i case-tdedt  tdedt_pri_vnesh         }
{ rep/procobor.i case-tdedt  tdedt_ras_vnesh         }
{ rep/procobor.i case-tdedt  tdedt_ras_vnesh_vp      }
{ rep/procobor.i case-tdedt  tdedt_ras_vnesh_kass    }
{ rep/procobor.i case-tdedt  tdedt_vozvrat_vnesh     }
{ rep/procobor.i case-tdedt  tdedt_vozvrat_vnesh_kass}
{ rep/procobor.i case-tdedt  tdedt_spi_vnesh         }
{ rep/procobor.i case-tdedt  tdedt_inv               }
{ rep/procobor.i case-tdedt  tdedt_pri_perem         }
{ rep/procobor.i case-tdedt  tdedt_ras_perem         }
{ rep/procobor.i case-tdedt  tdedt_vozvrat_perem     }
{ rep/procobor.i case-tdedt  tdedt_ras_prvo          }
{ rep/procobor.i case-tdedt  tdedt_pri_prvo          }
{ rep/procobor.i case-tdedt  tdedt_overturn          }
{ rep/procobor.i case-tdedt  tdedt_corr_acc_price    }
{ rep/procobor.i case-tdedt  tdedt_chg_purch_code    }


/* $Workfile$ e n d */