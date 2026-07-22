using Progress.Lang.*.
using ibs.th.str.*.
block-level on error undo, throw.
class ibs.th.str.InfoSection:
  define temp-table tt-section no-undo
      field dif     as integer
      field volume1 as decimal
      field deltaV  as decimal
      index pi dif
   .
  define property infoSectionTotal as InfoSectionsTotal no-undo
    get.
    set.
  define property UserMode as logical init false no-undo
    get.
    set (arg as log):
      UserMode = arg.
    end.
  define property CarVol as decimal no-undo
    get.
    set.
  define property Tests as character no-undo
    get.
    set.
  define property CertifFuel as character no-undo
    get.
    set.
  define property NormDoc as character no-undo
    get.
    set.
  define property NumPassport as character no-undo
    get.
    set.
  define property ValidityCertif as character no-undo
    get.
    set.
  define property PassportPlotn as character no-undo
    get.
    set.
  define property DatePovPlotn as date no-undo
    get.
    set.
  define property NumPlotn as character no-undo
    get.
    set.
  define property PassportPlotnTemp as character no-undo
    get.
    set.
  define property DatePovPlotnTemp as date no-undo
    get.
    set.
  define property NumPlotnTemp as character no-undo
    get.
    set.
  define property DateStart as date no-undo
    get.
    set.
  define property TimeStart as integer no-undo
    get.
    set.
  define property DateEnd as date no-undo
    get.
    set.
  define property TimeEnd as integer no-undo
    get.
    set.
  define property TankVol as decimal no-undo
    get.
    set.
  define property TankTemp as decimal no-undo init ?
    get.
    set.
  define property TankWater as decimal no-undo
    get.
    set.
  define property TankDensity as decimal no-undo
    get.
    set.
  define property TankWeight as decimal no-undo
    get.
    set.
  define property TankWeightRvs as decimal no-undo
    get.
    set.
  define property AvgTempRvs as decimal no-undo init ?
    get.
    set.
  define property Mouth as decimal no-undo
    get.
    set.
  define property ABTarir as decimal no-undo init ?
    get.
    set.
  define property Diameter as character no-undo
    get.
    set.
  define property CalibTable as character no-undo init ""
    get.
    set.
  define property PlSiName as character no-undo
    get.
    private set.
  define property PlaceSi as integer no-undo
    get.
    set (a as int):
      def buffer buf_sr-izmerenia for ub.sr-izmerenia.
      find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = a no-error.
      if available buf_sr-izmerenia then do:
        PlaceSi = a.
        PlSiName = buf_sr-izmerenia.sr-model.
      end.
      else do:
      end.
      release buf_sr-izmerenia.
    end.
  define property PlSiNameTemp as character no-undo
    get.
    private set.
  define property PlaceSiTemp as integer no-undo
    get.
    set (a as int):
      def buffer buf_sr-izmerenia for ub.sr-izmerenia.
      find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = a no-error.
      if available buf_sr-izmerenia then do:
        PlaceSiTemp = a.
        PlSiNameTemp = buf_sr-izmerenia.sr-model.
      end.
      else do:
      end.
      release buf_sr-izmerenia.
    end.
  define property TankDensityPomi as decimal no-undo
    get.
    set.
  define property TankVolPomi as decimal no-undo
    get.
    set.
  define property TankVolPomiReal as decimal no-undo
    get.
    set.
  define property TankVolPomiRvs as decimal no-undo
    get.
    set.
  define property DensTemp as decimal no-undo init ?
    get.
    set.
  define property SectionName as character no-undo
    get.
    set (arg as char):
      SectionName = arg.
    end.
  define property DocQnty as decimal no-undo
    get.
    set.
  define property DocDensity as decimal no-undo
    get.
    set.
  define property FactDensity as decimal no-undo
    get.
    set.
  define property FactQnty as decimal no-undo
    get.
    set.
  define property FactKgQnty as decimal no-undo
    get.
    set.
  define property CliQnty as decimal no-undo
    get.
    set.
  define property KolProb as decimal no-undo
    get.
    set.
  define property DateProb as date no-undo
    get.
    set.
  define property HourProb as integer no-undo
    get.
    set.
  define property MinProb as integer no-undo
    get.
    set.
  define property NumPrintProb as character no-undo
    get.
    set.
  define property RnAlgo as character no-undo
    get.
    set.
  define property AccAbsFact as decimal no-undo
    get.
    set.
  define property NaturalLoss as decimal no-undo
    get.
    set.
  define property Deficit as decimal no-undo
    get.
    set.
  define property Excess as decimal no-undo
    get.
    set.
  define property IsKP as logical no-undo init false
    get.
    set.
  define property AccMeth as integer no-undo init ?
    get.
    set.
  define property ListTank as character no-undo
    get.
    set.
  define property TTNTemp as decimal no-undo init ?
    get.
    set.
  define property AccPomi as decimal no-undo
    get.
    set.
  define property AccPomiReal as decimal no-undo
    get.
    set.
  define property AccShip as decimal no-undo
    get.
    set.
  define property TPNormAuto as decimal no-undo
    get.
    set.
  define property TPNormPL as decimal no-undo
    get.
    set.
  define property TPNorm as decimal no-undo
    get:
      return round (TPNormAuto + TPNormPL, 0).
    end.
  define property idSec as integer no-undo
    get.
    set.
  define property Pour as character no-undo
    get.
    set.
  define property Shape as character no-undo
    get.
    set.
  define property DopVolume as decimal no-undo
    get.
    set.
  define property NeckArea as decimal no-undo
    get.
    set.
  define property DocDensST as decimal no-undo
    get.
    set.
  define property PaspDens as decimal no-undo
    get.
    set.
  define property GroupNP as character no-undo
    get.
    set.
  define property Pressure as decimal no-undo
    get.
    set.
  define property DocVolume as decimal no-undo
    get.
    set.
  define property cmom-nb as character no-undo
    get.
    set.
  define property alarm-SGDKK as logical no-undo
    get.
    set.
  define property AukKey as character no-undo
    get.
    set.
  define property KPnoMeas as logical no-undo
    get.
    set.
  define property PokmiWarnings as character no-undo
    get.
    set.
  define property PokmiWarningsRVS as character no-undo
    get.
    set.
  constructor InfoSection (  ):
  end constructor.
  method public void SetCarVol (arg as char):
    def var ii as int no-undo.
    def var varauto-tank-par as character no-undo.
    empty temp-table tt-section.
    find first ub.auto-tank no-lock where ub.auto-tank.auto-num = infoSectionTotal:CarNum no-error.
    if not available (ub.auto-tank)
      then return.
    for each ub.auto-section no-lock where ub.auto-section.auto-num = infoSectionTotal:CarNum and ub.auto-section.section-num = integer (arg) :
      assign
        CarVol =  ub.auto-section.brutto-qnty
        DopVolume =  (if ub.auto-section.add-volume = ? then 0 else ub.auto-section.add-volume)
        Shape = entry (ub.auto-tank.type-neck + 1, "Без горловины,Квадратная/прямоугольная,Эллиптическая,Круглая")
      .
      case ub.auto-tank.type-neck:
      when 0 then do:
        diameter = if ub.auto-section.add-volume = ? then "0" else string(ub.auto-section.add-volume).
        for each ub.auto-section-table  no-lock where
          ub.auto-section-table.auto-num = ub.auto-section.auto-num and ub.auto-section-table.section-num = ub.auto-section.section-num:
          create tt-section.
          assign
            tt-section.dif     = ub.auto-section-table.error  when ub.auto-section-table.error <> ?
            tt-section.volume1 = ub.auto-section-table.volume-error when ub.auto-section-table.volume-error <> ?
            tt-section.deltaV  = ub.auto-section-table.volume-between / 100 when ub.auto-section-table.volume-between  <> ?
          no-error .
          diameter =  diameter + "/" + (if ub.auto-section-table.error = ? then "0" else string(ub.auto-section-table.error)) + chr(6)
                   + (if ub.auto-section-table.volume-error = ? then "0" else string(ub.auto-section-table.volume-error)) + chr(6)
                   + (if ub.auto-section-table.volume-between = ? then "0" else string(ub.auto-section-table.volume-between / 100))  .
        end.
      end.
      when 1 then do:
        diameter = (if ub.auto-section.add-volume = ? then "0" else string(ub.auto-section.add-volume)) + "/"
                 + (if ub.auto-section.section-depth = ? then "0" else string(ub.auto-section.section-depth)) + "/"
                 + (if ub.auto-section.length = ? then "0" else string(ub.auto-section.length)) + "/"
                 + (if ub.auto-section.width = ? then "0" else string(ub.auto-section.width))
          .
      end.
      when 2 then do:
        diameter = (if ub.auto-section.add-volume = ? then "0" else string(ub.auto-section.add-volume)) + "/"
                 + (if ub.auto-section.section-depth = ? then "0" else string(ub.auto-section.section-depth)) + "/"
                 + (if ub.auto-section.diameter-max = ? then "0" else string(ub.auto-section.diameter-max)) + "/"
                 + (if ub.auto-section.diameter-min = ? then "0" else string(ub.auto-section.diameter-min))
          .
      end.
      when 3 then do:
        diameter = (if ub.auto-section.add-volume = ? then "0" else string(ub.auto-section.add-volume)) + "/"
                 + (if ub.auto-section.diameter-max = ? then "0" else string(ub.auto-section.diameter-max)) + "/"
                 + (if ub.auto-section.diameter-min = ? then "0" else string(ub.auto-section.diameter-min)) + "/"
                 + (if ub.auto-section.length = ? then "0" else string(ub.auto-section.length)) + "/"
                 + (if ub.auto-section.section-depth = ? then "0" else string(ub.auto-section.section-depth))
          .
      end.
      end case.
    end.
    release ub.auto-tank.
    release ub.auto-section.
    release ub.auto-tank-attr.
  end.
  method public void FillTTSection (input inPar as char):
    def var ii as int no-undo.
    def var v-section as char no-undo.
    empty temp-table tt-section.
    DopVolume = decimal (entry(1, inPar, "/")) no-error .
    if error-status:error
      then DopVolume = 0.
    if lookup (Shape, "Без горловины,Квадратная/прямоугольная,Эллиптическая,Круглая") = 1
    then do:
      do ii = 2 to num-entries (inPar, "/"):
          v-section = entry(ii, inPar, "/") .
          create tt-section .
          tt-section.dif     = integer(entry (1,v-section,chr(6))) no-error .
          tt-section.volume1 = decimal(entry (2,v-section,chr(6))) no-error .
          tt-section.deltaV  = decimal(entry (3,v-section,chr(6))) no-error .
      end.
    end.
  end.
  method public void GetCalibTable (input DeltaH as decimal) :
    FillTTSection(Diameter) .
    find first tt-section where decimal(tt-section.dif) = (DeltaH / 10) no-error .
    if available tt-section
    then do :
      CalibTable = Substitute("&1=&2", tt-section.dif, tt-section.volume1) + (if tt-section.deltaV > 0 then ("=" + trim(string(tt-section.deltaV, ">>9.9999"))) else "") .
      return .
    end .
    find last tt-section where decimal(tt-section.dif) <= (DeltaH / 10) no-error .
    if available tt-section
    then do :
      CalibTable = Substitute("&1=&2", tt-section.dif, tt-section.volume1) + (if tt-section.deltaV > 0 then ("=" + trim(string(tt-section.deltaV, ">>9.9999"))) else "") .
    end .
    find first tt-section where decimal(tt-section.dif) > (DeltaH / 10) no-error .
    if available tt-section
    then do :
      if DeltaH < 0
      then do :
        CalibTable = Substitute("&1=&2", tt-section.dif, tt-section.volume1) + (if tt-section.deltaV > 0 then ("=" + trim(string(tt-section.deltaV, ">>9.9999"))) else "") + chr(10) + CalibTable .
      end .
      else do :
        CalibTable = CalibTable + chr(10) + Substitute("&1=&2", tt-section.dif, tt-section.volume1) + (if tt-section.deltaV > 0 then ("=" + trim(string(tt-section.deltaV, ">>9.9999"))) else "") .
      end .
    end .
  end .
  method public void SetProp( input inAttrCode as character,  input inAttrValue as character ):
    case inAttrCode:
      when 'car-vol' then
        do:
          assign
            CarVol = decimal (inAttrValue) no-error.
        end.
      when 'tests' then
        do:
          assign
            Tests = inAttrValue no-error.
        end.
      when 'certif-fuel' then
        do:
          assign
            CertifFuel = inAttrValue .
        end.
      when 'norm-doc' then
        do:
          assign
            NormDoc = inAttrValue no-error.
        end.
      when 'num-passport' then
        do:
          assign
            NumPassport = inAttrValue no-error.
        end.
      when 'validity-certif' then
        do:
          assign
            ValidityCertif = inAttrValue no-error.
        end.
      when 'passport-plotn' then
        do:
          assign
            PassportPlotn = inAttrValue no-error.
        end.
      when 'place-si' then
        do:
          assign
            PlaceSi = integer (inAttrValue) no-error.
        end.
      when 'date-pov-plotn' then
        do:
          assign
            DatePovPlotn = date (inAttrValue) no-error.
        end.
      when 'num-plotn' then
        do:
          assign
            NumPlotn = inAttrValue no-error.
        end.
      when 'date-start' then
        do:
          assign
            DateStart = date (inAttrValue) no-error.
        end.
      when 'time-start' then
        do:
          assign
            TimeStart = integer (inAttrValue) no-error.
        end.
      when 'date-end' then
        do:
          assign
            DateEnd = date (inAttrValue) no-error.
        end.
      when 'time-end' then
        do:
          assign
            TimeEnd = integer (inAttrValue) no-error.
        end.
      when 'tank-vol' then
        do:
          assign
            TankVol = decimal (inAttrValue) no-error.
        end.
      when 'tank-temp' then
        do:
          assign
            TankTemp = decimal (inAttrValue) no-error.
        end.
      when 'avg-temp-rvs' then
        do:
          assign
            AvgTempRvs = decimal (inAttrValue) no-error.
        end.
      when 'tank-water' then
        do:
          assign
            TankWater = decimal (inAttrValue) no-error.
        end.
      when 'tank-density' then
        do:
          assign
            TankDensity = decimal (inAttrValue)
          no-error.
        end.
      when 'tank-weight' then
        do:
          assign
            TankWeight = decimal (inAttrValue) no-error.
        end.
      when 'tank-weight-rvs' then
        do:
          assign
            TankWeightRvs = decimal (inAttrValue) no-error.
        end.
      when 'mouth' then
        do:
          assign
            Mouth = decimal (inAttrValue) no-error.
        end.
      when 'a-b-tarir' then
        do:
          assign
            ABTarir = decimal (inAttrValue) no-error.
        end.
      when 'diameter' then
        do:
          assign
            Diameter =  (inAttrValue) no-error.
        end.
      when 'tank-density-pomi' then
        do:
          assign
            TankDensityPomi = decimal (inAttrValue) no-error.
        end.
      when 'tank-vol-pomi' then
        do:
          assign
            TankVolPomi = decimal (inAttrValue) no-error.
        end.
      when 'tank-vol-pomi-real' then
        do:
          assign
            TankVolPomiReal = decimal (inAttrValue) no-error.
        end.
      when 'tank-vol-pomi-rvs' then
        do:
          assign
            TankVolPomiRvs = decimal (inAttrValue) no-error.
        end.
      when 'dens-temp' then
        do:
          assign
            DensTemp = decimal (inAttrValue) no-error.
        end.
      when 'section-name' then
        do:
          assign
            SectionName = inAttrValue no-error.
        end.
      when 'doc-qnty' then
        do:
          assign
            DocQnty = decimal (inAttrValue) no-error.
        end.
      when 'fact-qnty' then
        do:
          assign
            FactQnty = decimal (inAttrValue)
            CliQnty = DocDensity * DocQnty
            FactKgQnty = FactQnty * FactDensity no-error.
        end.
      when 'doc-dens' then
        do:
          assign
            DocDensity = decimal (inAttrValue)
            CliQnty = DocDensity * DocQnty no-error.
        end.
      when 'fact-dens' then
        do:
          assign
            FactDensity = decimal (inAttrValue)
            FactKgQnty = FactQnty * FactDensity no-error.
        end.
      when 'kol-prob' then
        do:
          assign
            KolProb = decimal (inAttrValue) no-error.
        end.
      when 'num-print-prob' then
        do:
          assign
            NumPrintProb = string (inAttrValue) no-error.
        end.
      when 'date-prob' then
        do:
          assign
            DateProb = date (inAttrValue) no-error.
        end.
      when 'hour-prob' then
        do:
          assign
            HourProb = integer (inAttrValue) no-error.
        end.
      when 'min-prob' then
        do:
          assign
            MinProb = integer (inAttrValue) no-error.
        end.
      when 'acc-ship' then
        do:
          assign
            AccShip = decimal (inAttrValue) no-error.
          if error-status:error or inAttrValue = ""
            then AccShip = 0.
        end.
      when 'rn-algo' then
        do:
          assign
            RnAlgo = (inAttrValue) no-error.
        end.
      when 'dop-info' then
        do:
          assign
            AccAbsFact = decimal (entry (1, inAttrValue)) no-error.
            NaturalLoss = decimal (entry (2, inAttrValue)) no-error.
            Deficit = decimal (entry (3, inAttrValue)) no-error.
            if Deficit < 0
              then
                assign
                  Deficit = abs(Deficit)
                  Excess = 0.
              else
                assign
                  Excess = Deficit
                  Deficit = 0.
          if error-status:error or inAttrValue = ""
            then AccAbsFact = ?.
        end.
      when 'is-kp' then
        do:
          assign
            IsKP = logical (inAttrValue) no-error.
          if error-status:error or inAttrValue = "" or IsKP = ?
            then IsKP = no.
        end.
      when 'acc-meth' then
        do:
          assign
            AccMeth = integer (inAttrValue) no-error.
        end.
      when 'list-tank' then
        do:
          assign
            ListTank = inAttrValue no-error.
        end.
      when 'ttn-temp' then
        do:
          assign
            TTNTemp = decimal (inAttrValue) no-error.
        end.
      when 'acc-pomi' then
        do:
          assign
            AccPomi = decimal (inAttrValue) no-error.
        end.
      when 'acc-pomi-real' then
        do:
          assign
            AccPomiReal = decimal (inAttrValue) no-error.
        end.
      when 'tp-norm-auto' then
        do:
          assign
            TPNormAuto = decimal (inAttrValue) no-error.
        end.
      when 'tp-norm-pl' then
        do:
          assign
            TPNormPL = decimal (inAttrValue) no-error.
        end.
      when 'passport-plotn-temp' then
        do:
          assign
            PassportPlotnTemp = inAttrValue no-error.
        end.
      when 'place-si-temp' then
        do:
          assign
            PlaceSiTemp = integer (inAttrValue) no-error.
        end.
      when 'date-pov-plotn-temp' then
        do:
          assign
            DatePovPlotnTemp = date (inAttrValue) no-error.
        end.
      when 'num-plotn-temp' then
        do:
          assign
            NumPlotnTemp = inAttrValue no-error.
        end.
      when 'pour' then
        do:
          assign
            Pour = inAttrValue no-error.
        end.
      when 'shape' then
        do:
          assign
            Shape = inAttrValue no-error.
        end.
      when 'dop-volume' then
        do:
          assign
            DopVolume = decimal (inAttrValue) no-error.
        end.
      when 'pasp-dens' then
        do:
          assign
            PaspDens = decimal (inAttrValue) no-error.
        end.
      when 'doc-dens-st' then
        do:
          assign
            DocDensST = decimal (inAttrValue) no-error.
        end.
      when 'pressure' then
        do:
          assign
            Pressure = decimal (inAttrValue) no-error.
        end.
      when 'group-np' then
        do:
          assign
            GroupNP = inAttrValue no-error.
        end.
      when 'doc-volume' then
        do:
          assign
            DocVolume = decimal (inAttrValue) no-error.
        end.
      when 'cmom-nb' then
        do:
          assign
            cmom-nb = inAttrValue no-error.
        end.
      when 'alarm-SGDKK' then
        do:
          assign
            alarm-SGDKK = logical (inAttrValue) no-error.
          if error-status:error or inAttrValue = "" or alarm-SGDKK = ?
            then alarm-SGDKK = no.
        end.
      when 'aukkey' then
        do:
          assign
            AukKey = inAttrValue no-error.
        end.
      when 'KPnoMeas' then
        do:
          assign
            KPnoMeas = logical (inAttrValue) no-error.
          if error-status:error or inAttrValue = "" or KPnoMeas = ?
            then KPnoMeas = no.
        end.
      when 'pokmi-warnings' then
        do:
          assign
            PokmiWarnings = inAttrValue no-error.
        end.
      when 'pokmi-warnings-rvs' then
        do:
          assign
            PokmiWarningsRVS = inAttrValue no-error.
        end.
    end case.
  end method.
  method public decimal getMouth ( input inABTarir as decimal,  input inArea as decimal ):
  def var v-mouth as decimal no-undo.
  def var v-diff as decimal no-undo.
  def var v-vol2 as decimal no-undo.
  if Shape = entry (1, "Без горловины,Квадратная/прямоугольная,Эллиптическая,Круглая")
  then do:
    if inABTarir = 0
      then v-mouth = 0.
    else do:
      FillTTSection(Diameter) .
      find first tt-section where decimal (tt-section.dif) = decimal (inABTarir) / 10 no-error.
      if available tt-section
      then do :
        v-mouth = tt-section.volume1 .
        return v-mouth.
      end .
      find first tt-section where decimal (tt-section.dif) > decimal (inABTarir) / 10 no-error.
      if error-status:error
      then do:
        return 0.
      end.
      v-vol2 = tt-section.volume1.
      find last tt-section where decimal (tt-section.dif) <= decimal (inABTarir) / 10 no-error.
      if error-status:error
      then do:
        return 0.
      end.
      v-diff = decimal (inABTarir) - decimal (tt-section.dif) * 10.
      v-mouth = tt-section.volume1 + (v-vol2 - tt-section.volume1) / 10 * v-diff.
      return v-mouth.
    end.
  end.
  else do:
    v-mouth = round ((inABTarir) * inArea, 2).
    return v-mouth.
  end.
  finally:
    return v-mouth.
  end.
  end method.
  destructor public InfoSection ( ):
  end destructor.
end class.
