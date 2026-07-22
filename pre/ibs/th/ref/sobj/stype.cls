using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.sobj.sType:
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Типы s.".
 define temp-table tt-type
    field list  as character
    field item as character
    field codeint  as integer
    field codeChar  as character
 index  item     list item
 index  codeint  list codeint
 index  codeChar list codeChar
 .
 define temp-table ttTypeOut
    field list  as character
    field item as character
    field codeint  as integer
    field codeChar  as character
 index  item     list item
 index  codeint  list codeint
 index  codeChar list codeChar
 .
define property SelectObjectListAll as character init "Все по фирме,Текущий,Выборочно,Все" no-undo
get.
define property SelectObjectCharall as character init "firm,currency,choice,all" no-undo
get.
define property SelectObjectList    as character  no-undo
    get():
       return if SelectObjectList = ""
              then SelectObjectListAll
              else SelectObjectList.
    end.
    private set(iarg as character):
       SelectObjectList = iarg.
       SelectObjectrefresh().
    end.
 method public void SelectObjectRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "SelectObject" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(SelectObjectList):
         create tt-type.
         assign
            tt-type.list     = "SelectObject".
            tt-type.item     = entry(vi,SelectObjectList).
            tt-type.codeInt  = lookup (tt-type.item, SelectObjectListAll).
            tt-type.codeChar = entry(tt-type.codeInt,SelectObjectCharall).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character SelectObjectLbl (intSts as integer ):
    return typeLbl("SelectObject",intSts).
end.
method public character SelectObjectLbl (charSts as character ):
    return typeLbl("SelectObject",charSts).
end.
method public integer SelectObjectInt (charSts as character):
    return typeInt("SelectObject",charSts).
end.
method public character  SelectObjectchar (charSts as character):
    return typechar("SelectObject",charSts).
end.
method public character  SelectObjectchar (icodeint as integer ):
    return typechar("SelectObject",icodeint).
end.
define property RadioTaskListAll as character init "Календарные даты,Сменные сутки,Сменные сутки и порядок,По сменам" no-undo
get.
define property RadioTaskList    as character  no-undo
    get():
       return if RadioTaskList = ""
              then RadioTaskListAll
              else RadioTaskList.
    end.
    private set(iarg as character):
       RadioTaskList = iarg.
       RadioTaskrefresh().
    end.
 method public void RadioTaskRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "RadioTask" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(RadioTaskList):
         create tt-type.
         assign
            tt-type.list     = "RadioTask".
            tt-type.item     = entry(vi,RadioTaskList).
            tt-type.codeInt  = lookup (tt-type.item, RadioTaskListAll).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character RadioTaskLbl (intSts as integer ):
    return typeLbl("RadioTask",intSts).
end.
method public character RadioTaskLbl (charSts as character ):
    return typeLbl("RadioTask",charSts).
end.
method public integer RadioTaskInt (charSts as character):
    return typeInt("RadioTask",charSts).
end.
method public character  RadioTaskchar (charSts as character):
    return typechar("RadioTask",charSts).
end.
method public character  RadioTaskchar (icodeint as integer ):
    return typechar("RadioTask",icodeint).
end.
define property SelectGoodListAll as character init "Все,Группы товаров,Производители,Выборочно,Один,Хранимый список,Гр. товаров + Производители" no-undo
get.
define property SelectGoodList    as character  no-undo
    get():
       return if SelectGoodList = ""
              then SelectGoodListAll
              else SelectGoodList.
    end.
    private set(iarg as character):
       SelectGoodList = iarg.
       SelectGoodrefresh().
    end.
 method public void SelectGoodRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "SelectGood" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(SelectGoodList):
         create tt-type.
         assign
            tt-type.list     = "SelectGood".
            tt-type.item     = entry(vi,SelectGoodList).
            tt-type.codeInt  = lookup (tt-type.item, SelectGoodListAll).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character SelectGoodLbl (intSts as integer ):
    return typeLbl("SelectGood",intSts).
end.
method public character SelectGoodLbl (charSts as character ):
    return typeLbl("SelectGood",charSts).
end.
method public integer SelectGoodInt (charSts as character):
    return typeInt("SelectGood",charSts).
end.
method public character  SelectGoodchar (charSts as character):
    return typechar("SelectGood",charSts).
end.
method public character  SelectGoodchar (icodeint as integer ):
    return typechar("SelectGood",icodeint).
