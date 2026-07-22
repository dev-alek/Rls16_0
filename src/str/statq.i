/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подтверждение ожидаемого СТАТУС+Флага по накладной , заказам и поставкам

Автор: Чернова Светлана Александровна
Дата создания: 10/26/09
Author: Svetlana Chernova
Creation date: 10/26/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }
{ cmp/library.i }

procedure statq_has-waiting-stat :
define input parameter p-oldbh              as handle no-undo .  /* Старый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-newbh              as handle no-undo .  /* Новый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-changed-fields     as character no-undo . /* Список полей для проверки изменений Если буфера одинаковые */
define input parameter p-waiting-status     as character no-undo . /* Ожидаемый статус */
define input parameter p-waiting-flag       as logical no-undo .     /* Ожидаемый флаг   */
define input parameter p-waiting-stati      as integer no-undo .    /* Ожидаемый status для edocNN */
define output parameter p-is-waiting-status as logical no-undo .    /* Ожидаемый статус+флаг подтверждается */
define output parameter p-direction         as character no-undo .  /* Направление графа открытие/закрытие  */

define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-changed-fields as character no-undo .
define variable v-ii as integer no-undo .
define variable v-flag as logical   no-undo .
define variable v-some-bh as handle no-undo .

assign
v-has-oldbh = valid-handle(p-oldbh) and p-oldbh:available
v-has-newbh = valid-handle(p-newbh) and p-newbh:available
v-flag = false
.

if v-has-newbh then do:  /* ЕСТЬ 2й буфер*/
  if p-changed-fields = '' then do:
    v-changed-fields = "status_,flag_".
    do v-ii = 1 to num-entries(v-changed-fields):
      if p-oldbh:buffer-field(entry(v-ii, v-changed-fields)):buffer-value <> p-newbh:buffer-field(entry(v-ii, v-changed-fields)):buffer-value then do:
        v-flag = yes.
        leave.
      end.
    end.
    if not v-flag then do: /* буфера одинаковые */
       assign
         p-direction          = ""
         p-is-waiting-status   = false
       .
       return .
    end.
  end.
  else do:  /* Поля сравнения */
    if lookup("status_", p-changed-fields) = 0
    and lookup("flag_", p-changed-fields) = 0
    and not(p-newbh:new) then do:
       assign
         p-direction          = ""
         p-is-waiting-status   = false
       .
       return .
    end.
    else do:  /* Есть  поля status_  или flag_*/
      if lookup("status_", p-changed-fields) > 0  and lookup("flag_", p-changed-fields) > 0 and
        p-newbh::status_ = p-waiting-status and
        (p-newbh:table = {&table_price-doc} or p-newbh::flag_   = p-waiting-flag)   then do:
          assign
              p-direction          = {&close-doc}
              p-is-waiting-status   = true
          .
          return .
       end.
      if lookup("status_", p-changed-fields) > 0  and lookup("flag_", p-changed-fields) = 0 and
        p-newbh::status_ = p-waiting-status  then do:
          assign
              p-direction          = {&close-doc}
              p-is-waiting-status   = true
          .
          return .
       end.
      if lookup("status_", p-changed-fields) = 0  and lookup("flag_", p-changed-fields) > 0 and
      (p-newbh:table = {&table_price-doc} or p-newbh::flag_   = p-waiting-flag )  then do:
          assign
              p-direction          = {&close-doc}
              p-is-waiting-status   = true
          .
          return .
       end.
        if lookup("status_", p-changed-fields) > 0  and lookup("flag_", p-changed-fields) > 0 and
        p-newbh::status_ = p-waiting-status and
        (p-newbh:table = {&table_price-doc} or p-waiting-flag = ? )  then do:
          assign
              p-direction          = {&close-doc}
              p-is-waiting-status   = true
          .
          return .
       end.
    end.
  end.
end. /*if v-has-newbh then do:*/
else do: /* Нет второго буфера */
  if p-changed-fields = '' then do:
    if p-oldbh::status_ = p-waiting-status
    and (p-oldbh:table = {&table_price-doc}
        or
      (p-waiting-flag = ?
      or p-oldbh::flag_ = p-waiting-flag)) then do:
      assign
      p-direction = {&deletion}
      p-is-waiting-status = yes.
      return.
    end.
    else do:
      assign
      p-direction          = ""
      p-is-waiting-status = no.
      return.
    end.
  end.
  else do:
    if lookup("status_", p-changed-fields) = 0
    and lookup("flag_", p-changed-fields) = 0
    then do:
       assign
          p-is-waiting-status  = false
          p-direction          = ""
       .
       return .
    end.
  end.
