block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getdcmsk.p $
$Archive: utl/getdcmsk.p $

Вывод непересекающихся диапазонов ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/05
Author: Bakhtadze Natalya
Creation date: 09/14/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getdcmsk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/getdcmsk.p $":U .
define variable vss-description as character no-undo init "Вывод непересекающихся диапазонов ДК".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/r-pril.i  new }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }

define temp-table tt-dis-card no-undo
like ub.dis-card
field d-card-u like ub.dis-card.d-card
index pi is unique primary
d-card.

define temp-table temp-dc-mask no-undo
field d-card-start like ub.dis-card.d-card     /*реальная граница диапазона*/
field d-card-end   like ub.dis-card.d-card     /*реальная граница диапазона*/
field bis-d-card-start like ub.dis-card.d-card /*граница диапазона полученная в результате декомпозиции первично полученной маски*/
field bis-d-card-end   like ub.dis-card.d-card /*граница диапазона полученная в результате декомпозиции первично полученной маски*/
field type         like ub.dis-card-type.type
field num-recs     as integer
field num-recs-calc as decimal
field maska        as character
field maska-save   as character  /*хранит маску*/
field length_      as integer
field node-code    as integer
field upper-code   as integer
field high-code    as decimal
field to-decompose as logical
field cut-down     as logical
field cut-up       as logical
index pi is unique primary
node-code
index iupper upper-code
index i1 d-card-start maska
index isave
length_ maska-save
index isort1
length_ bis-d-card-start
index isort2
length_ bis-d-card-end
index ishow
length_
d-card-start
index id
to-decompose
.

define variable v-get-data  as character no-undo .
/*может быть db - тогда ездим по БД*/
/*можеть быть file - тогда импортируем во временную таблицу из txt файла*/
define variable ii as integer no-undo .
define variable v-not-number as logical no-undo .
define variable v-type like ub.dis-card-type.type no-undo .
define variable v-length as integer no-undo .
define variable v-dopi as decimal no-undo .
define variable v-print as logical no-undo .
define variable v-d-card like ub.dis-card.d-card no-undo .
define variable v-count as integer no-undo .
define variable v-flag as logical no-undo init yes.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-seq as integer no-undo .
define variable v-found as logical no-undo .
define variable v-file-name as character no-undo .
define variable v-file-directory as character no-undo .
define variable v-choose as logical no-undo .
define variable v-dopd as decimal no-undo .
define variable v-choice as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_clients for ub.clients.
define buffer buf_temp-dc-mask for temp-dc-mask.
define stream InStream.

  run gbl/d-askw.w (  input "Сбор данных по диапазонам ДК"
                ,input "получаем информацию по непересекающимся диапазонам карт"
                ,input "|"
                ,input ("Из БД|" +
                       "Из файла|" +
                       "Отказ")
                ,input "||"
                ,input 1
                ,input 3
                ,output v-choice).
if v-choice = 3 then return.
if v-choice = 1 then v-get-data = 'db'.
if v-choice = 2 then v-get-data = 'file'.



if v-get-data = 'db':U then do:
  for each tt-dis-card:
    delete tt-dis-card.
  end.
  for each buf_dis-card no-lock
  by buf_dis-card.d-card   :
    assign
    ii = ii + 1
    .
    if ii modulo 100 = 0 then do:
      run waitfram-show in this-procedure (string(ii)).
    end.
      create tt-dis-card.
    buffer-copy buf_dis-card
    to tt-dis-card
    assign
    tt-dis-card.d-card-u = fill('#':U , 19 - length(buf_dis-card.d-card)) + buf_dis-card.d-card.
  end.
  ii = 0.
  for each tt-dis-card no-lock
  by tt-dis-card.d-card-u   :
    assign
    ii = ii + 1
    v-print = no
    .
    if ii modulo 100 = 0 then do:
      run waitfram-show in this-procedure (string(ii)).
    end.
    if  length(tt-dis-card.d-card) <> v-length
    or tt-dis-card.type <> v-type then do:
      /*печатаем старый тип*/
      if v-type <> '':U then do:
        if available temp-dc-mask then
        assign
        temp-dc-mask.d-card-end = v-d-card
        temp-dc-mask.num-recs = v-count
        .
      end.
      v-count = 0.
      find first temp-dc-mask no-lock where
                temp-dc-mask.d-card-start = tt-dis-card.d-card no-error .
      if not available temp-dc-mask then do:
        create temp-dc-mask.
        assign
        temp-dc-mask.upper-code   = 0
        temp-dc-mask.node-code    = v-seq + 1
        v-seq                     = v-seq + 1
        temp-dc-mask.high-code    = temp-dc-mask.node-code
        temp-dc-mask.d-card-start = tt-dis-card.d-card
        temp-dc-mask.type = tt-dis-card.type
        temp-dc-mask.length_ = length(tt-dis-card.d-card)
        .
      end.
    end.
    assign
    v-length = length(tt-dis-card.d-card)
    v-type = tt-dis-card.type
    v-count = v-count + 1
    v-d-card = tt-dis-card.d-card
    .
    process events.
  end.
  find first temp-dc-mask where
            temp-dc-mask.node-code = v-seq - 1 no-error .
  if available temp-dc-mask then
  assign
  temp-dc-mask.d-card-end = v-d-card
  temp-dc-mask.num-recs = v-count
  .