end.
define property RadioSchetListAll as character init "Все по фирме,Своей фирмы,Выборочно,Один,Все рублевые,Все валютные,По валюте" no-undo
get.
define property RadioSchetList    as character  no-undo
    get():
       return if RadioSchetList = ""
              then RadioSchetListAll
              else RadioSchetList.
    end.
    private set(iarg as character):
       RadioSchetList = iarg.
       RadioSchetrefresh().
    end.
 method public void RadioSchetRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "RadioSchet" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(RadioSchetList):
         create tt-type.
         assign
            tt-type.list     = "RadioSchet".
            tt-type.item     = entry(vi,RadioSchetList).
            tt-type.codeInt  = lookup (tt-type.item, RadioSchetListAll).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character RadioSchetLbl (intSts as integer ):
    return typeLbl("RadioSchet",intSts).
end.
method public character RadioSchetLbl (charSts as character ):
    return typeLbl("RadioSchet",charSts).
end.
method public integer RadioSchetInt (charSts as character):
    return typeInt("RadioSchet",charSts).
end.
method public character  RadioSchetchar (charSts as character):
    return typechar("RadioSchet",charSts).
end.
method public character  RadioSchetchar (icodeint as integer ):
    return typechar("RadioSchet",icodeint).
end.
define property RadioPeriodListAll as character init "Год,Год (прошлый),Полугодие,Полугодие (прошлое),Квартал,Квартал (прошлый),Месяц,Месяц (прошлый),Неделя,Неделя (прошлая),День,Вчера,Час (текущий),Час (прошлый),Смена,Смена (прошлая)" no-undo
get.
define property RadioPeriodCharall as character init "year,year-last,halfyear,halfyear-last,quarter,quarter-last,month,month-last,week,week-last,day,yesterday,hour,hour-last,shift,shift-last" no-undo
get.
define property RadioPeriodList    as character  no-undo
    get():
       return if RadioPeriodList = ""
              then RadioPeriodListAll
              else RadioPeriodList.
    end.
    private set(iarg as character):
       RadioPeriodList = iarg.
       RadioPeriodrefresh().
    end.
 method public void RadioPeriodRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "RadioPeriod" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(RadioPeriodList):
         create tt-type.
         assign
            tt-type.list     = "RadioPeriod".
            tt-type.item     = entry(vi,RadioPeriodList).
            tt-type.codeInt  = lookup (tt-type.item, RadioPeriodListAll).
            tt-type.codeChar = entry(tt-type.codeInt,RadioPeriodCharall).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character RadioPeriodLbl (intSts as integer ):
    return typeLbl("RadioPeriod",intSts).
end.
method public character RadioPeriodLbl (charSts as character ):
    return typeLbl("RadioPeriod",charSts).
end.
method public integer RadioPeriodInt (charSts as character):
    return typeInt("RadioPeriod",charSts).
end.
method public character  RadioPeriodchar (charSts as character):
    return typechar("RadioPeriod",charSts).
end.
method public character  RadioPeriodchar (icodeint as integer ):
    return typechar("RadioPeriod",icodeint).
end.
define property SetPayTypeListAll as character init "Продажные цены,Учетные цены,Цены документа" no-undo
get.
define property SetPayTypeList    as character  no-undo
    get():
       return if SetPayTypeList = ""
              then SetPayTypeListAll
              else SetPayTypeList.
    end.
    private set(iarg as character):
       SetPayTypeList = iarg.
       SetPayTyperefresh().
    end.
 method public void SetPayTypeRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "SetPayType" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(SetPayTypeList):
         create tt-type.
         assign
            tt-type.list     = "SetPayType".
            tt-type.item     = entry(vi,SetPayTypeList).
            tt-type.codeInt  = lookup (tt-type.item, SetPayTypeListAll).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character SetPayTypeLbl (intSts as integer ):
    return typeLbl("SetPayType",intSts).
end.
method public character SetPayTypeLbl (charSts as character ):
    return typeLbl("SetPayType",charSts).
end.
method public integer SetPayTypeInt (charSts as character):
    return typeInt("SetPayType",charSts).
end.
method public character  SetPayTypechar (charSts as character):
    return typechar("SetPayType",charSts).
end.
method public character  SetPayTypechar (icodeint as integer ):
    return typechar("SetPayType",icodeint).
