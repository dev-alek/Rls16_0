/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
определение временной таблицы для отчета итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table sj-cards  no-undo
field d-card        like dis-card.d-card
field cli-type      like clients.obj-type
field cli-code      like clients.obj-code
field cli-name      like clients.obj-name
field global-card   as logical
field credit-card   like dis-card.credit-card
field g-code        like cli-grp.node-code
field d-pcnt        like dis-card.d-pcnt
field d-pcntchr     as character
field must-pay      as decimal
field saldo         as decimal
field pay           as decimal
field tot           as decimal
field disc          as decimal
field netto         as decimal
field instant-pay   as decimal
field credit-pay    as decimal
field num-chk       as integer
field obj-qnty      as integer
field card-num-chr  as character
field is-sum        as logical
field last-card     like ub.dis-card.d-card
field main-card     like ub.dis-card.main-card
field first-card    like ub.dis-card.first-card
field first-main-card  like ub.dis-card.first-main-card
INDEX pi            IS PRIMARY UNIQUE
d-card is-sum
INDEX ipay
pay
INDEX grp-code
d-card
g-code
index pi2
last-card
index p3 card-num-chr is-sum
.

def {1} temp-table sj-groups  no-undo
field g-code       like cli-grp.node-code
field g-name       like cli-grp.node-name
field obj-code      like dis-obj.obj-code
field tot             as decimal
field disc          as decimal
field netto         as decimal
field pay           as decimal
field credit-pay    as decimal
field instant-pay    as decimal
field num-chk    as integer
field cards-qnty as integer
field must-pay   as decimal
field saldo      as decimal
field obj-qnty   as integer
INDEX igroup  is primary
      g-code
      obj-code
.

DEFINE {1} TEMP-TABLE legacy NO-UNDO
field root-card     like dis-card.d-card
field d-card        like dis-card.d-card
field card-num      like dis-card.card-num
field sourced-card  like dis-card.sourced-card
field last-card     like ub.dis-card.d-card
field d-pcntchr as character
field d-pcnt like dis-card.d-pcnt
field leg-num       as integer /*номер карты в цепочек перевыпуска*/
index pi is primary
card-num
leg-num   descending
index p1 d-card
index p2
card-num
sourced-card.


DEFINE {1} TEMP-TABLE legacy-obj NO-UNDO
field d-card        like ub.dis-card.d-card
field first-card    like ub.dis-card.first-card
field main-card    like ub.dis-card.first-card
field first-main-card    like ub.dis-card.first-main-card
field card-num-chr  as character
field obj-type      like ub.dis-obj.obj-type
field obj-code      like ub.dis-obj.obj-code
field gds-tot-rubl as decimal
field pay-tot-rubl as decimal
field gds-dis-rubl as decimal
field gds-tot-base as decimal
field pay-tot-base as decimal
field gds-dis-base as decimal
field d-pcnt as decimal
field d-pcntchr as character
field num-chk    as integer
index pi is primary unique
obj-type
obj-code
card-num-chr
index pi2
obj-type
obj-code
d-card
index pi3
d-card
obj-type
obj-code
.

/* должна быть и запись sj-groups с obj-code = 0 - вместо accum*/

def {1} var dis-obj-found as logical no-undo init NO.



/* $Workfile$ e n d */