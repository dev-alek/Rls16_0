block-level on error undo, throw.
/*

$Revision: 498238e333a5, 491, rls $
$Author: SSlivenko $
$Date: Sun Feb 28 19:23:10 2016 +0400 $
$Workfile: trn-grfp.p $
$Archive: str/trn-grfp.p $

Стандартный граф переходов складских документов по параметрам

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06

ГРАФ ПЕРЕХОДОВ ОПИСАН В ФАЙЛЕ trn-graf.p


*/

define input  parameter pardoc-type       like ub.trn-doc.doc-type     no-undo. /*тип документа*/
define input  parameter parext-doc-type   like ub.trn-doc.ext-doc-type no-undo. /*расширенный тип документа*/
define input  parameter parstatus-current like ub.trn-doc.status_      no-undo. /*статус документа*/
define input  parameter parflag-current   like ub.trn-doc.flag_        no-undo. /*флаг документа*/
define input  parameter parinternal       like ub.trn-doc.internal     no-undo. /*внутренний*/
define input  parameter parmode           as   character               no-undo. /*режим обработки документа*/
define input  parameter parcur-db-num     like ub.db.db-num            no-undo. /*БД на которой работает*/
define input  parameter pardoc-db-num     like ub.trn-doc.cr-db-num    no-undo. /*БД на которой документ был создан*/
define input  parameter parcur-db-name    like ub.db.db-name           no-undo. /*БД на которой работает*/
define input  parameter pardb-num         like ub.db.db-num            no-undo. /*БД документа*/
define input  parameter pardb-name        like ub.db.db-name           no-undo. /*БД документа*/
define input  parameter parobj-type       like ub.clients.obj-type     no-undo. /*объект*/
define input  parameter parobj-code       like ub.clients.obj-code     no-undo.
define input  parameter paractive         like ub.store.active         no-undo. /*активный объект*/
define input  parameter parhold-gen       as   logical                 no-undo. /*документ межфирменного перемещения*/
define output parameter parstatus         like ub.trn-doc.status_      no-undo. /*статус в который документ перейдет*/
define output parameter parflag           like ub.trn-doc.flag_        no-undo. /*флаг в который документ перейдет*/
define output parameter parcopystatus     like ub.trn-doc.status_      no-undo. /*статус в который документ будет скопирован*/
define output parameter parcopyflag       like ub.trn-doc.flag_        no-undo. /*флаг в который документ будет скопирован*/
def var vss-revision    as character no-undo init "$Revision: 498238e333a5, 491, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Sun Feb 28 19:23:10 2016 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: trn-grfp.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/trn-grfp.p $":U .
def var vss-description as character no-undo init "Стандартный граф переходов складских документов по параметрам".
{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,pardoc-type,parext-doc-type,parstatus-current,parflag-current,parinternal,parmode,parcur-db-num,pardoc-db-num),substitute('&1|&2|&3|&4|&5|&6|&7':u,parcur-db-name,pardb-num,pardb-name,parobj-type,parobj-code,paractive,parhold-gen))"}
{ cmp/str-glbl.i }

