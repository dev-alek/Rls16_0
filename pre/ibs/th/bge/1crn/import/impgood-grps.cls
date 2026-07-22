using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.gbl.ggoattr FROM PROPATH.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impgood-grps implements ibs.th.bge.1crn.import.iimpsubject:
  define variable ggoattr as class ggoattr no-undo .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-rec  as recid     no-undo .
    define variable v-mode as character no-undo .
    define buffer buf_gds-grp for ub.gds-grp .
    DEFINE VARIABLE varnode-code          like ub.gds-grp.node-code no-undo .
    DEFINE VARIABLE varupper-code         like ub.gds-grp.upper-code no-undo .
    define variable v-fill-tax-from-upper as LOGICAL no-undo .
    define variable v-perenos             as logical no-undo .
    define variable v-value               as logical no-undo .
    define variable objGood-Grps          as class   good-grps no-undo.
    objGood-Grps = cast (subjectObj, good-grps).
    if objGood-Grps:code_ = "1" then
    do:
      Msg = "Группа товара не должна иметь код равный 1 !!!".
      return false.
    end.
    if objGood-Grps:del-f = 1 then
    do:
      find first buf_gds-grp EXCLUSIVE-LOCK
        where buf_gds-grp.node-code = integer(objGood-Grps:code_)
        no-error.
      if error-status :error
        then
      do:
        Msg = "Нет группы БД, соответствующей значению в списке.".
        return false.
      end.
      run ref/gdsgrp03.p ( input yes
        ,input recid(buf_gds-grp)
        ,input "up"
        ,input "up"
        ) no-error.
      if error-status:error then
      do:
        Msg = return-value.
        return false.
      end.
    end.
    else
    do:
      ASSIGN
        varnode-code  = INTEGER(objGood-Grps:code_)
        varupper-code = if objGood-Grps:upper-code = ? or objGood-Grps:upper-code = "" then 1 else INTEGER (objGood-Grps:upper-code)
        .
      find first buf_gds-grp EXCLUSIVE-LOCK
        where buf_gds-grp.node-code = integer(objGood-Grps:code_)
        no-error.
      if AVAILABLE buf_gds-grp then
      do:
        assign
          v-rec                 = RECID (buf_gds-grp)
          v-mode                = 'ИЗМЕНЕНИЕ':U
          v-fill-tax-from-upper = no
          .
        if varupper-code <> buf_gds-grp.upper-code then
        do:
          assign
            varupper-code = buf_gds-grp.upper-code
            v-perenos     = yes.
          .
        end.
      end.
      else
      do:
        assign
          v-rec                 = ?
          v-mode                = 'ДОБАВЛЕНИЕ':U
          v-fill-tax-from-upper = yes
          .
      end.
      run ref/gdsgrp01.p (
        input v-mode
        ,input yes
        ,input yes
        ,input v-fill-tax-from-upper
        ,input-output  varnode-code
        ,input-output  varupper-code
        ,input objGood-Grps:name_
        ,input 'Не-считать':U
        ,input ""
        ,input objGood-Grps:rn-code
        ,input 'Отключено':U
        ,input 0
        ,output v-rec
        ) no-error .
      if error-status:error then
      do:
        Msg = return-value.
        return false.
      end.
      else
      do:
        ggoattr = new ggoattr ().
        if objGood-Grps:r-mat = 1 then
        do:
          ggoattr:ggoattr-write(
            varnode-code
            ,0
            ,""
            ,0
            ,'no-inc-auto-rep':U
            ,"yes"
            ).
        end.
        else
        do:
          ggoattr:ggoattr-delete(
            varnode-code
            ,0
            ,""
            ,0
            ,'no-inc-auto-rep':U
            ,v-value
            ).
        end.
define var old_val as character no-undo.
define var old_tipe as character no-undo.
ggoattr:ggoattr-value(varnode-code
            ,0
            ,""
            ,0
            ,'no-inc-auto-rep':U
            ,output old_val
                        ,output old_tipe
            ).
        if objGood-Grps:Prohibition-sale = 1 or objGood-Grps:r-mat = 1 then
        do:
          ggoattr:ggoattr-write(
            varnode-code
            ,0
            ,""
            ,0
            ,'ban-sales-via-cd':U
            ,"yes"
            ).
          old_tipe = "yes".
        end.
        else
        do:
          ggoattr:ggoattr-delete(
            varnode-code
            ,0
            ,""
            ,0
            ,'ban-sales-via-cd':U
            ,v-value
            ).
            old_tipe = ?.
end.
        if  old_tipe <> old_val then do:
    define variable mImp2CdH as handle no-undo.
    run str/imp2cdgeth.p(output mImp2CdH).
        for each ub.goods no-lock where ub.goods.grp-code = varnode-code:
           run fill-g-list in mImp2CdH  ( input ub.goods.gds-code, input ?, input ?).
        END.
    END.
      end.
    end.
  end method.
end class.
