/*

$Revision: 41c4ffaaf087, 1404, rls $
$Author: DARuban $
$Date: Thu Jun 28 15:24:34 2018 +0300 $
$Workfile: vsdstatustype.cls $
$Archive: ibs/th/str/mercury/vsdstatustype.cls $

Константы для меркурия


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/
using Progress.Lang.*.
block-level on error undo, throw.

class ibs.th.str.mercury.vsdstatustype: 
  
  define property IsNeedCheck as integer init 0 no-undo
    get.
    
  define property IsErrCheck as integer init 1 no-undo
    get.
    
  define property IsNeedUtilized as integer init 2 no-undo
    get.

  define property IsErrUtilized as integer init 3 no-undo
    get.

  define property IsUtilized as integer init 4 no-undo
    get.

  define property IsSent as integer init 5 no-undo
    get.

  define property StatusList as character init "Требует проверки,Ошибка проверки,К гашению,Ошибка гашения,Погашен,Отправлен" no-undo
    get.
    
  define property VSDTypeList as character init "Входящий,Исходящий,Производственный,Возвратный,Транспортный" no-undo
    get.
  
  define property PendingRepaymentList as character init "4,5" no-undo
    get.

  define property IsNeedCheckLbl as character no-undo
    get:
      IsNeedCheckLbl = entry (1, StatusList).
      return IsNeedCheckLbl. 
    end.
    private set.
    
  define property IsErrCheckLbl as character no-undo
    get:
      IsErrCheckLbl = entry (2, StatusList).
      return IsErrCheckLbl.
    end.
    private set.

  define property IsNeedUtilizedLbl as character no-undo
    get:
      IsNeedUtilizedLbl = entry (3, StatusList).
      return IsNeedUtilizedLbl.
    end.
    private set.

  define property IsErrUtilizedLbl as character no-undo
    get:
      IsErrUtilizedLbl = entry (4, StatusList).
      return IsErrUtilizedLbl.
    end.
    private set.

  define property IsUtilizedLbl as character no-undo
    get:
      IsUtilizedLbl = entry (5, StatusList).
      return IsUtilizedLbl.
    end.
    private set.
    
  define property IsSentLbl as character no-undo
    get:
      IsSentLbl = entry (6, StatusList).
      return IsSentLbl.
    end.
    private set.
    
  define property VSDIn as integer no-undo init 1
    get.
    private set.
    
  define property VSDInLbl as character no-undo
    get:
      VSDInLbl = entry (1, VSDTypeList).
      return VSDInLbl.
    end.
    private set.
    
  define property VSDOut as integer no-undo init 2
    get.
    private set.
    
  define property VSDOutLbl as character no-undo
    get:
      VSDOutLbl = entry (2, VSDTypeList).
      return VSDOutLbl.
    end.
    private set.
  
  define property VSDProduct as integer no-undo init 3
    get.
    private set.
    
  define property VSDProductLbl as character no-undo
    get:
      VSDProductLbl = entry (3, VSDTypeList).
      return VSDProductLbl.
    end.
    private set.
    
  define property VSDReturn as integer no-undo init 4
    get.
    private set.
    
  define property VSDReturnLbl as character no-undo
    get:
      VSDReturnLbl = entry (4, VSDTypeList).
      return VSDReturnLbl.
    end.
    private set.
    
  define property VSDTrans as integer no-undo init 5
    get.
    private set.
    
  define property VSDTransLbl as character no-undo
    get:
      VSDTransLbl = entry (5, VSDTypeList).
      return VSDTransLbl.
    end.
    private set.

  method public character StatusLbl (intSts as integer):
    define variable v-str as character no-undo.
    v-str = entry (intSts + 1, StatusList).
    if v-str = ""
      then v-str = "Неизвестный". 
    return v-str.
  end.

  method public integer StatusInt (charSts as character):
    define variable v-int as integer no-undo.
    v-int = lookup (charSts, StatusList) - 1.
    if v-int <  0
      then v-int = ?. 
    return v-int.
  end.
  
  method public Logical PendingRepayment (intSts as integer):
    define variable v-int as integer no-undo.
    v-int = lookup (string(intSts), PendingRepaymentList).
    return v-int ne 0.
  end.

  method public character VSDTypeLbl (intVSDType as integer):
    define variable v-str as character no-undo.
    v-str = entry (intVSDType, VSDTypeList).
    if v-str = ""
      then v-str = "Неизвестный". 
    return v-str.
  end.

  method public integer VSDTypeInt (charVSDType as character):
    define variable v-int as integer no-undo.
    v-int = lookup (charVSDType, VSDTypeList).
    if v-int <  0
      then v-int = ?. 
    return v-int.
  end.

end class.