{ str/chk-tdb.i }
assign
  parcopystatus = ?
  parcopyflag   = ?.
{ str/trn-grfp.i
&ext-inc-inq-minus    = " run ext-inc-inq-minus    . "
&ext-inc-inq-plus     = " run ext-inc-inq-plus     . "
&ext-inc-wayb-minus   = " run ext-inc-wayb-minus   . "
&ext-inc-wayb-plus    = " run ext-inc-wayb-plus    . "
&ext-inc-fact         = " run ext-inc-fact         . "
&ext-exp-inq-minus    = " run ext-exp-inq-minus    . "
&ext-exp-inq-plus     = " run ext-exp-inq-plus     . "
&ext-exp-wayb-minus   = " run ext-exp-wayb-minus   . "
&ext-exp-wayb-plus    = " run ext-exp-wayb-plus    . "
&ext-exp-perm-plus    = " run ext-exp-perm-plus    . "
&ext-exp-fact         = " run ext-exp-fact         . "
&ext-wroff-inq-minus  = " run ext-wroff-inq-minus  . "
&ext-wroff-inq-plus   = " run ext-wroff-inq-plus   . "
&ext-wroff-wayb-minus = " run ext-wroff-wayb-minus . "
&ext-wroff-wayb-plus  = " run ext-wroff-wayb-plus  . "
&ext-wroff-perm-plus  = " run ext-wroff-perm-plus  . "
&ext-wroff-fact       = " run ext-wroff-fact       . "
&ext-ret-inq-minus    = " run ext-ret-inq-minus    . "
&ext-ret-inq-plus     = " run ext-ret-inq-plus     . "
&ext-ret-wayb-minus   = " run ext-ret-wayb-minus   . "
&ext-ret-wayb-plus    = " run ext-ret-wayb-plus    . "
&ext-ret-perm-plus    = " run ext-ret-perm-plus    . "
&ext-ret-fact         = " run ext-ret-fact         . "
&inv-wayb-minus       = " run inv-wayb-minus       . "
&inv-wayb-plus        = " run inv-wayb-plus        . "
&inv-perm-minus       = " run inv-perm-minus       . "
&inv-perm-plus        = " run inv-perm-plus        . "
&inv-fact             = " run inv-fact             . "
&peresort-wayb        = " run peresort-wayb        . "
&peresort-fact        = " run peresort-fact        . "
&cp-wayb-minus        = " run cp-wayb-minus        . "
&cp-fact              = " run cp-fact              . "
&cmp-wayb-minus       = " run cmp-wayb-minus       . "
&cmp-fact             = " run cmp-fact             . "
&int-inc-inq-minus    = " run int-inc-inq-minus    . "
&int-inc-inq-plus     = " run int-inc-inq-plus     . "
&int-inc-wayb-plus    = " run int-inc-wayb-plus    . "
&int-inc-fact         = " run int-inc-fact         . "
&int-exp-inq-minus    = " run int-exp-inq-minus    . "
&int-exp-inq-plus    =  " run int-exp-inq-plus     . "
&int-exp-wayb-minus   = " run int-exp-wayb-minus   . "
&int-exp-wayb-plus    = " run int-exp-wayb-plus    . "
&int-exp-perm-plus    = " run int-exp-perm-plus    . "
&int-exp-fact         = " run int-exp-fact         . "
&int-ret-wayb-plus    = " run int-ret-wayb-plus    . "
&int-ret-perm-plus    = " run int-ret-perm-plus    . "
&int-ret-fact         = " run int-ret-fact         . "
&obj-exp-wayb-minus   = " run obj-exp-wayb-minus   . "
&obj-exp-wayb-plus    = " run obj-exp-wayb-plus    . "
&obj-int-wayb         = " run obj-int-wayb         . "
}

procedure ext-inc-inq-minus :
/*внеш прих запр-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Запрос открыт.').
  end.
  when {&close-doc} then do:
     assign parstatus = {&inquiry}
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-inq-plus:
/*внеш прих запр+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
       return error substitute ('Нельзя открывать запрос для объекта удаленной базы данных.', parmode, pardoc-type, parstatus-current, parflag-current, (if paractive = yes then 'активного' else 'пассивного'), parobj-type, parobj-code, pardb-name + '(' + string(pardb-num) + ')', parcur-db-name + '(' + string(parcur-db-num) + ')').
    end.
    assign parstatus = {&inquiry}
           parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
       return error substitute ('Нельзя переводить запрос в накладную для объекта удаленной БД.').
    end.
    assign
      parstatus     = {&inquiry}
      parflag       = yes
      parcopystatus = {&wayb}
      parcopyflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-wayb-minus:
/*внеш прих накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  when {&close-fact} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ на факт для объекта удаленной БД').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  otherwise do:
     return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-wayb-plus:
/*внеш прих накл+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    if parcur-db-num <> 0 and
       pardoc-db-num  = 0 then do:
      return error substitute ('Нельзя открыть документ созданный в главной БД.').
    end.
    if parhold-gen = yes then do:
      return error substitute ('Нельзя открыть документ межфирменного перемещения.').
    end.
    assign parstatus = {&wayb}
           parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ на факт для объекта удаленной БД').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  otherwise do:
     return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-fact:
 return error substitute ('Документ закрыт на факт.', pardoc-type, parstatus-current).
end procedure.
procedure ext-exp-inq-minus:
/*внеш расх запр-*/
case parmode:
  when {&open-doc} then do:
      return error substitute("Документ открыт.").
  end.
  when {&close-doc} then do:
     assign parstatus = {&inquiry}
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.

