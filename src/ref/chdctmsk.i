/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка корректности набора масок по разным фирмам и объектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/15/04
Author: Bakhtadze Natalya
Creation date: 12/15/04

*/

/*
не должно быть ситуации когдадля одной ДК нашлось сразу ДВЕ ИЛИ БОЛЕЕ МАСКИ,
для РАЗНЫХ объектов или фирм, которым удовлетворяет номер ДК.
Для этого предварительно каждую маску разложить на набор простых диапазонов номеров карт
и искать в этом множестве диапазонов пересекающиеся диапазоны для разных объектов и/или фирм
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop max-length 19

define temp-table temp-mask-range no-undo
field mask-original   like ub.dis-card-mask.mask
field mask      like ub.dis-card-mask.mask
field mask-num as integer
field lvl-decompose as integer
field host-code like ub.sysconf.host-code
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field first-code as decimal
field last-code as decimal
field to-check as logical
index pi is unique mask-num lvl-decompose first-code last-code
index iobj to-check first-code last-code host-code obj-type obj-code
.


procedure decompose-mask :
define input parameter p-mask-num  like ub.dis-card-mask.mask-num no-undo .
define input parameter p-mask      like ub.dis-card-mask.mask     no-undo .
define input parameter p-mask-original like ub.dis-card-mask.mask     no-undo .
define input parameter p-lvl-decompose  as integer no-undo .
define input parameter p-host-code like ub.sysconf.host-code      no-undo .
define input parameter p-obj-type  like ub.clients.obj-type       no-undo .
define input parameter p-obj-code  like ub.clients.obj-code       no-undo .

define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-kk as integer no-undo .
define variable v-max as integer no-undo .
define variable v-mask as character no-undo .
define variable v-mask0 as character no-undo .
define variable v-mask9 as character no-undo .
define variable v-mask-char as character no-undo .
define variable v-dec       as decimal no-undo .

  do
  on error undo, return error return-value
  :
    assign
    v-mask = p-mask
    v-max = length (p-mask).
    _do:
    do v-ii = 1 to v-max:
      assign
      v-mask-char = substring(p-mask, v-ii, 1)
      .
      if v-mask-char = {&question-mark} then do:
        do v-kk = 0 to 9:
          create temp-mask-range.
          assign
          substring(v-mask, v-ii, 1) = string(v-kk)
          temp-mask-range.mask     = v-mask
          temp-mask-range.mask-original = p-mask-original
          temp-mask-range.mask-num = p-mask-num
          temp-mask-range.host-code = p-host-code
          temp-mask-range.obj-type  = p-obj-type
          temp-mask-range.obj-code  = p-obj-code
          temp-mask-range.lvl-decompose = p-lvl-decompose + 1
          .
          assign
          v-dec = decimal(v-mask + "." ) no-error .
          if not error-status:error then
          assign
          temp-mask-range.first-code = decimal(v-mask + ".")
          temp-mask-range.last-code = decimal(v-mask + ".")
          temp-mask-range.to-check  = yes
          .
          else do:
            assign
            temp-mask-range.first-code = ?
            temp-mask-range.last-code = ?
            temp-mask-range.to-check  = no
            .
          end.
        end.
      end.
      if v-mask-char = "*":U then do:
        assign
        v-mask =  trim(v-mask, "*":U)
        v-mask0 = trim(v-mask, "*":U)
        v-mask9 = trim(v-mask, "*":U)
        .
        do v-jj = 1 to ({&max-length} - v-ii + 1) :
          create temp-mask-range.
          assign
          temp-mask-range.mask     = v-mask
          temp-mask-range.mask-original = p-mask-original
          temp-mask-range.mask-num = p-mask-num
          temp-mask-range.host-code = p-host-code
          temp-mask-range.obj-type  = p-obj-type
          temp-mask-range.obj-code  = p-obj-code
          temp-mask-range.lvl-decompose = p-lvl-decompose + 1
          v-mask  = v-mask + "0"
          v-mask0 = v-mask0 + "0"
          v-mask9 = v-mask9 + "9"
          .
          assign
          v-dec = decimal(v-mask0 + ".") no-error .
          if not error-status:error then
          assign
          temp-mask-range.first-code = decimal(v-mask0 + ".":U)
          temp-mask-range.last-code = decimal(v-mask9 + ".")
          temp-mask-range.to-check  = yes
          .
        end.
      end.
    end.
    for each temp-mask-range no-lock where
            temp-mask-range.mask-num = p-mask-num
        AND temp-mask-range.lvl-decompose = p-lvl-decompose + 1:
      if index(temp-mask-range.mask, "*":U) > 0 then
      run decompose-mask in this-procedure (
                                               input temp-mask-range.mask-num
                                              ,input temp-mask-range.mask
                                              ,input temp-mask-range.mask-original
                                              ,input temp-mask-range.lvl-decompose
                                              ,input temp-mask-range.host-code
                                              ,input temp-mask-range.obj-type
                                              ,input temp-mask-range.obj-code  ).
    end.

  end.

end procedure. /* decompose-mask */


