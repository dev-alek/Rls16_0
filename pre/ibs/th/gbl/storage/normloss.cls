using Progress.Lang.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.clients.*.
using ibs.th.ref.* from propath.
block-level on error undo, throw.
class ibs.th.gbl.storage.normloss:
  define property Msg as character
    get.
    private set.
  define buffer buf_norm-loss for ub.norm-loss.
  method private void exception( arg as handle, invsdObj as class vsdsub, t-h as handle ):
    invsdObj:setMsg(arg:get-message (1)).
    invsdObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    return.
  end method.
  method private void exception( arg as char ):
    Msg = arg.
    return.
  end method.
  method public void insertDB( input normlossobj as normlosssub  ):
    create buf_norm-loss.
    assign
    no-error.
    if error-status:error
    then do:
      return.
    end.
    setDataStorage(input normlossobj, buffer buf_norm-loss).
    return.
  end method.
  method public void updateDB( input normlossObj as normlosssub  ):
    find first buf_norm-loss where
      buf_norm-loss.id = normlossObj:ID no-error.
    if not available (buf_norm-loss)
    then do:
      return.
    end.
    setDataStorage(input normlossObj, buffer buf_norm-loss).
    release buf_norm-loss.
    return.
  end method.
  method public void getNormLoss ( parTPforNorm as class partpnloss ):
    def buffer bf_norm-loss for ub.norm-loss.
    def buffer bf_pl-attr for ub.place-attr.
    def buffer bf_gds-attr for ub.goods-attr.
    def buffer bf_cli-attr for ub.clients-attr.
    def buffer buf_auto-tank for ub.auto-tank.
    def buffer buf_auto-section for ub.auto-section.
    def var plnlValue as decimal init 0 no-undo.
    def var autonlValue as decimal init 0 no-undo.
    def var climGrp as character no-undo.
    def var dateSeason1 as date no-undo.
    def var dateSeason2 as date no-undo.
    def var season as integer no-undo.
    def var locate as character no-undo.
    find first bf_pl-attr no-lock
      where
            bf_pl-attr.pl-code = parTPforNorm:PlCode
        and bf_pl-attr.obj-type = parTPforNorm:ObjType
        and bf_pl-attr.obj-code = parTPforNorm:ObjCode
        and bf_pl-attr.attr-code = "place-local"
      no-error.
    if available (bf_pl-attr)
    then do:
      if bf_pl-attr.attr-value = "1"
        then locate = "0".
        else locate = "1".
    end.
    else locate = "1".
    find first bf_gds-attr no-lock where
          bf_gds-attr.gds-code = parTPforNorm:GdsCode
      and bf_gds-attr.attr-code = 'group-np':U
      no-error.
    find first bf_cli-attr no-lock where
          bf_cli-attr.obj-type = parTPforNorm:ObjType
      and bf_cli-attr.obj-code = parTPforNorm:ObjCode
      and bf_cli-attr.attr-code = 'cli-clim-grp':U
      no-error.
    if available (bf_cli-attr)
    and (available (bf_gds-attr) or parTPforNorm:GroupNP > "")
    and parTPforNorm:OnDate <> ?
    then do:
      if num-entries (bf_cli-attr.attr-value) = 3
      then do:
        climGrp = entry (1,bf_cli-attr.attr-value).
        dateSeason1 = date (entry (2,bf_cli-attr.attr-value)  + "/" + string (year (parTPforNorm:OnDate))).
        dateSeason2 = date (entry (3,bf_cli-attr.attr-value)  + "/" + string (year (parTPforNorm:OnDate))).
        if dateSeason1 < parTPforNorm:OnDate and parTPforNorm:OnDate < dateSeason2
        then
          season = 0.
        else
          season = 1.
      end.
    end.
    find first bf_norm-loss no-lock where bf_norm-loss.type = 0 and bf_norm-loss.clim-grp = climGrp
        and bf_norm-loss.oil-grp = (if parTPforNorm:GroupNP > "" then parTPforNorm:GroupNP else bf_gds-attr.attr-value)
        and bf_norm-loss.position = locate
        and bf_norm-loss.season = season
        no-error.
    if available (bf_norm-loss)
      then plnlValue = bf_norm-loss.value-loss.
    def var maxlvl as decimal no-undo.
    def var maxlvl1 as decimal no-undo.
    def var maxlvl2 as decimal no-undo.
    for first buf_auto-section no-lock where buf_auto-section.auto-num = parTPforNorm:AutoNum
                                         and buf_auto-section.section-num = integer(parTPforNorm:SecNum)
                                         :
      assign
        maxlvl = buf_auto-section.brutto-qnty / 1000
      no-error.
    end.
    for last bf_norm-loss no-lock where maxlvl > 0 and bf_norm-loss.type = 1 and bf_norm-loss.clim-grp = climGrp
        and bf_norm-loss.oil-grp = (if parTPforNorm:GroupNP > "" then parTPforNorm:GroupNP else bf_gds-attr.attr-value)
        and bf_norm-loss.season = season
        and
        (
          ((bf_norm-loss.sec-vol1) < maxlvl
          and (bf_norm-loss.sec-vol2) >= maxlvl)
          or
          ((bf_norm-loss.sec-vol1) < maxlvl
          and (bf_norm-loss.sec-vol2) = 0)
        )
        by bf_norm-loss.sec-vol1:
        autonlValue = bf_norm-loss.value-loss.
    end.
    finally:
      release bf_pl-attr.
      release bf_cli-attr.
      release bf_gds-attr.
      release buf_norm-loss.
      parTPforNorm:PLNormLoss = plnlValue.
      parTPforNorm:AutoNormLoss = autonlValue.
    end finally.
  end method.
  method public decimal getNormLoss ( input auto-num as char, input in-gds-code as int ):
    def buffer buf_norm-loss for ub.norm-loss.
    def var nlValue as decimal no-undo.
    release buf_norm-loss.
    return nlValue.
  end method.
  method private void setDataStorage (input innormlossObj as class normlosssub, buffer inbf_normloss for ub.norm-loss ):
    assign
      inbf_normloss.id         = innormlossObj:ID
      inbf_normloss.clim-grp   = innormlossObj:ClimGrp
      inbf_normloss.oil-grp    = innormlossObj:OilGrp
      inbf_normloss.position   = innormlossObj:Position_
      inbf_normloss.season     = innormlossObj:Season
      inbf_normloss.sec-vol    = innormlossObj:SecVol
      inbf_normloss.type       = innormlossObj:Type_
      inbf_normloss.value-loss = innormlossObj:ValueLoss
    .
    release inbf_normloss.
  end.
  method private class normlosssub getDataStorage ( buffer inbf_normloss for ub.norm-loss ):
    define variable normlossObj as class normlosssub no-undo.
    normlossObj = new normlosssub ().
    assign
      normlossObj:ID        = inbf_normloss.id
      normlossObj:ClimGrp   = inbf_normloss.clim-grp
      normlossObj:OilGrp    = inbf_normloss.oil-grp
      normlossObj:Position_ = inbf_normloss.position
      normlossObj:Season    = inbf_normloss.season
      normlossObj:SecVol    = inbf_normloss.sec-vol
      normlossObj:Type_     = inbf_normloss.type
      normlossObj:ValueLoss = inbf_normloss.value-loss
    .
    return normlossObj.
  end.
  method private decimal SecVol1 (arg as char):
    return decimal (entry (1, arg, "-")).
  end.
  method private decimal SecVol2 (arg as char):
    if num-entries (arg, "-") = 2
      then return decimal (entry (2, arg, "-")).
      else return ?.
  end.
end class.