end.

if v-has-newbh then do:
  v-some-bh = p-newbh.
end.
else do:
  v-some-bh = p-oldbh.
end.

case v-some-bh:table :
  when {&table_ord-doc}  then do:
     if v-some-bh::doc-type = {&O-R} or v-some-bh::doc-type = {&O-P} then do:
     if v-some-bh::doc-type = {&O-R} then do:
        run ord-orc in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
     end.
     if v-some-bh::doc-type = {&O-P} then do:
        run ord-op in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
     end.
     end.
     else do:
       assign
          p-is-waiting-status  = false
          p-direction          = ""
       .
     end.
  end.
  when {&table_ord-doc-rcv}  then do:
        run ord-rcv in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  when {&table_trn-doc}  then do:
        run stat-graf-trn in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  when {&table_price-doc} then do:
    run stat-graf-price in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  when {&table_inkas} then do:
        run stat-graf-inkas in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  otherwise do:
       assign
          p-is-waiting-status  = false
          p-direction          = ""
       .
  end.
end case.
return .
end procedure. /* trnstatq_is-waiting-stat */


procedure ord-op :
/* Обработка заказов ОП*/
define input parameter p-oldbh              as handle no-undo .  /* Старый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-newbh              as handle no-undo .  /* Новый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-changed-fields     as character no-undo . /* Список полей для проверки изменений Если буфера одинаковые */
define input parameter p-waiting-status     as character no-undo . /* Ожидаемый статус */
define input parameter p-waiting-flag       as logical no-undo .     /* Ожидаемый флаг   */
define output parameter p-is-waiting-status as logical no-undo .    /* Ожидаемый статус+флаг подтверждается */
define output parameter p-direction         as character no-undo .  /* Направление графа открытие/закрытие  */

define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .


  do
  on error undo, return error return-value
  :

assign
v-stat-list[1] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-accept} +  {&delim-key} +
                 {&ord-rcv}    +  {&delim-key} +
                 {&ord-close}  +  {&delim-key} +
                 {&fact}
v-stat-list[2] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-rejection}
v-stat-list[3] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-accept} +  {&delim-key} +
                 {&ord-rejection}
v-stat-list[4] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-accept} +  {&delim-key} +
                 {&ord-rcv}    +  {&delim-key} +
                 {&ord-rejection}
v-stat-list[5] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-accept} +  {&delim-key} +
                 {&ord-rcv}    +  {&delim-key} +
                 {&ord-close}  +  {&delim-key} +
                 {&ord-rejection}
.
/*чего отслеживаем*/

  assign
  v-waiting-stfl = p-waiting-status
  .
  /*зададим начальный и конечный статус*/
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  /*цифровое выражение нач и конечной точки для всех возможный путей - пока максимум 2 возможных пути*/
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], {&delim-key})
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], {&delim-key})
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], {&delim-key})
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to".
      return.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to-up".
      return.
      end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to".
      return.
      end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to-down".
      return.
      end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "from".
      return.
    end.
  end.

  end.

end procedure. /* ord-op */


procedure ord-orc :
/* Обработка заказов ОРЦ */
define input parameter p-oldbh              as handle no-undo .  /* Старый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-newbh              as handle no-undo .  /* Новый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-changed-fields     as character no-undo . /* Список полей для проверки изменений Если буфера одинаковые */
define input parameter p-waiting-status     as character no-undo . /* Ожидаемый статус */
define input parameter p-waiting-flag       as logical no-undo .     /* Ожидаемый флаг   */
define output parameter p-is-waiting-status as logical no-undo .    /* Ожидаемый статус+флаг подтверждается */
define output parameter p-direction         as character no-undo .  /* Направление графа открытие/закрытие  */

define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .


  do
  on error undo, return error return-value
  :

assign
v-stat-list[1] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-req} +  {&delim-key} +
                 {&ord-per}    +  {&delim-key} +
                 {&ord-ship}  +  {&delim-key} +
                 {&fact}
v-stat-list[2] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-rejection}
v-stat-list[3] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-req} +  {&delim-key} +
                 {&ord-rejection}
v-stat-list[4] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-req} +  {&delim-key} +
                 {&ord-per}    +  {&delim-key} +
                 {&ord-rejection}
v-stat-list[5] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&ord-req} +  {&delim-key} +
                 {&ord-per}    +  {&delim-key} +
                 {&ord-ship}  +  {&delim-key} +
                 {&ord-rejection}