end.
define property SetValTypeListAll as character init "руб,вал,обе валюты" no-undo
get.
define property SetValTypeList    as character  no-undo
    get():
       return if SetValTypeList = ""
              then SetValTypeListAll
              else SetValTypeList.
    end.
    private set(iarg as character):
       SetValTypeList = iarg.
       SetValTyperefresh().
    end.
 method public void SetValTypeRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "SetValType" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(SetValTypeList):
         create tt-type.
         assign
            tt-type.list     = "SetValType".
            tt-type.item     = entry(vi,SetValTypeList).
            tt-type.codeInt  = lookup (tt-type.item, SetValTypeListAll).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character SetValTypeLbl (intSts as integer ):
    return typeLbl("SetValType",intSts).
end.
method public character SetValTypeLbl (charSts as character ):
    return typeLbl("SetValType",charSts).
end.
method public integer SetValTypeInt (charSts as character):
    return typeInt("SetValType",charSts).
end.
method public character  SetValTypechar (charSts as character):
    return typechar("SetValType",charSts).
end.
method public character  SetValTypechar (icodeint as integer ):
    return typechar("SetValType",icodeint).
end.
define property RadioCustomerListAll as character init "Все,Выборочно" no-undo
get.
define property RadioCustomerList    as character  no-undo
    get():
       return if RadioCustomerList = ""
              then RadioCustomerListAll
              else RadioCustomerList.
    end.
    private set(iarg as character):
       RadioCustomerList = iarg.
       RadioCustomerrefresh().
    end.
 method public void RadioCustomerRefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "RadioCustomer" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(RadioCustomerList):
         create tt-type.
         assign
            tt-type.list     = "RadioCustomer".
            tt-type.item     = entry(vi,RadioCustomerList).
            tt-type.codeInt  = lookup (tt-type.item, RadioCustomerListAll).
            tt-type.codeInt = tt-type.codeInt - 0
         .
    end.
end.
method public character RadioCustomerLbl (intSts as integer ):
    return typeLbl("RadioCustomer",intSts).
end.
method public character RadioCustomerLbl (charSts as character ):
    return typeLbl("RadioCustomer",charSts).
end.
method public integer RadioCustomerInt (charSts as character):
    return typeInt("RadioCustomer",charSts).
end.
method public character  RadioCustomerchar (charSts as character):
    return typechar("RadioCustomer",charSts).
end.
method public character  RadioCustomerchar (icodeint as integer ):
    return typechar("RadioCustomer",icodeint).
end.
constructor public sType(  ):
   SelectObjectRefresh().
   RadioTaskRefresh().
   SelectGoodRefresh().
   RadioSchetRefresh().
   RadioPeriodRefresh().
   SetPayTypeRefresh().
   SetValTypeRefresh().
   RadioCustomerRefresh().
end.
method public character typeLbl (ilist as character ,intType as integer ):
    find first tt-type where tt-type.list    eq ilist
                         and tt-type.codeint eq intType
                         no-error.
    return if available tt-type then tt-type.item else ?.
end.
method public character typeLbl (ilist as character ,charType as char ):
    find first tt-type where tt-type.list     eq ilist
                         and tt-type.codechar eq charType
                         no-error.
    return if available tt-type then tt-type.item else ?.
end.
method public integer typeInt (ilist as character ,chartype as character):
    find first tt-type where tt-type.list eq ilist
                         and tt-type.item eq charType
                         no-error.
    return if available tt-type then tt-type.codeint else ?.
end.
method public character  typechar (ilist as character ,chartype as character):
    find first tt-type where tt-type.list eq ilist
                         and tt-type.item eq charType
                         no-error.
    return if available tt-type then tt-type.codechar else ?.
end.
method public character  typechar (ilist as character ,inttype as integer):
    find first tt-type where tt-type.list eq ilist
                         and tt-type.codeint eq inttype
                         no-error.
    return if available tt-type then tt-type.codechar else ?.
end.
method public void  settypelbl (ilist as character ,inttype as integer,iVal as character ):
    find first tt-type where tt-type.list eq ilist
                         and tt-type.codeint eq inttype
                         no-error.
    if available tt-type
    then
      tt-type.item = iVal.
end.
method public void typeTable (ilist as character,output table ttTypeOut ):
    define variable vi as integer  no-undo.
    define buffer tt-type for tt-type.
    for each ttTypeOut:
        delete ttTypeOut.
    end.
    do vi = 1 to num-entries(ilist):
        for each tt-type where tt-type.list eq entry(vi,ilist):
            create ttTypeOut.
            buffer-copy tt-type to ttTypeOut.
        end.
    end.
end.
end class.