procedure ext-exp-inq-plus:
/*внеш расх запр+*/
case parmode:
  when {&open-doc} then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя открывать запрос для объекта удаленной БД.').
     end.
     assign parstatus = {&inquiry}
            parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя переводить запрос в накладную для объекта удаленной БД.').
    end.
    assign
      parstatus = {&wayb}
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-exp-wayb-minus:
/*внеш расх накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
       return error substitute ('Нельзя закрывать накладную для объекта удаленной БД.', parmode, pardoc-type, parstatus-current, parflag-current, (if paractive = yes then 'активного' else 'пассивного'), parobj-type, parobj-code, pardb-name + '(' + string(pardb-num) + ')', parcur-db-name + '(' + string(parcur-db-num) + ')').
    end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  when {&close-fact} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ на факт для объекта удаленной БД').
    end.
    assign parstatus = {&fact}
           parflag   = true .
  end.

  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-exp-wayb-plus:
/*внеш расх накл+*/
case parmode:
 when {&open-doc} then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя открыть документ для объекта удаленной БД.').
   end.
   assign parstatus = {&wayb}
          parflag   = no.
 end.
 when {&close-doc} then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя закрыть документ для объекта удаленной БД.').
   end.
   assign parstatus = {&permitted}
          parflag   = yes.
 end.
 otherwise do:
   return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
 end.
end case.
end procedure.

procedure ext-exp-perm-plus:
/*внеш расх разр+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ для объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ для объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-exp-fact:
 return error substitute ('Документ закрыт на &2.', pardoc-type, parstatus-current).
end procedure.

procedure ext-wroff-inq-minus:
/*внеш спис запр+*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Запрос открыт.').
  end.
  when {&close-doc} then do:
     assign parstatus = {&inquiry}
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-inq-plus:
/*внеш спис запр+*/
case parmode:
  when {&open-doc} then do:
     if varmain-for-active-remote then do:
        return error substitute ('Нельзя открыть запрос для объекта удаленной БД.').
     end.
     assign parstatus = {&inquiry}
            parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя перевести запрос в накладную для документа объекта удаленной БД').
    end.
    assign
      parstatus = {&wayb}
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-wayb-minus:
/*внеш спис накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-wayb-plus:
/*внеш спис накл+*/
case parmode:
 when {&open-doc} then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя открыть документ удаленной БД.').
   end.
   assign parstatus = {&wayb}
          parflag   = no.
 end.
 when {&close-doc} then do:
   if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
   end.
   assign parstatus = {&permitted}
          parflag   = yes.
 end.
 otherwise do:
   return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
 end.
end case.
end procedure.

procedure ext-wroff-perm-plus:
/*внеш спис разр+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure ext-ret-inq-minus:
/*внеш возвр запр-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Запрос открыт.').
  end.
  when {&close-doc} then do:
     assign parstatus = {&inquiry}
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-inq-plus:
/*внеш возвр запр+*/
case parmode:
  when {&open-doc} then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя открыть запрос объекта удаленной БД.').
     end.
     assign parstatus = {&inquiry}
            parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя перевести запрос в накладную для документа объекта удаленной БД.').
    end.
    assign
      parstatus = {&wayb}
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-wayb-minus:
/*внеш возвр накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    /*
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    */
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-wayb-plus:
/*внеш возвр накл+*/
case parmode:
 when {&open-doc} then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя открыть документ объекта удаленной БД.').
   end.
   if parhold-gen = yes then do:
      return error substitute ('Нельзя открыть документ межфирменного перемещения.').
   end.
   assign parstatus = {&wayb}
          parflag   = no.
 end.
 when {&close-doc} then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
   end.
   assign parstatus = {&permitted}
          parflag   = yes.
 end.
 otherwise do:
   return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
 end.
end case.
end procedure.