end.
if v-get-data = 'file' then do:
  run gbl/d-file.p (
  input-output v-file-name
  ,input-output v-file-directory
  ,input        "Текстовые файлы,Все файлы"
  ,input        "*.txt,*.*":U
  ,input        ","
  ,input        "txt,all":U
  ,input        yes
  ,input        no
  ,input        yes
  ,input        "Введите имя файла, содержащего данные по диапазонам карт"
  ,output       v-choose
  ).
  if not v-choose then return.
  input stream Instream from value(v-file-name).
  _repeat:
  repeat:
    create temp-dc-mask.
    temp-dc-mask.num-recs = ?.
    import stream Instream temp-dc-mask.type temp-dc-mask.d-card-start temp-dc-mask.d-card-end temp-dc-mask.num-recs no-error .
    if error-status:error then do:
      message
      substitute("Строка &1&2Ошибка при импорте&2&3&2&4"
                , v-seq + 1
                , {&new-line}
                , error-status:get-message(1)
                , return-value )
     view-as alert-box error .
     next _repeat.
    end.
    if length(temp-dc-mask.d-card-start) <> length(temp-dc-mask.d-card-end) then do:
      message
      substitute("Строка &1&2Разная длина номера карты для карты начала и конца диапазона"
                , v-seq + 1
                , {&new-line})
      view-as alert-box error .
      next _repeat.
    end.
    assign
    v-dopd = decimal(temp-dc-mask.d-card-start) no-error.
    if ( error-status:error ) OR
        index( temp-dc-mask.d-card-start , "." ) > 0 OR
        index( temp-dc-mask.d-card-start , {&comma-char} ) > 0 OR
        index( temp-dc-mask.d-card-start , "-" ) > 0 OR
        index( temp-dc-mask.d-card-start , "+" ) > 0 then do:
      message
      substitute("Строка&1&2Возможно только цифровое значение номера дисконтной карты"
                 , v-seq + 1
                 , {&new-line})
      view-as alert-box error .
    end.
    assign
    v-dopd = decimal(temp-dc-mask.d-card-end) no-error.
    if ( error-status:error ) OR
        index( temp-dc-mask.d-card-start , "." ) > 0 OR
        index( temp-dc-mask.d-card-start , {&comma-char} ) > 0 OR
        index( temp-dc-mask.d-card-start , "-" ) > 0 OR
        index( temp-dc-mask.d-card-start , "+" ) > 0 then do:
      message
      substitute("Строка&1&2Возможно только цифровое значение номера дисконтной карты"
                 , v-seq + 1
                 , {&new-line})
      view-as alert-box error .
    end.
    assign
    temp-dc-mask.upper-code   = 0
    temp-dc-mask.node-code    = v-seq + 1
    v-seq                     = v-seq + 1
    temp-dc-mask.high-code    = temp-dc-mask.node-code
    temp-dc-mask.length_ = length(temp-dc-mask.d-card-start)
    temp-dc-mask.num-recs = (if temp-dc-mask.num-recs = ?
                             then decimal(temp-dc-mask.d-card-end) - decimal(temp-dc-mask.d-card-start) + 1
                             else temp-dc-mask.num-recs)
    .
  end.
  input stream Instream close.
  find first temp-dc-mask where
  temp-dc-mask.type = '':U no-error .
  if available temp-dc-mask then delete temp-dc-mask.