.
/*чего отслеживаем*/

  assign
  v-waiting-stfl = p-waiting-status
  .
  /*зададим начальный и конечный статус*/
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  /*цифровое выражение нач и конечной точки для всех возможный путей - пока максимум 2 возможных пути*/
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], {&delim-key})
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], {&delim-key})
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], {&delim-key})
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to".
      return.
      end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to-down".
      return.
      end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "from".
      return.
      end.
      end.
  end.
end procedure. /* ord-orc */


procedure ord-rcv :
/* Поставки */
define input parameter p-oldbh              as handle no-undo .  /* Старый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-newbh              as handle no-undo .  /* Новый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-changed-fields     as character no-undo . /* Список полей для проверки изменений Если буфера одинаковые */
define input parameter p-waiting-status     as character no-undo . /* Ожидаемый статус */
define input parameter p-waiting-flag       as logical no-undo .     /* Ожидаемый флаг   */
define output parameter p-is-waiting-status as logical no-undo .    /* Ожидаемый статус+флаг подтверждается */
define output parameter p-direction         as character no-undo .  /* Направление графа открытие/закрытие  */

define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .

   do
   on error undo, return error return-value
   :

  assign
  v-stat-list[1] =
                  ''            +  {&delim-key} +
                  {&g___new}    +  {&delim-key} +
                  {&ord-rcv} +  {&delim-key} +
                  {&fact}
  v-stat-list[2] =
                  ''            +  {&delim-key} +
                  {&g___new}    +  {&delim-key} +
                  {&rejected}
  v-stat-list[3] =
                  ''            +  {&delim-key} +
                  {&g___new}    +  {&delim-key} +
                  {&ord-rcv} +  {&delim-key} +
                  {&rejected}
  .
/*чего отслеживаем*/

  assign
  v-waiting-stfl = p-waiting-status
  .
  /*зададим начальный и конечный статус*/
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  /*цифровое выражение нач и конечной точки для всех возможный путей - пока максимум 2 возможных пути*/
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], {&delim-key})
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], {&delim-key})
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], {&delim-key})
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "from".
      return.
      end.
      end.
   end.
end procedure. /* ord-rcv */

procedure stat-graf-trn :
/* Обработка Накладных */
define input parameter  p-oldbh              as handle no-undo .      /* Старый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter  p-newbh              as handle no-undo .      /* Новый буфер (trn-doc, ord-doc, ord-doc-rcv) */
define input parameter  p-changed-fields     as character no-undo .   /* Список полей для проверки изменений Если буфера одинаковые */
define input parameter  p-waiting-status     as character no-undo .   /* Ожидаемый статус */
define input parameter  p-waiting-flag       as logical no-undo .     /* Ожидаемый флаг   */
define output parameter p-is-waiting-status  as logical no-undo .     /* Ожидаемый статус+флаг подтверждается */
define output parameter p-direction          as character no-undo .   /* Направление графа открытие/закрытие  */

define variable v-doc-code as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-stat-list as character no-undo extent 84.
define variable v-stat-list-all as character no-undo .
define variable v-jj as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-waiting-stfl-i as integer no-undo .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
:

if p-newbh = ?  then do:
  /*но сюда не попадем*/
  v-doc-code = p-oldbh::doc-code .
  v-ext-doc-type = p-oldbh::ext-doc-type .
end.
else do:
  v-doc-code     = p-newbh::doc-code .
  v-ext-doc-type = p-newbh::ext-doc-type .
end.

assign
v-stat-list-all =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(yes) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(no) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(yes) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(no) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(yes) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(yes)
.
assign
v-stat-list[lookup({&TDEDT_Pri_Vnesh}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Ras_Vnesh}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Ras_Vnesh}, {&TDEDT_List}) * 4 - 2] =
                                                                 '' +           {&delim-par} + string(no) + {&delim-key} +
                                                                 {&ready}     + {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Ras_Vnesh}, {&TDEDT_List}) * 4 - 1] =
                                                                 '' +           {&delim-par} + string(no) + {&delim-key} +
                                                                 {&rejected}  +  {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Ras_Vnesh_VP}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Vozvrat_Vnesh}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Spi_Vnesh}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Peresort}, {&TDEDT_List}) * 4 - 3] =
                                                                ''              + {&delim-par} + string(no) + {&delim-key} +
                                                                {&wayb}         + {&delim-par} + string(no) + {&delim-key} +
                                                                {&fact}         + {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Pri_Perem}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Ras_Perem}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Pri_Object}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Ras_Object}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Vozvrat_Perem}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Ras_Prvo}, {&TDEDT_List}) * 4 - 3] = v-stat-list-all