procedure ext-ret-perm-plus:
/*внеш возвр разр+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').  end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure inv-wayb-minus:
/*инв накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure inv-wayb-plus:
/*инв накл+*/
case parmode:
  when {&open-doc}   then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = no.
  end.
  when {&close-doc}  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&permitted}
           parflag   = yes.
  end.
  when {&reserv-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя сделать пересортицу для документа объекта удаленной БД.', parmode, pardoc-type, parstatus-current, parflag-current, (if paractive = yes then 'активного' else 'пассивного'), parobj-type, parobj-code, pardb-name + '(' + string(pardb-num) + ')', parcur-db-name + '(' + string(parcur-db-num) + ')').
    end.
    assign parstatus = {&permitted}
           parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure inv-perm-minus:
/*инв разр-*/
case parmode:
  when {&open-doc}   then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя открыть документ объекта удаленной БД.').
     end.
     assign parstatus = {&wayb}
            parflag   = yes.
  end.
  when {&close-doc}  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  when {&reserv-doc} then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя делать резервирование по документу объекта удаленной БД.').
     end.
     assign parstatus = {&permitted}
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure inv-perm-plus:
/*инв разр+*/
case parmode:
  when {&open-doc}   then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  when {&close-doc}  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  when {&reserv-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя делать пересортицу для документа объекта удаленной БД.').
    end.
    assign parstatus = {&permitted}
           parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.

procedure inv-fact:
  return error substitute ('Документ закрыт.').
end procedure.

procedure cmp-wayb-minus:
/*инв накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    assign parstatus = {&fact}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.

procedure cmp-fact:
  return error substitute ('Документ закрыт.').
end procedure.


procedure cp-wayb-minus:
/*инв накл+*/
case parmode:
  when {&open-doc}   then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc}  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure cp-fact:
  return error substitute ('Документ закрыт.').
end procedure.

procedure int-inc-inq-minus:
/*внутр прих запр-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Запрос открыт.').
  end.
  when {&close-doc} then do:
    assign parstatus = {&inquiry}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-inc-inq-plus:
/*внутр прих запр+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть запрос объекта удаленной базы данных.').
    end.
    assign parstatus = {&inquiry}
           parflag   = no.
  end.
  when {&close-doc} then do:
    return error substitute ('Нельзя переводить внутренний приходный запрос в накладную.').
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-inc-wayb-plus:
/*внутр прих накл+*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Нельзя открыть внутреннюю приходную накладную.').
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-inc-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure int-exp-inq-minus:
/*внутр расх запр-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Запрос открыт.').
  end.
  when {&close-doc} then do:
    assign parstatus = {&inquiry}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-inq-plus:
/*внутр расх запр+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть запрос объекта удаленной БД.').
    end.
    assign parstatus = {&inquiry}
           parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть запрос объекта удаленной БД.').
    end.
    assign
      parstatus = {&wayb}
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-wayb-minus:
/*внутр расх накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД').
    end.
    assign parstatus = {&wayb}
           parflag = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-wayb-plus:
/*внутр расх накл+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&permitted}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-perm-plus:
/*внутр расх разр+*/
case parmode:
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД').
    end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-fact:
  return error substitute ('Документ закрыт.', pardoc-type, parstatus-current).
end procedure.
procedure int-ret-wayb-plus:
/*внутр возвр накл+*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Нельзя открыть внутреннюю возвратную накладную.').
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&permitted}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-ret-perm-plus:
/*внутр возвр разр+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = yes.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = ?.
  end.
    otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-ret-fact:
  return error substitute ('Документ закрыт.').
end procedure.

procedure peresort-wayb:
/*пересортица накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    assign parstatus = {&fact}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure peresort-fact:
  return error substitute ('Документ закрыт.').
end procedure.

procedure obj-exp-wayb-minus:
/*внутриобъектный расх накл-*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД').
    end.
    assign parstatus = {&wayb}
           parflag = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure obj-exp-wayb-plus:
/*внутриобъектный расх накл+*/
case parmode:
  when {&open-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&wayb}
           parflag   = no.
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.

procedure obj-int-wayb:
/*внутриобъектный приход накл*/
case parmode:
  when {&open-doc} then do:
    return error substitute ('Документ открыт.').
  end.
  when {&close-doc} then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = {&fact}
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.