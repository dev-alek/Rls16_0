using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impnormloss implements ibs.th.bge.1crn.import.iimpsubject:
  define buffer buf_norm-loss for ub.norm-loss.
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable result      as logical no-undo.
    define variable objNormLoss as class   normloss no-undo.
    define variable ii          as integer no-undo .
    objNormLoss = cast (subjectObj, normloss).
    find first buf_norm-loss where buf_norm-loss.type = integer (objNormLoss:type_) and
      buf_norm-loss.clim-grp = objNormLoss:clim-grp and buf_norm-loss.sec-vol1 = objNormLoss:sec-vol1 and buf_norm-loss.sec-vol2 = objNormLoss:sec-vol2 and buf_norm-loss.oil-grp    = objNormLoss:oil-grp
      and buf_norm-loss.position   = string(objNormLoss:position_) and buf_norm-loss.season     = objNormLoss:season_ no-error.
    if available (buf_norm-loss)
      then
    do:
      assign
        buf_norm-loss.oil-grp    = objNormLoss:oil-grp
        buf_norm-loss.position   = string(objNormLoss:position_)
        buf_norm-loss.season     = objNormLoss:season_
        buf_norm-loss.sec-vol1    = objNormLoss:sec-vol1
        buf_norm-loss.sec-vol2    = objNormLoss:sec-vol2
        buf_norm-loss.value-loss = objNormLoss:value_
        .
    end.
    else
    do:
      create ub.norm-loss .
      assign
        ub.norm-loss.id         = next-value( s-norm-loss , ub )
        ub.norm-loss.type       = objNormLoss:type_
        ub.norm-loss.clim-grp   = objNormLoss:clim-grp
        ub.norm-loss.oil-grp    = objNormLoss:oil-grp
        ub.norm-loss.position   = string(objNormLoss:position_)
        ub.norm-loss.season     = objNormLoss:season_
        ub.norm-loss.sec-vol1   = objNormLoss:sec-vol1
        ub.norm-loss.sec-vol2   = objNormLoss:sec-vol2
        ub.norm-loss.value-loss = objNormLoss:value_
        .
        validate ub.norm-loss .
    end.
  end method.
end class.