end.
_temp-dc-mask:
for each temp-dc-mask:
 v-flag = yes.
  do ii = 1 to temp-dc-mask.length_:
    assign
    v-dop1 = substring(temp-dc-mask.d-card-start, ii, 1)
    v-dop2 = substring(temp-dc-mask.d-card-end, ii, 1)
    v-flag = v-flag and (v-dop1 = v-dop2 )
    .
    assign
    temp-dc-mask.maska =  temp-dc-mask.maska +
                         (if v-dop1 = v-dop2
                         and v-flag
                         then v-dop1
                         else {&question-mark})
    temp-dc-mask.maska-save =  temp-dc-mask.maska
    .
  end.
  if temp-dc-mask.num-recs = 1
  or index(temp-dc-mask.maska, {&question-mark}) = temp-dc-mask.length_  then do:
    temp-dc-mask.maska = "".
  end.
  assign
  temp-dc-mask.bis-d-card-start = replace(temp-dc-mask.maska-save, {&question-mark}, '0':U)
  temp-dc-mask.bis-d-card-end   = replace(temp-dc-mask.maska-save, {&question-mark}, '9':U)
  .
end.
for each temp-dc-mask
by temp-dc-mask.length_
by temp-dc-mask.d-card-start:
  if temp-dc-mask.maska <> '':U then
  run decompose-mask in this-procedure (buffer temp-dc-mask) .
end.
for each temp-dc-mask:
  if temp-dc-mask.maska <> '':U
  and temp-dc-mask.to-decompose = yes
  then
  run decompose-mask in this-procedure (buffer temp-dc-mask) .
end.

for each temp-dc-mask:
  assign
  temp-dc-mask.bis-d-card-start   = (if (temp-dc-mask.d-card-start >= temp-dc-mask.bis-d-card-start
                                    and temp-dc-mask.d-card-start <= temp-dc-mask.bis-d-card-end)
                                    and temp-dc-mask.cut-down
                                    then temp-dc-mask.d-card-start
                                    else temp-dc-mask.bis-d-card-start)
  temp-dc-mask.bis-d-card-end     = (if (temp-dc-mask.d-card-end >= temp-dc-mask.bis-d-card-start
                                    and temp-dc-mask.d-card-end <= temp-dc-mask.bis-d-card-end)
                                    and temp-dc-mask.cut-up
                                    then temp-dc-mask.d-card-end
                                    else temp-dc-mask.bis-d-card-end)
  temp-dc-mask.num-recs-calc      = decimal(temp-dc-mask.bis-d-card-end) - decimal(temp-dc-mask.bis-d-card-start) + 1
  .

end.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*append*/
                                            ).

put stream PrnLibStream unformatted
"Имеющиеся номера дисконтных карт" skip(0)
 cur-time-print() AT 5 format "x(35)" skip(0)
"Диапазоны дисконтных карт разложением на поддиапазоны" AT 5 skip(0)
"Рекоменд. маска"
"Тип карты"    at 21
"Начало диап." at 30
"Конец диап."  at 50
"Кол-во карт"  at 70
skip(0)
"Факт/возможн" at 30
"Факт/возможн" at 50
"Факт/возможн" at 70
skip(0)
fill('-', 80) skip(0).


for each temp-dc-mask where temp-dc-mask.upper-code = 0
by temp-dc-mask.length_
by temp-dc-mask.d-card-start

:
  put stream PrnLibStream unformatted
  temp-dc-mask.maska
  temp-dc-mask.type at 21
  temp-dc-mask.d-card-start at 30
  temp-dc-mask.d-card-end   at 50
  temp-dc-mask.num-recs     at 70
  skip.
  put stream PrnLibStream unformatted
  fill('-', 80) skip(0).
  v-found = no.
  for each buf_temp-dc-mask no-lock where
          buf_temp-dc-mask.upper-code = temp-dc-mask.node-code :

    put stream PrnLibStream unformatted
    buf_temp-dc-mask.maska
    buf_temp-dc-mask.bis-d-card-start at 30
    buf_temp-dc-mask.bis-d-card-end   at 50
    buf_temp-dc-mask.num-recs-calc    at 70
    skip.
    v-found = yes.
  end.
  if not v-found then do:
    put stream PrnLibStream unformatted
    temp-dc-mask.maska
    temp-dc-mask.bis-d-card-start at 30
    temp-dc-mask.bis-d-card-end   at 50
    temp-dc-mask.num-recs-calc    at 70
    skip.
  end.
  put stream PrnLibStream unformatted
  skip(2).
end.
put stream PrnLibStream unformatted
skip(0)
"В порядке номеров карт" AT 5 skip(0)
fill('-', 80) skip(1)
.