v-stat-list[lookup({&TDEDT_Spi_Prvo}, {&TDEDT_List}) * 4 - 3] =
                                                                ''              + {&delim-par} + string(no) + {&delim-key} +
                                                                {&manufactured} + {&delim-par} + string(yes) + {&delim-key} +
                                                                {&fact}         + {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Pri_Prvo}, {&TDEDT_List}) * 4 - 3] =
                                                                ''              + {&delim-par} + string(no) + {&delim-key} +
                                                                {&fact}         + {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Corr_Acc_Price}, {&TDEDT_List}) * 4 - 3] =
                                                                      ''              + {&delim-par} + string(no) + {&delim-key} +
                                                                      {&wayb}         + {&delim-par} + string(no) + {&delim-key} +
                                                                      {&fact}         + {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Corr_Minus_Parts}, {&TDEDT_List}) * 4 - 3] =
                                                                      ''              + {&delim-par} + string(no) + {&delim-key} +
                                                                      {&fact}         + {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Chg_Purch_Code}, {&TDEDT_List}) * 4 - 3] =
                                                                      ''              + {&delim-par} + string(no) + {&delim-key} +
                                                                      {&fact}         + {&delim-par} + string(yes)
.

assign
v-stat-list[lookup({&TDEDT_Pri_vnesh}, {&TDEDT_List}) * 4 - 2] =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(yes) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(no) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(yes) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(no) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(yes) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(no)
.
assign
v-stat-list[lookup({&TDEDT_Inv}, {&TDEDT_List}) * 4 - 3] =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(yes) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(no) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(yes) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(yes) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(no) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(yes)
.
assign
v-stat-list[lookup({&TDEDT_Inv}, {&TDEDT_List}) * 4 - 2] =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} +   {&delim-par} + string(yes) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(no) + {&delim-key} +
                 {&wayb} +      {&delim-par} + string(yes) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(yes) + {&delim-key} +
                 {&permitted} + {&delim-par} + string(no) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(no)
.
assign
v-stat-list[lookup({&TDEDT_Ras_Vnesh_Kass}, {&TDEDT_List}) * 4 - 3] =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&cash-desk} + {&delim-par} + string(no) + {&delim-key} +
                 {&cash-desk} + {&delim-par} + string(yes) + {&delim-key} +
                 {&doc-froze} + {&delim-par} + string(yes) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(yes)
v-stat-list[lookup({&TDEDT_Vozvrat_Vnesh_Kass}, {&TDEDT_List}) * 4 - 3] =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&cash-desk} + {&delim-par} + string(no) + {&delim-key} +
                 {&cash-desk} + {&delim-par} + string(yes) + {&delim-key} +
                 {&doc-froze} + {&delim-par} + string(yes) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(yes)

v-stat-list[lookup({&TDEDT_Ras_Vnesh_Kass}, {&TDEDT_List}) * 4 - 2] =
                 '' +         {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} + {&delim-par} + string(no)
v-stat-list[lookup({&TDEDT_Vozvrat_Vnesh_Kass}, {&TDEDT_List}) * 4 - 2] =
                 '' +         {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} + {&delim-par} + string(no)
.

/*чего отслеживаем*/
_jj:
do v-jj = 1 to 2:
  if v-jj = 1 then do:
    assign
    v-waiting-stfl = p-waiting-status + {&delim-par} + string(if p-waiting-flag = ? then yes else p-waiting-flag)
    .
  end.
  if v-jj = 2 then do:
    if p-waiting-flag <> ? then leave  _jj.
    assign
    v-waiting-stfl = p-waiting-status + {&delim-par} + string(no)
    .
  end.
  /*зададим начальный и конечный статус*/
  assign
  v-old-stfl = p-oldbh::status_ + {&delim-par} + string(p-oldbh::flag_)
  .
  assign
  v-new-stfl = p-newbh::status_ + {&delim-par} + string(p-newbh::flag_)
  .
  /*цифровое выражение нач и конечной точки для всех возможный путей - пока максимум 4 возможных пути*/
  _ii:
  do v-ii = (lookup(v-ext-doc-type, {&TDEDT_List}) * 4 - 3) to (lookup(v-ext-doc-type, {&TDEDT_List}) * 4):
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], {&delim-key})
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], {&delim-key})
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], {&delim-key})
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "from".
      return.
    end.
  end.
