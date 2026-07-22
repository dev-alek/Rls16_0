/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура открытия смены

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/28/09
Author: Dmitry Ukhanov
Creation date: 01/28/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/19/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable mOk as logical no-undo.
define variable mBachMode as logical no-undo.
&if defined(BachMode) ne 0
&then
   mBachMode = yes.
&endif   

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Открытие смены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/integerm.i }
define variable f-date   as date    no-undo.    /* факт дата для документа */
define variable f-time   as integer no-undo.    /* факт время для документа */
define variable s-date   as date    no-undo.    /* дата начала смены для документа */
define variable e-date   as date    no-undo.
define variable s-time   as integer no-undo.    /* дата начала смены для документа */
define variable e-time   as integer no-undo.
define variable s-num      as integer   no-undo.    /* порялок смены для документа */
define variable s-name     as character no-undo.    /* номер смены для документа */
define variable s-name-int as integer   no-undo.
define variable is-super as log     no-undo.    /* является ли пользователь менеджером */
define variable varupd-obj-date as logical initial no   no-undo.
define variable varobj-date     as date                 no-undo.
define variable v-sys-date      as date                 no-undo. /* Системная дата */
define variable v-sys-time      as integer              no-undo. /* Системное время */
define variable v-cancel        as logical              no-undo.
define variable glog as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

define buffer bf-trb_shift-obj   for ub.shift-obj .
define buffer open-shift         for ub.shift-obj .
define buffer buf_shift-obj      for ub.shift-obj .
define buffer closed-shift       for ub.shift-obj .  /* буфер для закрытой смены */
&if defined (MyPutMes) eq 0
&then 
procedure put-mes:
define input  parameter iVss    as logical   no-undo.
define input  parameter iText   as character no-undo.
define input  parameter iGetMes as logical   no-undo.
define input  parameter iRetval as character no-undo.

message if ivss then vss-workfile else ""
        if ivss then vss-revision else ""
        if ivss then vss-description else ""
        if ivss then "~n" else ""
        iText skip
        if iGetMes then trim(error-status :get-message(1)) else ""  
        if iGetMes then trim(error-status :get-message(2)) else ""
        if iGetMes then trim(error-status :get-message(3)) else ""
        if iGetMes then trim(error-status :get-message(4)) else ""
        if iGetMes then trim(error-status :get-message(5)) else ""
        skip
        iRetval
   view-as alert-box error .
end procedure.
&endif   
do
on error undo, return error return-value + error-status:get-message(1) + error-status:get-message(2)
:

{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
{ gbl/getcntxt.i get }

/* проверяем, что на объекте включены смены */
{ gbl/objat.i
  p-curr-obj-type
  p-curr-obj-code
  "'shift-on=request'"
  glog
  no-error
}
if error-status :error then do:
  run put-mes(yes ,"Ошибка при запуске процедуры objat",yes,return-value).
  return error.
end.
/* Читаем системную дату и дату на объекте */
run cur-time in this-procedure ( output v-sys-date
                               , output v-sys-time
                               ) no-error.
if error-status:error then do:
    run put-mes(yes ,"Ошибка при чтении системной даты.",yes,return-value).
    
    undo, return error .
end.
{ gbl/curobjdt.i
  p-curr-obj-type
  p-curr-obj-code
  varobj-date
  no-error
}
if error-status:error then do:
  run put-mes(no ,"Ошибка при чтении календарной даты на текущем объекте.",no,"").
  return error.
end.
if not glog then do:
  run put-mes(yes ,substitute("На объекте выключены смены.~nРабота со сменами невозможна.~nОбъект:&1 &2", p-curr-obj-type, p-curr-obj-code),no,"").
  return error.
end.

/* проверяем права на работу со сменами */
/* менеджер */
is-super = no.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_shift_super':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  false
  glog
}
if glog then do:
  is-super = yes.
end.
else do:
  /* обычный пользователь */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_shift_regular':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
