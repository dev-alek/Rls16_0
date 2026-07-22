block-level on error undo, throw.
/*

$Revision: aa9af722fe7d, 3049, rls $
$Author: EShklyar $
$Date: Чт май 12 16:29:49 2022 +0300 $
$Workfile: place01.p $
$Archive: ref/place01.p $

Сохранение изменений в карточке складского места

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/23/06
Author: Bakhtadze Natalya
Creation date: 05/23/06

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/


define variable vss-revision    as character no-undo init "$Revision: aa9af722fe7d, 3049, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Чт май 12 16:29:49 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: place01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/place01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке складского места".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ trg/new-bcod.i }

define input-output parameter p-rid      as recid no-undo.
define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pl-code as integer no-undo .
define input parameter p-loc1 as character no-undo .
define input parameter p-loc2 as character no-undo .
define input parameter p-loc3 as character no-undo .
define input parameter p-loc4 as character no-undo .
define input parameter p-pl-name as character no-undo .
define input parameter p-ps as character no-undo .
define input parameter p-add-qnty as decimal no-undo .
define input parameter p-is-meas as logical no-undo .
define input parameter p-max-qnty as decimal no-undo .
define input parameter p-issue-year as integer no-undo .
define input parameter p-start-date as date no-undo .
define input parameter p-chk-max-qnty as logical no-undo .

define variable glog as logical no-undo .
define variable v-mess as character no-undo .
DEFINE VARIABLE v-shift-date as date no-undo.
DEFINE VARIABLE v-shift-num as integer no-undo.
define variable v-shift-name as character no-undo .
define variable v-is-petrol-place as logical no-undo .

define buffer buf_clients for ub.clients.
define buffer main_place for ub.place.

define variable v-dopi  as integer  no-undo .

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.


define variable t-loc as integer no-undo .

if p-loc1 <> '' THEN DO:
	t-loc = integer(p-loc1) NO-ERROR.  
	IF ERROR-STATUS:ERROR THEN DO:
		 MESSAGE "коорд1 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.

	IF t-loc > 999 THEN DO:
		 MESSAGE "коорд1 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.

END.


if p-loc2 <> '' THEN DO:
	t-loc = integer(p-loc2) NO-ERROR.  
	IF ERROR-STATUS:ERROR THEN DO:
		 MESSAGE "коорд2 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.

	IF t-loc > 999 THEN DO:
		 MESSAGE "коорд2 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.

END.

if p-loc3 <> '' THEN DO:
	t-loc = integer(p-loc3) NO-ERROR.  
	IF ERROR-STATUS:ERROR THEN DO:
		 MESSAGE "коорд3 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.
	IF t-loc > 999 THEN DO:
		 MESSAGE "коорд3 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.

END.

if p-loc4 <> '' THEN DO:
	t-loc = integer(p-loc4) NO-ERROR.  
	IF ERROR-STATUS:ERROR THEN DO:
		 MESSAGE "коорд4 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.
	IF t-loc > 999 THEN DO:
		 MESSAGE "коорд4 должна быть числом от 1 до 999 "
         	 view-as alert-box error .
        return error '':u.
        END.

END.



if p-pl-name = '':U
or p-pl-name = ? then do:
  v-mess = "Название складского места не может быть пустым".
  run err-mes in this-procedure ( input-output v-mess).
  undo, return error (if p-silent then v-mess else 'pl-name':U).
end.


if p-obj-type <> {&shop}
and p-obj-type <> {&stock} then do:
  v-mess = substitute("Складские места могут быть только для &1 и &2", {&shop}, {&stock}).
  run err-mes in this-procedure ( input-output v-mess).
  undo, return error (if p-silent then v-mess else '':U).
end.

if p-mode = {&add-def} then do:
  find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code no-error .
  if not available buf_clients then do:
     v-mess = substitute("Не найден объект &1&2 для складского места", p-obj-type, p-obj-code).
     undo, return error (if p-silent then v-mess else '':U).
  end.
end.
main-block:
DO for main_place
on error undo, return error return-value
:
  /*проверка корректности loc1 для топливных резервуаров*/
  v-is-petrol-place = no.
  run trg/plloc1wv.p (
                        input p-obj-type
                      ,input p-obj-code
                      ,input p-pl-code
                      ,input p-loc1
                      ,input p-is-meas
                      ,input-output v-is-petrol-place
                      ,output glog) no-error.
  if error-status:error then do:
    v-mess = error-status:get-message(1) .
    run err-mes in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent then v-mess else '':U).
  end.
  if not glog then do:
    v-mess = return-value .
    run err-mes in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent then v-mess else '':U).
  end.

  CASE p-mode:
    when {&add-def} then do:
       define variable conf-par as character no-undo.
       define variable par-type as character no-undo.
       { gbl/conf-rd.i
             "'is-erpRN'"
             0
             "''"
             0
             "''"
             "''"
             "''"
             NO
             conf-par
             par-type
             no-error
         }
         IF not error-status:error and conf-par = "yes":U 
         then do: 

          find last c-place where c-place.obj-type = p-obj-type
                              and c-place.obj-code = p-obj-code
                              and c-place.pl-code  < 10000000000 /* возьмем для индекса*/
                              no-lock no-error.
          if available c-place 
          then 
             p-pl-code = c-place.pl-code.
          find last place where place.obj-type = p-obj-type
                            and place.obj-code = p-obj-code
                            and place.pl-code  < 10000000000 /* возьмем для индекса*/
                              no-lock no-error.
          if available place 
          then 
             p-pl-code = max(place.pl-code,p-pl-code).
          if p-pl-code < 100000 then p-pl-code = 100000.
          p-pl-code =  p-pl-code +  1.
         end.
         else do:   
           run gen-b-code in this-procedure ( input {&gbl-bc-code}, output p-pl-code) no-error.
            if error-status:error then do:
              if return-value <> '':u then do:
                v-mess = return-value .
                run err-mes in this-procedure ( input-output v-mess).
              end.
              undo main-block, return error (if p-silent then v-mess else 'pl-code').
            end.
         end.
      create main_place.
      assign
      main_place.obj-type = p-obj-type
      main_place.obj-code = p-obj-code
      main_place.pl-code = p-pl-code
      .
    end.
    when {&update} then do:
      FIND FIRST main_place where
                recid(main_place) = p-rid No-ERROR.
      if not available main_place then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись СКЛАДСКОГО МЕСТА - p-rid" p-rid
        view-as alert-box error .
        undo main-block, return error '':u.
      end.
      if main_place.obj-type <>  p-obj-type
      OR main_place.obj-code <>  p-obj-code
      OR main_place.pl-code <>  p-pl-code
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Для уже имеющейся записи нельзя изменить"
        "тип и код объекта" skip
        view-as alert-box ERROR.
        undo main-block, return error '':U.
      end.
      if v-is-petrol-place
      and p-loc1 <> main_place.loc1
      then do:
        { gbl/curshift.i p-obj-type p-obj-code v-shift-date v-shift-num v-shift-name }
        if v-shift-date <> ? then do:
           v-mess = substitute("Нельзя менять КООРД1 для резервуара: открыта смена на &1&2", p-obj-type, p-obj-code).
           run err-mes in this-procedure ( input-output v-mess).
           undo main-block, return error (if p-silent then v-mess else 'loc1').
        end.
      end.
    end. /*update*/
  END CASE.
  assign
  main_place.loc1   = p-loc1
  main_place.loc2   = p-loc2
  main_place.loc3   = p-loc3
  main_place.loc4   = p-loc4
  main_place.pl-name   = p-pl-name
  main_place.ps     = p-ps
  main_place.add-qnty = p-add-qnty
  main_place.is-meas = p-is-meas
  main_place.max-qnty = p-max-qnty
  main_place.issue-year  = p-issue-year
  main_place.start-date  = p-start-date
  main_place.chk-max-qnty = p-chk-max-qnty
  p-rid = recid(main_place)
  .
  release main_place no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранении СКЛАДСКОГО МЕСТА&1&2&1&3", {&new-line}, return-value, error-status:get-message(1)).
    run err-mes in this-procedure ( input-output v-mess).
    undo main-block, return error v-mess.
  end.
end. /*doe*/

procedure err-mes :
define input-output parameter p-mess as character no-undo .

  do
  on error undo, return error
  :
    if not p-silent then do:
      message
      p-mess
      view-as alert-box error.
    end.
    assign
    p-mess = substitute("&1", p-mess).
  end.

end procedure. /* err-mes */