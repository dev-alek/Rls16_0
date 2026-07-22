/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.sobj.sType:  
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Типы s.". 
  
{ibs/th/gbl/TypeDef.i tt-type} 
{ibs/th/gbl/TypeDef.i ttTypeOut}
{cmp\str-glbl.i class }  
{cmp\r-page-pre.i}

{ibs/th/gbl/type.i
    &NameType = SelectObject
    &ListType = "Все по фирме,Текущий,Выборочно,Все"
    &ListTypeChar = "{&bef-obj-firm},{&bef-obj-currency},{&bef-obj-choice},{&bef-obj-all}"
}

{ibs/th/gbl/type.i
    &NameType = RadioTask
    &ListType = "Календарные даты,Сменные сутки,Сменные сутки и порядок,По сменам"
    
}

{ibs/th/gbl/type.i
    &NameType = SelectGood
    &ListType = "Все,Группы товаров,Производители,Выборочно,Один,Хранимый список,Гр. товаров + Производители"
}

{ibs/th/gbl/type.i
    &NameType = RadioSchet
    &ListType = "Все по фирме,Своей фирмы,Выборочно,Один,Все {&abbr_rublevye},Все валютные,По валюте"
    
}

/* &glob radio-period-list-scr '~ */

{ibs/th/gbl/type.i
    &NameType = RadioPeriod
    &ListType = "{&bef-period-type-year-full},{&bef-period-type-year-last-full},{&bef-period-type-halfyear-full},{&bef-period-type-halfyear-last-full},{&bef-period-type-quarter-full},{&bef-period-type-quarter-last-full},{&bef-period-type-month-full},{&bef-period-type-month-last-full},{&bef-period-type-week-full},{&bef-period-type-week-last-full},{&bef-period-type-day-full},{&bef-period-type-yesterday-full},{&bef-period-type-hour-full},{&bef-period-type-hour-last-full},{&bef-period-type-shift-full},{&bef-period-type-shift-last-full}"
    &ListTypeChar = "{&bef-period-type-year},{&bef-period-type-year-last},{&bef-period-type-halfyear},{&bef-period-type-halfyear-last},{&bef-period-type-quarter},{&bef-period-type-quarter-last},{&bef-period-type-month},{&bef-period-type-month-last},{&bef-period-type-week},{&bef-period-type-week-last},{&bef-period-type-day},{&bef-period-type-yesterday},{&bef-period-type-hour},{&bef-period-type-hour-last},{&bef-period-type-shift},{&bef-period-type-shift-last}"
    
}
 
{ibs/th/gbl/type.i
    &NameType = SetPayType
    &ListType = "Продажные цены,Учетные цены,Цены документа"
    
} 

{ibs/th/gbl/type.i
    &NameType = SetValType
    &ListType = "{&abbr_rub},вал,обе валюты"
    
}

{ibs/th/gbl/type.i
    &NameType = RadioCustomer
    &ListType = "Все,Выборочно"
    
}


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