end.
if not glog then do:
  run put-mes(no ,substitute("Вы не имеете прав для работы со сменами.~nОбъект:&1 &2", p-curr-obj-type, p-curr-obj-code),no,"").
  return error.
end.
find last open-shift where
          open-shift.obj-type = p-curr-obj-type and
          open-shift.obj-code = p-curr-obj-code and
          open-shift.status_ = {&sht-current}
          use-index pi no-error.
if available open-shift then do:
  run put-mes(no ,substitute("На объекте &1 &2 уже есть открытая смена &3 &4."
                             ,p-curr-obj-type
                             ,p-curr-obj-code
                             ,open-shift.shift-date  
                             ,open-shift.shift-num
  ),no,"").
  return error.
end.

/* ищем запланированную смену */
find first buf_shift-obj no-lock
     where buf_shift-obj.obj-type = p-curr-obj-type
       and buf_shift-obj.obj-code = p-curr-obj-code
       and buf_shift-obj.status_ = {&sht-expected}
use-index pi no-error.
if available buf_shift-obj
then do:
  /* может быть начата только запланированная смена */
    do transaction
    on error undo, return error "Ошибка обработки запланированной смены" :
        find first buf_shift-obj exclusive-lock
             where buf_shift-obj.obj-type   = p-curr-obj-type
               and buf_shift-obj.obj-code    = p-curr-obj-code
               and buf_shift-obj.status_     = {&sht-expected}
        use-index pi no-error.
        assign
            s-date = buf_shift-obj.shift-date
            s-time = v-sys-time
            s-num  = buf_shift-obj.shift-num
            s-name = buf_shift-obj.shift-name
        .
        run gbl/shift.w (
              input parparentproc
            , input p-curr-obj-type
            , input p-curr-obj-code
            , input-output s-date /* дата начала смены для документа */
            , input-output e-date
            , input-output s-time /* время начала смены для документа */
            , input-output e-time
            , input-output s-num  /* порядок смены для документа */
            , input-output s-name /* номер смены для документа */
            , input "open-planned"
            , output v-cancel
        ) no-error.
        if error-status:error then do:
                run put-mes(yes ,"Ошибка ввода времени для новой смены.",yes,return-value).
          
                undo, return error .
        end.
        if v-cancel = yes
        then do:
            undo, return.
        end.
        assign
            buf_shift-obj.open-sys-date = v-sys-date
            buf_shift-obj.open-sys-time = v-sys-time
        .
        /* Параметры для смены */
        define buffer bf_shift-param for ub.shift-param .
        find first bf_shift-param no-lock where bf_shift-param.obj-code = 0 and
            bf_shift-param.obj-type = "" and
            bf_shift-param.shift-date = 01.01.1900  no-error .
        if available (bf_shift-param) then
        do:
            find first ub.shift-param no-lock where ub.shift-param.obj-code = buf_shift-obj.obj-code and
                ub.shift-param.obj-type = buf_shift-obj.obj-type and
                ub.shift-param.shift-date = buf_shift-obj.shift-date and
                ub.shift-param.shift-name = buf_shift-obj.shift-name and
                ub.shift-param.shift-num = buf_shift-obj.shift-num and
                ub.shift-param.gds-code = 0 and
                ub.shift-param.pl-code = 0 no-error .
            if not available (ub.shift-param) then 
            do:
                create ub.shift-param .
                assign
                    ub.shift-param.obj-code   = buf_shift-obj.obj-code
                    ub.shift-param.obj-type   = buf_shift-obj.obj-type
                    ub.shift-param.shift-date = buf_shift-obj.shift-date
                    ub.shift-param.shift-name = buf_shift-obj.shift-name
                    ub.shift-param.shift-num  = buf_shift-obj.shift-num
                    .
            end.
            assign
                ub.shift-param.prc-dev-mass   = bf_shift-param.prc-dev-mass
                ub.shift-param.dev-paid-trans = bf_shift-param.dev-paid-trans .
        end.
    end.
end.
else do:
    /* может быть начата произвольная смена */
    &if defined(BachMode) eq 0
