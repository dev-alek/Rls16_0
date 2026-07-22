 
 /*------------------------------------------------------------------------
    File        : rvsinvstr
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : asmorozov
    Created     : Wed Oct 17 00:00:36 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.str.ptrl.*.
block-level on error undo, throw.

class ibs.th.gbl.storage.rvsinvstr: 
  

  define property ListAttr as character init "MeteringErr,Diff,TPNormalPL,TPNormalAuto,NormalWastage"
    get.
  
  
  def private var v-metererrwast as dec no-undo.
  def private var v-natur-wast as dec no-undo.
  def private var v-tp-wast as dec no-undo.
  
  method public void insertDB( input rvsinvsubObj as class rvsinvsub  ):
    
    define buffer bf_rvs-l-attr for ub.rvs-line-attr.

    create bf_rvs-l-attr.
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-code = "MeteringErr".
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:MeteringErr).

    create bf_rvs-l-attr.
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-code = "Diff".
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:Diff).
    
    create bf_rvs-l-attr.
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-code = "TPNormalAuto".
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:TPNormalAuto).

    create bf_rvs-l-attr.
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-code = "TPNormalPL".
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:TPNormalPl).
    
    create bf_rvs-l-attr.
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-code = "NormalWastage".
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:NormalWastage).

    finally:
      SetWast(rvsinvsubObj).
      release bf_rvs-l-attr.
    end finally.
      
  end.
  
  method public void updateDB( input rvsinvsubObj as class rvsinvsub  ):
    
    define buffer bf_rvs-l-attr for ub.rvs-line-attr.

    find first bf_rvs-l-attr exclusive-lock where       
          bf_rvs-l-attr.rvs-code = rvsinvsubObj:RvsCode
      and bf_rvs-l-attr.obj-type = rvsinvsubObj:ObjType
      and bf_rvs-l-attr.obj-code = rvsinvsubObj:ObjCode
      and bf_rvs-l-attr.pl-code = rvsinvsubObj:PlCode
      and bf_rvs-l-attr.gds-code = rvsinvsubObj:GdsCode
      and bf_rvs-l-attr.attr-code = "MeteringErr" 
      no-error.
    
    if not available (bf_rvs-l-attr)
    then do:
      message "rvsinvstr: Ошибка обновления записи. Запись отсутствует." view-as alert-box error.
      return.
    end.
    
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:MeteringErr).

    find first bf_rvs-l-attr exclusive-lock where       
          bf_rvs-l-attr.rvs-code = rvsinvsubObj:RvsCode
      and bf_rvs-l-attr.obj-type = rvsinvsubObj:ObjType
      and bf_rvs-l-attr.obj-code = rvsinvsubObj:ObjCode
      and bf_rvs-l-attr.pl-code = rvsinvsubObj:PlCode
      and bf_rvs-l-attr.gds-code = rvsinvsubObj:GdsCode
      and bf_rvs-l-attr.attr-code = "Diff" 
      no-error.
      
    if not available (bf_rvs-l-attr)
    then do:
      message "rvsinvstr: Ошибка обновления записи. Запись отсутствует." view-as alert-box error.
      return.
    end.
      
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:Diff).
    
    find first bf_rvs-l-attr exclusive-lock where       
          bf_rvs-l-attr.rvs-code = rvsinvsubObj:RvsCode
      and bf_rvs-l-attr.obj-type = rvsinvsubObj:ObjType
      and bf_rvs-l-attr.obj-code = rvsinvsubObj:ObjCode
      and bf_rvs-l-attr.pl-code = rvsinvsubObj:PlCode
      and bf_rvs-l-attr.gds-code = rvsinvsubObj:GdsCode 
      and bf_rvs-l-attr.attr-code = "TPNormalAuto" 
      no-error.
    
    if not available (bf_rvs-l-attr)
    then do:
      message "rvsinvstr: Ошибка обновления записи. Запись отсутствует." view-as alert-box error.
      return.
    end.
    
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:TPNormalAuto).

    find first bf_rvs-l-attr exclusive-lock where       
          bf_rvs-l-attr.rvs-code = rvsinvsubObj:RvsCode
      and bf_rvs-l-attr.obj-type = rvsinvsubObj:ObjType
      and bf_rvs-l-attr.obj-code = rvsinvsubObj:ObjCode
      and bf_rvs-l-attr.pl-code = rvsinvsubObj:PlCode
      and bf_rvs-l-attr.gds-code = rvsinvsubObj:GdsCode 
      and bf_rvs-l-attr.attr-code = "TPNormalPl" 
      no-error.
    
    if not available (bf_rvs-l-attr)
    then do:
      message "rvsinvstr: Ошибка обновления записи. Запись отсутствует." view-as alert-box error.
      return.
    end.
    
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:TPNormalPl).
    
    find first bf_rvs-l-attr exclusive-lock where       
          bf_rvs-l-attr.rvs-code = rvsinvsubObj:RvsCode
      and bf_rvs-l-attr.obj-type = rvsinvsubObj:ObjType
      and bf_rvs-l-attr.obj-code = rvsinvsubObj:ObjCode
      and bf_rvs-l-attr.pl-code = rvsinvsubObj:PlCode
      and bf_rvs-l-attr.gds-code = rvsinvsubObj:GdsCode 
      and bf_rvs-l-attr.attr-code = "NormalWastage"
      no-error.
    
    if not available (bf_rvs-l-attr)
    then do:
      message "rvsinvstr: Ошибка обновления записи. Запись отсутствует." view-as alert-box error.
      return.
    end.
    
    RvsLAttrFillHeadr(rvsinvsubObj, buffer bf_rvs-l-attr).
    bf_rvs-l-attr.attr-value = string (rvsinvsubObj:NormalWastage).
    
    finally:
      SetWast(rvsinvsubObj).
      release bf_rvs-l-attr.
    end finally.
    
        
  end.
  
  method private void RvsLAttrFillHeadr ( input rvsinvsubObj as class rvsinvsub, buffer bf_rvs-l-attr for ub.rvs-line-attr ):
    
      bf_rvs-l-attr.rvs-code = rvsinvsubObj:RvsCode.
      bf_rvs-l-attr.obj-type = rvsinvsubObj:ObjType.
      bf_rvs-l-attr.obj-code = rvsinvsubObj:ObjCode.
      bf_rvs-l-attr.pl-code = rvsinvsubObj:PlCode.
      bf_rvs-l-attr.gds-code = rvsinvsubObj:GdsCode.
    
  end.
  
  method public void DeleteDB ( rvscode as char, objtype as char, objcode as int ):
    
    define buffer bf_rvs-l-attr for ub.rvs-line-attr.
    for each bf_rvs-l-attr exclusive-lock where
            bf_rvs-l-attr.rvs-code = rvscode
        and bf_rvs-l-attr.obj-type = objtype
        and bf_rvs-l-attr.obj-code = objcode
        and lookup (bf_rvs-l-attr.attr-code, ListAttr) > 0
        :
      
      delete bf_rvs-l-attr.
      
    end.
    
  end.
  
  method public void FillSumByOver ( rvsinvsubsObj as class rvsinvsubs  ):
    
    FillSum ( rvsinvsubsObj, false ).
    
  end.
  
  method public void FillSumByDeficit ( rvsinvsubsObj as class rvsinvsubs  ):
  
    FillSum ( rvsinvsubsObj, true ).
    
  end.
  
  method public void FillSum ( rvsinvsubsObj as class rvsinvsubs, isDeficit as logical  ):
    
    define buffer bf_rvs-l-attr for ub.rvs-line-attr.
    define buffer bf_rvs-l-attr-1 for ub.rvs-line-attr.
    
    def var v-metererrnorm as dec no-undo.
    def var v-natur-norm as dec no-undo.
    def var v-tp-norm as dec no-undo.
    
    for each bf_rvs-l-attr no-lock where 
          bf_rvs-l-attr.rvs-code = rvsinvsubsObj:RvsCode
      and bf_rvs-l-attr.obj-type = rvsinvsubsObj:ObjType
      and bf_rvs-l-attr.obj-code = rvsinvsubsObj:ObjCode
      and bf_rvs-l-attr.attr-code = "Diff"
      and ( (not isDeficit and decimal (bf_rvs-l-attr.attr-value) >= 0)  or (isDeficit and decimal (bf_rvs-l-attr.attr-value) < 0))
        :
      
      for each bf_rvs-l-attr-1 no-lock where
            bf_rvs-l-attr-1.rvs-code = rvsinvsubsObj:RvsCode
        and bf_rvs-l-attr-1.obj-type = rvsinvsubsObj:ObjType
        and bf_rvs-l-attr-1.obj-code = rvsinvsubsObj:ObjCode
        and bf_rvs-l-attr-1.gds-code  = bf_rvs-l-attr.gds-code
        and bf_rvs-l-attr-1.pl-code  = bf_rvs-l-attr.pl-code
        and lookup (bf_rvs-l-attr-1.attr-code, ListAttr) > 0:
        
        case bf_rvs-l-attr-1.attr-code:
          when "Diff" then do:
            rvsinvsubsObj:DiffSum = rvsinvsubsObj:DiffSum + decimal (bf_rvs-l-attr-1.attr-value).
            rvsinvsubsObj:IsRvsInvAlg3 = true. /*инвет. сделана по новому алгоритму*/
          end.
          when "TPNormalAuto" then do:
            v-tp-norm = v-tp-norm + decimal (bf_rvs-l-attr-1.attr-value).
          end.
          when "TPNormalPl" then do:
            v-tp-norm = v-tp-norm + decimal (bf_rvs-l-attr-1.attr-value).
          end.
          when "NormalWastage" then do:
            v-natur-norm = decimal (bf_rvs-l-attr-1.attr-value).

          end.
          when "MeteringErr" then do:
            v-metererrnorm = decimal (bf_rvs-l-attr-1.attr-value).
          end.
        end case.
        

      end.
      v-tp-norm = round (v-tp-norm, 0).
       
      SetWast(decimal (bf_rvs-l-attr.attr-value), v-metererrnorm, v-natur-norm, v-tp-norm ).
      rvsinvsubsObj:NaturWastageSum = rvsinvsubsObj:NaturWastageSum + v-natur-wast.
      rvsinvsubsObj:MeteringErrWastSum = rvsinvsubsObj:MeteringErrWastSum + v-metererrwast.
      rvsinvsubsObj:TPWastSum = rvsinvsubsObj:TPWastSum  + v-tp-wast.
      
      v-tp-norm = 0.
      
    end.
    
  end.
  
  method public void SetWast (rvsinvObj as rvsinvsub):
    
    SetWast (rvsinvObj:Diff, rvsinvObj:MeteringErr, rvsinvObj:NormalWastage, rvsinvObj:TPNormal).
    assign
      rvsinvObj:MeterErrWast = v-metererrwast
      rvsinvObj:NaturWast = v-natur-wast
      rvsinvObj:TPWast = round (v-tp-wast, 0).
    .
  end.
  
  method private void SetWast (inDiff as decimal, inMetErrN as decimal, inNaturN as decimal, inTPN as decimal):
    
    if absolute (inDiff) < inMetErrN
      then 
        assign
          v-metererrwast = inDiff
          v-natur-wast = 0
          v-tp-wast = 0
        .
    else
      if absolute (inDiff) < inMetErrN + inNaturN
        then
          assign
            v-metererrwast = inMetErrN
            v-natur-wast = inDiff - inMetErrN
            v-tp-wast = 0
          .
        else
          if absolute (inDiff) < inMetErrN + inNaturN + inTPN
          then
            assign
              v-metererrwast = inMetErrN
              v-natur-wast = inNaturN
              v-tp-wast = inDiff - (inMetErrN + inNaturN)
            .
          else
            assign
              v-metererrwast = inMetErrN
              v-natur-wast = inNaturN
              v-tp-wast = inTPN
            .
  end.
  
  method public logical FillSub ( rvsinvsubObj as class rvsinvsub):
    
    define buffer bf_rvs-l-attr for ub.rvs-line-attr.
    define variable isRvsInv as logical no-undo init false. /*инвентаризация по сверке*/
    for each bf_rvs-l-attr no-lock where 
          bf_rvs-l-attr.rvs-code = rvsinvsubObj:RvsCode
      and bf_rvs-l-attr.obj-type = rvsinvsubObj:ObjType
      and bf_rvs-l-attr.obj-code = rvsinvsubObj:ObjCode
      and bf_rvs-l-attr.gds-code = rvsinvsubObj:GdsCode
      and bf_rvs-l-attr.pl-code = rvsinvsubObj:PlCode
        :
      
      case bf_rvs-l-attr.attr-code:
        when "Diff" then do:
          rvsinvsubObj:Diff = decimal (bf_rvs-l-attr.attr-value).
                      
        end.
        when "TPNormalAuto" then do:
          rvsinvsubObj:TPNormalAuto = decimal (bf_rvs-l-attr.attr-value).
        end.
        when "TPNormalPl" then do:
          rvsinvsubObj:TPNormalPl = decimal (bf_rvs-l-attr.attr-value).
        end.
        when "NormalWastage" then do:
          rvsinvsubObj:NormalWastage = decimal (bf_rvs-l-attr.attr-value).
        end.
        when "MeteringErr" then do:
          rvsinvsubObj:MeteringErr = decimal (bf_rvs-l-attr.attr-value).
        end.
      end case.

      isRvsInv = true.
    end.
    SetWast(rvsinvsubObj).    
    return isRvsInv.
    
  end.
  
  
  /*method public void FillSub ( rvsinvsubObj as class rvsinvsub):
  

  
  end.*/ 
  
  
  method public void CalcSum (RvsInvSubsObj as class rvsinvsubs):
    
    def var ii as int no-undo.
    
    assign
      RvsInvSubsObj:MeteringErrWastSum = 0
      RvsInvSubsObj:TPWastSum = 0
      RvsInvSubsObj:NaturWastageSum = 0
      RvsInvSubsObj:DiffSum = 0
    .
    do ii = 1 to RvsInvSubsObj:iCounter:
      assign
        RvsInvSubsObj:MeteringErrWastSum = RvsInvSubsObj:RvsInvSubCurr:MeterErrWast + RvsInvSubsObj:MeteringErrWastSum
        RvsInvSubsObj:NaturWastageSum = RvsInvSubsObj:RvsInvSubCurr:NaturWast + RvsInvSubsObj:NaturWastageSum
        RvsInvSubsObj:TPWastSum = RvsInvSubsObj:RvsInvSubCurr:TPWast + RvsInvSubsObj:TPWastSum
        RvsInvSubsObj:DiffSum = RvsInvSubsObj:RvsInvSubCurr:Diff + RvsInvSubsObj:DiffSum
      .
    end.

  end method.
  

end class.