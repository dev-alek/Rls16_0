/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов печати ценников (этикеток). Печать одного ценника (этикетки).

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/

run rep/ticket.p (
               buffer ub.goods
              ,buffer ub.bar-code
              ,buffer ub.scales-gds
              ,input p-obj-type
              ,input p-obj-code
              ,input Action
              ,input rootnode_code
              ,input TickOnw
              ,input TickOnN
              ,input QntyType
              ,input PriceType
              ,input scaleprice
              ,input nakl-qnty
              ,input list-qnty
              ,input pr-doc-rubl
              ,input pr-doc-rb
              ,input pr-doc-rubl-old
              ,input pr-doc-rb-old
              ,input v-fact-order
              ,input ListProdBc
              ,input curr-rate
              ,input TickPS
              ,input dflt-cd
              ,input how-pcnt-kat
              ,input-output b-count
              ,input v-part-code
              ,input v-doc-code
              ,input v-promo-code
              ,input v-ActionId
              ,input v-db-num
              ) no-error .


/* $Workfile$ e n d */