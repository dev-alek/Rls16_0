using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.promo.promoType:
define variable vss-revision    as character no-undo initial "$Revision: 38e7c64866ed, 3182, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:25 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promoType.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoType.cls $":U .
define variable vss-description as character no-undo initial "Типы для акций.".
 define temp-table tt-type
    field list  as character
    field item as character
    field code  as integer
 index  item list item
 index  code list code
 .
 define temp-table ttTypeOut
    field list  as character
    field item as character
    field code  as integer
 index  item list item
 index  code list code
 .
CONSTRUCTOR PUBLIC promoType(  ):
    TypeDiscontrefresh().
    methodCalcrefresh().
    typecondrefresh().
    Status_refresh().
end.
define property TypeDiscontListAll as character init "Временная скидка,Промо-набор,Карта Visa" no-undo
get.
define property TypeDiscontList    as character  no-undo
    get():
       return if TypeDiscontList = ""
              then TypeDiscontListAll
              else TypeDiscontList.
    end.
    private set.
 method public void TypeDiscontrefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "TypeDiscont" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(TypeDiscontList):
         create tt-type.
         assign
            tt-type.list  = "TypeDiscont"
            tt-type.item  = entry(vi,TypeDiscontList)
            tt-type.code  = lookup (tt-type.item, TypeDiscontListAll) - 0
         .
    end.
end.
method public character TypeDiscontLbl (intSts as integer ):
    return typeLbl("TypeDiscont",intSts).
end.
method public integer TypeDiscontInt (charSts as character):
    return typeInt("TypeDiscont",charSts).
end.
define property methodCalcListAll as character init "Скидка процентом,Абсолютная (скидка суммой от цены),Скидка количеством,Скидка процентом за количество,Фиксированная цена,Выдача сообщения,Подарок" no-undo
get.
define property methodCalcList    as character  no-undo
    get():
       return if methodCalcList = ""
              then methodCalcListAll
              else methodCalcList.
    end.
    private set.
 method public void methodCalcrefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "methodCalc" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(methodCalcList):
         create tt-type.
         assign
            tt-type.list  = "methodCalc"
            tt-type.item  = entry(vi,methodCalcList)
            tt-type.code  = lookup (tt-type.item, methodCalcListAll) - 0
         .
    end.
end.
method public character methodCalcLbl (intSts as integer ):
    return typeLbl("methodCalc",intSts).
end.
method public integer methodCalcInt (charSts as character):
    return typeInt("methodCalc",charSts).
end.
define property typecondListAll as character init "Количество по строке,Сумма по строке,Сумма в документе,Скидка по ШК,Скидка по картам лояльности" no-undo
get.
define property typecondList    as character  no-undo
    get():
       return if typecondList = ""
              then typecondListAll
              else typecondList.
    end.
    private set.
 method public void typecondrefresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "typecond" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(typecondList):
         create tt-type.
         assign
            tt-type.list  = "typecond"
            tt-type.item  = entry(vi,typecondList)
            tt-type.code  = lookup (tt-type.item, typecondListAll) - 0
         .
    end.
end.
method public character typecondLbl (intSts as integer ):
    return typeLbl("typecond",intSts).
end.
method public integer typecondInt (charSts as character):
    return typeInt("typecond",charSts).
end.
define property Status_ListAll as character init "Настройки в работе,Активная,Заблокирована" no-undo
get.
define property Status_List    as character  no-undo
    get():
       return if Status_List = ""
              then Status_ListAll
              else Status_List.
    end.
    private set.
 method public void Status_refresh():
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "Status_" :
         delete tt-type.
     end.
     do vi = 1 to num-entries(Status_List):
         create tt-type.
         assign
            tt-type.list  = "Status_"
            tt-type.item  = entry(vi,Status_List)
            tt-type.code  = lookup (tt-type.item, Status_ListAll) - 1
         .
    end.
end.
method public character Status_Lbl (intSts as integer ):
    return typeLbl("Status_",intSts).
end.
method public integer Status_Int (charSts as character):
    return typeInt("Status_",charSts).
end.
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