&then
    run gbl/shift.w (
                    input parparentproc
                  , input p-curr-obj-type
                  , input p-curr-obj-code
                    ,  input-output s-date /* дата начала смены для документа */
                  , input-output e-date
                    , input-output s-time /* время начала смены для документа */
                  , input-output e-time
                    , input-output s-num  /* порядок смены для документа */
                    , input-output s-name /* номер смены для документа */
                    , input ""
                    , output v-cancel
                ) no-error.
    if error-status:error then do:
      run put-mes(yes ,"Ошибка ввода даты, времени или номера для новой смены.",yes,return-value).
          
            undo, return error .
    end.
 &else
 { gbl/curobjdt.i p-curr-obj-type p-curr-obj-code s-date }
 find last open-shift where
           open-shift.obj-type = p-curr-obj-type and
           open-shift.obj-code = p-curr-obj-code and
           open-shift.shift-date = today
          use-index pi no-error.  
 s-num  = (if available open-shift then open-shift.shift-num else 0) + 1.
 s-name = "11".
 s-time = time.
 e-time = time.
    &endif
    if v-cancel = yes
    then do:
        undo, return.
    end.
end.

if not mBachMode 
then do:
glog = no.
message
  "Начать новую смену по" p-curr-obj-type p-curr-obj-code skip
  "Дата начала смены:" s-date skip
  "Время начала смены:" string( s-time, "hh:mm" ) skip
  "Номер смены:" s-name skip
  "Порядок смены" s-num "?"
view-as alert-box question buttons OK-Cancel update glog.
end.
else
   glog = yes.
if not glog
then do:
  return error.
end.
/* пытаемся найти смену с такими параметрами */
find first buf_shift-obj
     where buf_shift-obj.obj-type   = p-curr-obj-type
       and buf_shift-obj.obj-code   = p-curr-obj-code
       and buf_shift-obj.shift-date = s-date
       and buf_shift-obj.shift-num  = s-num
no-error.
if available buf_shift-obj then do:
  case buf_shift-obj.status_:
    when {&sht-expected} then do:
      /* OK */
    end.
    when {&sht-current} then do:
      run put-mes(no ,substitute("Смена уже открыта.~nДата начала смены: &1~nНомер смены: &2~nПорядок смены: &3~n" 
                             ,s-date
                             ,s-name
                             ,s-num)  
                             
  ),no,"").
  
      
      return error.
    end.
    when {&sht-closed} then do:
      run put-mes(no ,substitute("Смена уже закрыта.~nДата начала смены: &1~nНомер смены: &2~nПорядок смены: &3~n" 
                             ,s-date
                             ,s-name
                             ,s-num)  
                             
  ),no,"").
      return error.
    end.
    otherwise do:
      run put-mes(no ,substitute("Неизвестный статус смены: &1~nДата начала смены: &2~nНомер смены: &3~nПорядок смены: &4~n" 
                             ,buf_shift-obj.status_
                             ,s-date
                             ,s-name
                             ,s-num)  
                             
  ),no,"").
      return error.
    end.
  end case.
end.

/* находим последнюю закрытую смену */
find last closed-shift where
          closed-shift.obj-type = p-curr-obj-type and
          closed-shift.obj-code = p-curr-obj-code and
          closed-shift.status_ = {&sht-closed}
          use-index pi no-error.
if not available closed-shift and
   not is-super then do:
           run put-mes(no ,substitute("Не найдена закрытая смена.~nНевозможно начать новую смену.~nОбъект: &1 &2"
                             ,p-curr-obj-type
                             ,p-curr-obj-code
                             
  ),no,"").
     
  return error.
end.