end. /*do v-jj = 1 to 2:*/
end.
end procedure .

procedure stat-graf-price :
define input parameter p-oldbh              as handle no-undo .  /* Старый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-newbh              as handle no-undo .  /* Новый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter p-changed-fields     as character no-undo . /* Список полей для проверки изменений Если буфера одинаковые */
define input parameter p-waiting-status     as character no-undo . /* Ожидаемый статус */
define input parameter p-waiting-flag       as logical no-undo .     /* Ожидаемый флаг   */
define output parameter p-is-waiting-status as logical no-undo .    /* Ожидаемый статус+флаг подтверждается */
define output parameter p-direction         as character no-undo .  /* Направление графа открытие/закрытие  */


define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .


do
on error undo, return error return-value
:

assign
v-stat-list[1] =
                 ''            +  {&delim-key} +
                 {&g___new}    +  {&delim-key} +
                 {&order}      +  {&delim-key} +
                 {&permitted}  +  {&delim-key} +
                 {&act-overvalue}
.
/*чего отслеживаем*/

  assign
  v-waiting-stfl = p-waiting-status
  .
  /*зададим начальный и конечный статус*/
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  /*цифровое выражение нач и конечной точки для всех возможный путей - пока максимум 2 возможных пути*/
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], {&delim-key})
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], {&delim-key})
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], {&delim-key})
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "from".
      return.
    end.
  end.

end.
end procedure. /* stat-graf-price */

procedure stat-graf-inkas :
/* Обработка inkas */
define input parameter  p-oldbh              as handle no-undo .      /* Старый буфер (trn-doc, ord-doc, ord-doc-rcv)*/
define input parameter  p-newbh              as handle no-undo .      /* Новый буфер (trn-doc, ord-doc, ord-doc-rcv) */
define input parameter  p-changed-fields     as character no-undo .   /* Список полей для проверки изменений Если буфера одинаковые */
define input parameter  p-waiting-status     as character no-undo .   /* Ожидаемый статус */
define input parameter  p-waiting-flag       as logical no-undo .     /* Ожидаемый флаг   */
define output parameter p-is-waiting-status  as logical no-undo .     /* Ожидаемый статус+флаг подтверждается */
define output parameter p-direction          as character no-undo .   /* Направление графа открытие/закрытие  */

define variable v-doc-code as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-stat-list as character no-undo extent 3.
define variable v-jj as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-waiting-stfl-i as integer no-undo .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
:

if p-newbh = ?  then do:
  /*но сюда не попадем*/
  v-doc-code = p-oldbh::inkas-code .
end.
else do:
  v-doc-code     = p-newbh::inkas-code .
end.

assign
v-stat-list[1] =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&g___new} + {&delim-par} + string(no) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(no)
v-stat-list[2] =
                 '' +           {&delim-par} + string(no) + {&delim-key} +
                 {&g___new} + {&delim-par} + string(no) + {&delim-key} +
                 {&g___new} + {&delim-par} + string(yes) + {&delim-key} +
                 {&doc-froze} + {&delim-par} + string(yes) + {&delim-key} +
                 {&fact} +      {&delim-par} + string(no)

v-stat-list[3] =
                 '' +         {&delim-par} + string(no) + {&delim-key} +
                 {&inquiry} + {&delim-par} + string(no)
.

/*чего отслеживаем*/
_jj:
do v-jj = 1 to 2:
  if v-jj = 1 then do:
    assign
    v-waiting-stfl = p-waiting-status + {&delim-par} + string(if p-waiting-flag = ? then no else p-waiting-flag)
    .
  end.
  if v-jj = 2 then do:
    if p-waiting-flag <> ? then leave  _jj.
    assign
    v-waiting-stfl = p-waiting-status + {&delim-par} + string(yes)
    .
  end.
  /*зададим начальный и конечный статус*/
  assign
  v-old-stfl = p-oldbh::status_ + {&delim-par} + string(p-oldbh::flag_)
  .
  assign
  v-new-stfl = p-newbh::status_ + {&delim-par} + string(p-newbh::flag_)
  .
  /*цифровое выражение нач и конечной точки для всех возможный путей - пока максимум 4 возможных пути*/
  _ii:
  do v-ii = 1 to 3:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], {&delim-key})
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], {&delim-key})
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], {&delim-key})
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&close-doc} + {&delim-par} + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = {&open-doc} + {&delim-par} + "from".
      return.
    end.
  end.
end. /*do v-jj = 1 to 2:*/
end.
end procedure .


/* $Workfile$ e n d */