procedure check-mask-correct-ho-join :
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-type              like ub.dis-card-mask.type no-undo .
define input parameter p-new-mask          like ub.dis-card-mask.mask      no-undo .
define input parameter p-new-host-code     like ub.dis-card-mask.host-code no-undo .
define input parameter p-new-obj-type      like ub.dis-card-mask.obj-type  no-undo .
define input parameter p-new-obj-code      like ub.dis-card-mask.obj-code  no-undo .


define output parameter p-is-correct as logical no-undo .
define variable v-found as logical no-undo .
define buffer buf_temp-mask-range for temp-mask-range.
define buffer buf_dis-card-mask for ub.dis-card-mask.

  do
  on error undo, return error
  :
    /*декомпозируем все имеющиеся действующие маски по данному типу ДК*/
    for each temp-mask-range:
      delete temp-mask-range.
    end.
    for each buf_dis-card-mask no-lock where
            buf_dis-card-mask.emitent-host-code = p-emitent-host-code
        AND buf_dis-card-mask.type = p-type
        AND buf_dis-card-mask.stts = integer({&current-status-int})
        :
      if buf_dis-card-mask.use-on = integer({&dcm-only-cd}) then NEXT.
      /*потому что здесь проверяем корректность для масок НЕОТСЫЛАЕМЫХ НА КАССУ*/
      run decompose-mask in this-procedure (
                                               input buf_dis-card-mask.mask-num
                                              ,input buf_dis-card-mask.mask
                                              ,input buf_dis-card-mask.mask
                                              ,input 0 /* p-lvl-decompose*/
                                              ,input buf_dis-card-mask.host-code
                                              ,input buf_dis-card-mask.obj-type
                                              ,input buf_dis-card-mask.obj-code  ).

    end.
    /*если мы проверяем  при добавлении новой маски - еще не записанной в БД*/
    if p-new-mask <> "":U then do:
      run decompose-mask in this-procedure (
                                               input 0 /*mask-num*/
                                              ,input p-new-mask
                                              ,input p-new-mask
                                              ,input 0 /* p-lvl-decompose*/
                                              ,input p-new-host-code
                                              ,input p-new-obj-type
                                              ,input p-new-obj-code   ).
    end.
    for each temp-mask-range no-lock where
            temp-mask-range.to-check = yes
    break
    by temp-mask-range.host-code
    by temp-mask-range.obj-type
    by temp-mask-range.obj-code:
      for each buf_temp-mask-range where
             buf_temp-mask-range.to-check = yes
         AND
             (buf_temp-mask-range.first-code >= temp-mask-range.first-code
         AND buf_temp-mask-range.first-code <= temp-mask-range.last-code)
         OR
             (buf_temp-mask-range.last-code >= temp-mask-range.first-code
         AND buf_temp-mask-range.last-code <= temp-mask-range.last-code):
        if recid(buf_temp-mask-range) = recid(temp-mask-range) then Next.
        if temp-mask-range.host-code <> 0
        and (buf_temp-mask-range.host-code = temp-mask-range.host-code
        AND buf_temp-mask-range.obj-type = temp-mask-range.obj-type
        AND buf_temp-mask-range.obj-code = temp-mask-range.obj-code) then NEXT.
        assign
        v-found = yes.
        return substitute("Могут существовать номера карт, удовлетворяющих маске &1 по фирме &2 объект &3 и маске &4 по фирме &5 объект &6"
                           , temp-mask-range.mask-original
                           , temp-mask-range.host-code
                           , (temp-mask-range.obj-type + string(temp-mask-range.obj-code))
                           , buf_temp-mask-range.mask-original
                           , buf_temp-mask-range.host-code
                           , (buf_temp-mask-range.obj-type + string(buf_temp-mask-range.obj-code))
                              ).
      end.
    end.
    assign
    p-is-correct = yes.
  end.

end procedure. /* check-mask-correct-ho-join */





/* $Workfile$ e n d */