/* проверяем дату и номер открываемой смены */
if available closed-shift then do:
  /* проверяем, что закрывал другой пользователь */
  if closed-shift.close-id = v-cntxt-userid and
    not is-super then do:
      run put-mes(no ,substitute("Предыдущая смена закрыта пользователем: &1 Новая смена должна быть открыта другим пользователем."
                             ,v-cntxt-userid
                            
                             
  ),no,"").
    return error.
  end.
  if s-date = closed-shift.shift-date then do:
    if s-num <> closed-shift.shift-num + 1 then do:
      /* номера в одном дне не подряд */
      run put-mes(no ,substitute("Последняя закрытая смена:&1 Порядок: &2~nНовая смена должна иметь порядок на 1 больше, или относиться к следующему дню."
                             ,closed-shift.shift-date
                             ,closed-shift.shift-num
                            
                             
  ),no,"").
        return error.
    end.
  end.
  if (s-date - closed-shift.shift-date) > 1 then do:
    /* дни не подряд */
    if not mbachMode
    then do:
      glog = no .
    
    message
      "Последняя закрытая смена:" closed-shift.shift-date "Порядок:" closed-shift.shift-num skip
      "Последняя смена закрыта не вчера." skip
      "Открыть новую смену" s-date "Номер:" s-name "Порядок:" s-num "?" skip
      view-as alert-box question buttons yes-no update glog.
    end.
    else  
       glog = yes.
    if not glog or
       not is-super then
      return error.
  end.
  if s-date > closed-shift.shift-date then do:
    if s-num <> 1 then do:
      /* новый день не с 1-й смены */
      run put-mes(no ,substitute("Последняя закрытая смена:&1 Порядок: &2~nПоследняя смена закрыта не сегодня.~nНовая смена должна иметь порядок 1."
                             ,closed-shift.shift-date
                             ,closed-shift.shift-num
                            
                             
  ),no,"").
      return error.
    end.
  end.
end.
if s-date > v-sys-date then do:
  run put-mes(no ,substitute("Дата смены &1~nДата на сервере &2~n Дата смены не может быть больше даты на сервере"
                             ,s-date
                             ,v-sys-date
                               
                             
  ),no,"").
   return error.
end.
if s-date < v-sys-date - 10 and
   is-super = no then do:
   run put-mes(no ,substitute("Дата смены &1~nДата на сервере &2~n Разница ~nЭта разница должна быть меньше 10 дней!"
                             ,s-date
                             ,v-sys-date
                             ,v-sys-date - s-date  
                             
  ),no,"").
   return error.
end.

if not mBachMode 
then do:
/* проверяем кассовые запреты */
    run str/dskshtop.p (
                     input parparentproc
                    ,input no /*silent*/
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input s-date
                    ,input s-num
        ,input s-name
                    ) no-error.
    if error-status :error then do:
      run put-mes(yes ,"Ошибка при проверке кассовых запретов",yes,return-value).
      return error.
    end.
end.
if varobj-date - s-date > 4 then do:
  run put-mes(no ,substitute("Календарная дата объекта &1~nСменная дата &2 ~nРазница &3~nРазница должна составлять не более 4 дней."
                             ,varobj-date
                             ,s-date
                             ,v-sys-date - s-date  
                             
  ),no,"").
  
end.
if varobj-date < s-date then do:
   message
        "Календарная дата объекта " varobj-date
   skip "Сменная дата " s-date
   skip "Календарная дата должна быть не меньше сменной даты."
   skip "Будем приравнивать календарную дату к сменной?"
   view-as alert-box question buttons yes-no update glog.
   if glog = no then return error.
                 else assign varupd-obj-date = yes.
end.
/*На данный момент (16.12.05) номер смены может быть только integer*/
define variable vardata-valid as logical no-undo.
define variable varmessage    as character no-undo.
run integerm in this-procedure (
    input  s-name,
    input  no,
    input  no,
    output s-name-int,
    output vardata-valid,
    output varmessage ) no-error.
if error-status:error or
   vardata-valid <> yes then do:
     run put-mes(no ,"Ошибка при заведении номера смены. ",yes,varmessage).
 return error.
end.
if s-name-int < 1 then do:
  run put-mes(no ,"Номер смены может быть только положительным целым числом.",no,"").
  return error.
