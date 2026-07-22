/*

$Revision: 38e7c64866ed, 3182, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:25 $
$Workfile: promoType.cls $
$Archive: ibs/th/ref/promo/promoType.cls $
 
Типы для акций.

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.promo.promoType:  
define variable vss-revision    as character no-undo initial "$Revision: 38e7c64866ed, 3182, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:25 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promoType.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoType.cls $":U .
define variable vss-description as character no-undo initial "Типы для акций.". 
  
{ibs/th/ref/promo/promoType.def tt-type} 
{ibs/th/ref/promo/promoType.def ttTypeOut}  
CONSTRUCTOR PUBLIC promoType(  ):
    TypeDiscontrefresh().
    methodCalcrefresh().
    typecondrefresh().
    Status_refresh().
end.    
{ibs/th/ref/promo/promotype.i
    &NameType = TypeDiscont
    &ListType = "Временная скидка,Промо-набор,Карта Visa"
}
{ibs/th/ref/promo/promotype.i
    &NameType = methodCalc
    &ListType = "Скидка процентом,Абсолютная (скидка суммой от цены),Скидка количеством,Скидка процентом за количество,Фиксированная цена,Выдача сообщения,Подарок"
}
{ibs/th/ref/promo/promotype.i
    &NameType = typecond
    &ListType = "Количество по строке,Сумма по строке,Сумма в документе,Скидка по ШК,Скидка по картам лояльности"
} 

{ibs/th/ref/promo/promotype.i
    &NameType = Status_
    &ListType = "Настройки в работе,Активная,Заблокирована"
    &Shift    =  1
} 
method public character typeLbl (ilist as character ,intType as integer ):
    find first tt-type where tt-type.list eq ilist
                         and tt-type.code eq intType
                         no-error. 
    return if available tt-type then tt-type.item else ?.
end.

method public integer typeInt (ilist as character ,chartype as character):
    find first tt-type where tt-type.list eq ilist
                         and tt-type.item eq charType
                         no-error. 
    return if available tt-type then tt-type.code else ?.
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
 
method public void CangeTypeDiscont (input iTypeDiscont as int):
    if iTypeDiscont eq 1
    then
       methodCalclist = methodCalclistall.
    else if iTypeDiscont eq 3
    then
       methodCalclist = "Подарок".
    else
       methodCalclist = "Скидка процентом,Фиксированная цена".   
    methodCalcRefresh().   
  end.


method public void CangeTypeDiscontAndMethodCalc (input iTypeDiscont as int,input iMethodCalc as int):
    
    if iTypeDiscont = 1
    then do:
        if    iMethodCalc eq 1
           or iMethodCalc eq 6
           or iMethodCalc eq 7
        then   
            TypeCondList = TypeCondListAll.
        else if  iMethodCalc eq 2
        then
            TypeCondList = "Количество по строке,Сумма по строке,Скидка по ШК". 
        else if  iMethodCalc eq 5
        then
            TypeCondList = ",Скидка по ШК,Скидка по картам лояльности". 
        else        
            TypeCondList = "".     
    end.
    else if iTypeDiscont = 3
    then do:
       TypeCondList = "Сумма в документе".
    end.
    else
        TypeCondList = "".      
    TypeCondRefresh().   
  end.
end class.