for each temp-dc-mask
by temp-dc-mask.length_
by temp-dc-mask.bis-d-card-start:
  find first buf_temp-dc-mask no-lock where
            buf_temp-dc-mask.upper-code = temp-dc-mask.node-code no-error .
  if not available buf_temp-dc-mask then do:
    put stream PrnLibStream unformatted
    temp-dc-mask.maska
    temp-dc-mask.type at 21
    temp-dc-mask.bis-d-card-start at 30
    temp-dc-mask.bis-d-card-end   at 50
    temp-dc-mask.num-recs-calc    at 70
    skip.
  end.
end.

output stream PrnLibStream close.

run waitfram-hide in this-procedure .


run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


procedure decompose-mask :
define parameter buffer buf_temp-dc-mask for temp-dc-mask.
define variable v-mask as character no-undo .
define variable v-first-ques as integer no-undo .
define variable v-start as integer no-undo .
define variable v-end as integer no-undo .
define variable v-found as logical no-undo .
define variable v-new-maska as character no-undo .
define buffer buf1_temp-dc-mask for temp-dc-mask .  /*буфер масок получившихся в результате decompose*/
define buffer buf2_temp-dc-mask for temp-dc-mask . /*буфер маски которая нам мешает*/


do
on error undo, return error
:
  _buf2:
  for each buf2_temp-dc-mask where
            buf2_temp-dc-mask.length_ = buf_temp-dc-mask.length_
       and  buf2_temp-dc-mask.maska > '':U
       AND  (
             (buf2_temp-dc-mask.bis-d-card-start >= buf_temp-dc-mask.bis-d-card-start
              AND  buf2_temp-dc-mask.bis-d-card-start   <= buf_temp-dc-mask.bis-d-card-end)
              or
             (buf2_temp-dc-mask.bis-d-card-end >= buf_temp-dc-mask.bis-d-card-start
              AND  buf2_temp-dc-mask.bis-d-card-end   <= buf_temp-dc-mask.bis-d-card-end)
            ):

    if buf2_temp-dc-mask.high-code = buf_temp-dc-mask.high-code then next.
    assign
    v-mask = buf_temp-dc-mask.maska
    v-first-ques = index(v-mask, {&question-mark})
    .
    buf2_temp-dc-mask.to-decompose = yes.
    if v-first-ques = 0 then do:
      next _buf2.
    end.
    if
    (buf2_temp-dc-mask.bis-d-card-start >= buf_temp-dc-mask.bis-d-card-start
    AND  buf2_temp-dc-mask.bis-d-card-start   <= buf_temp-dc-mask.bis-d-card-end)  then do:
      assign
      buf_temp-dc-mask.cut-down = yes.
    end.
    if (buf2_temp-dc-mask.bis-d-card-end >= buf_temp-dc-mask.bis-d-card-start
    AND  buf2_temp-dc-mask.bis-d-card-end   <= buf_temp-dc-mask.bis-d-card-end) then do:
      assign
      buf_temp-dc-mask.cut-up = yes.
    end.


    assign
    v-start = integer(substring(buf_temp-dc-mask.d-card-start, v-first-ques , 1))
    v-end   = integer(substring(buf_temp-dc-mask.d-card-end, v-first-ques , 1))
    buf_temp-dc-mask.maska = '':U
    .
    do ii = v-start to v-end:
      v-new-maska                          = v-mask.
      substring(v-new-maska, v-first-ques, 1) = string(ii).
      create buf1_temp-dc-mask.
      buffer-copy buf_temp-dc-mask
      except cut-down cut-up
      to buf1_temp-dc-mask
      assign
      buf1_temp-dc-mask.upper-code         = buf_temp-dc-mask.node-code
      buf1_temp-dc-mask.node-code          = v-seq + 1
      v-seq                                = v-seq + 1
      buf1_temp-dc-mask.maska              = v-new-maska
      buf1_temp-dc-mask.bis-d-card-start   = replace(buf1_temp-dc-mask.maska, {&question-mark}, '0':U)
      buf1_temp-dc-mask.bis-d-card-end     = replace(buf1_temp-dc-mask.maska, {&question-mark}, '9':U)
      .
    end.
    for each buf1_temp-dc-mask where
    buf1_temp-dc-mask.upper-code = buf_temp-dc-mask.node-code:
      run decompose-mask in this-procedure (buffer buf1_temp-dc-mask).
    end.
    buf_temp-dc-mask.to-decompose = no.
  end.
end. /*doe*/

end procedure. /* decompose-mask */