end.
for each bf-trb_shift-obj where bf-trb_shift-obj.obj-type    = p-curr-obj-type and
                                bf-trb_shift-obj.obj-code    = p-curr-obj-code and
                                bf-trb_shift-obj.shift-date  = s-date          and
                                bf-trb_shift-obj.shift-name  = s-name          and
                                bf-trb_shift-obj.status_    <> {&sht-expected} on error undo, return error return-value :
 run put-mes(no ,substitute("Запрещено добавлять смены с одним номером в одном сменном дне.~nНа объекте &1 &2 есть смена:~nДата смены &3~nПорядок смены &4~nНомер смены &5" 
                             ,bf-trb_shift-obj.obj-type
                             ,bf-trb_shift-obj.obj-code
                             ,bf-trb_shift-obj.shift-date
                             ,bf-trb_shift-obj.shift-num 
                             ,bf-trb_shift-obj.shift-name 
                             
  ),no,"").                                 
  return error.
end.

define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-param-type            as character no-undo .

run adm/shattri.p ( input "get":U
                  , input  '':u
                  , input  0
                  , input  {&attr-obj-date}
                  , input  {&attr-obj-date_newordsh}
                  , output v-value-character
                  , output v-value-date
                  , output v-value-decimal
                  , output v-value-integer
                  , output v-value-logical
                  , output v-param-type
                  , input-output table-handle v-tth
                  ) no-error .
if error-status :error then do:
   /* параметр может быть не задан */
   assign
      v-value-logical = FALSE
   .
end.

if v-value-logical then do:
  for each bf-trb_shift-obj where bf-trb_shift-obj.obj-type    = p-curr-obj-type and
                                  bf-trb_shift-obj.obj-code    = p-curr-obj-code and
                                  bf-trb_shift-obj.shift-date  = s-date          and
                                  bf-trb_shift-obj.shift-name  > s-name          on error undo, return error return-value :
      run put-mes(no ,substitute("По настройкам конфигурации (newordsh) вам запрещено добавлять смены с меньшим номером после смены с большим номером в одном сменном дне.~nНа объекте &1 &2 есть смена:~nДата смены &3~nПорядок смены &4~nНомер смены &5" 
                             ,bf-trb_shift-obj.obj-type
                             ,bf-trb_shift-obj.obj-code
                             ,bf-trb_shift-obj.shift-date
                             ,bf-trb_shift-obj.shift-num 
                             ,bf-trb_shift-obj.shift-name 
                             
  ),no,""). 
    return error.
  end.
end.

start-shift:
do transaction on error undo start-shift, return on stop undo start-shift, return:
  if not available buf_shift-obj then do:

    create buf_shift-obj.
    assign
      buf_shift-obj.host-code     = v-host-code
      buf_shift-obj.obj-type      = p-curr-obj-type
      buf_shift-obj.obj-code      = p-curr-obj-code
      buf_shift-obj.shift-date    = s-date
      buf_shift-obj.shift-num     = s-num
      buf_shift-obj.shift-name    = s-name
      buf_shift-obj.open-date     = s-date
    .
  end.
  assign
    buf_shift-obj.status_ = {&sht-current}
    buf_shift-obj.open-sys-date = v-sys-date
    buf_shift-obj.open-sys-time = v-sys-time
    buf_shift-obj.open-time     = s-time
  .
  if varupd-obj-date = yes then do:
     { gbl/objdtset.i
       p-curr-obj-type
       p-curr-obj-code
       s-date
       no-error
     }
     if error-status:error then do:
       run put-mes(no ,"Ошибка при установке календарной даты.",no,"").
        return error.
     end.
  end.
end. /*end*/
if not mbachMode
then
    message
      "Новая смена открыта."
    view-as alert-box.
end.
mOk =yes.
&if defined(BachMode) eq 0
&then
run ref/shftpers.w ( INPUT parparentproc
                   , INPUT p-curr-obj-type
                   , INPUT p-curr-obj-code
                   , INPUT s-date
                   , INPUT s-num
                   , INPUT "b-add,b-add-next"
                   , INPUT {&obj-shift-open}) no-error.
&endif