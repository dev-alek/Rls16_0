/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс работы с секциями по топливу.

Автор: Морозов Александр Сергеевич
Дата создания: 09/29/2015
Author: Alexandr Morozov
Creation date: 09/29/2015

*/ 

using Progress.Lang.*.
using ibs.th.str.*.
using ibs.th.gbl.storage.*.
using ibs.th.ref.*.
using ibs.th.gbl.ptrl.par.*.
block-level on error undo, throw.


class ibs.th.str.InfoSectionsTotal: 

{ cmp/str-glbl.i class}
{ gbl/attr-lib.i class}
&global-define list-shape "Без горловины,Квадратная/прямоугольная,Эллиптическая,Круглая"

  define private buffer buf_doc-line  for ub.doc-line.
  define private buffer buf_doc-line-attr for ub.doc-line-attr.
  define private buffer buf_goods  for ub.goods.
  define private buffer buf_trn  for ub.trn-doc.
  
  define stream log-algo.
  define stream outstream.
  
  define private temp-table ttObjInfoSecProp no-undo
    field iSecNum as integer
    field objInfoSecProp as class Progress.Lang.Object
    index pi is primary unique iSecNum .

  define property TrnDocNum as character no-undo
    get.
    private set.

  define property Parentproc as handle no-undo
    get.
    set.
    
  define property Mode as character no-undo
    get.
    private set.    

  define property WasSetting as logical no-undo
    get.
    set.
    
  define property PlChanged as logical no-undo
    get.
    set.

  define property GdsCode as integer no-undo
    get.
    private set.

  define property FlagTrn as logical no-undo
    get.
    set.

  define property Sts as character no-undo
    get.
    set.

  define property SectionNum as integer no-undo
    get.
    private set.

  define property idSecCurr as integer no-undo
    get.
    private set.

  define property InfoSectionCurr as class InfoSection no-undo
    get.
    set.
   
  define property TankWeightTotal as decimal no-undo
    get.
    set.

  define property TankVolTotal as decimal no-undo
    get.
    set.

  define property CarVolTotal as decimal no-undo
    get.
    set.

  define property DocQntyTotal as decimal no-undo
    get.
    set.

  define property CliQntyTotal as decimal no-undo
    get.
    set.

  define property FactQntyTotal as decimal no-undo
    get.
    set.

  define property FactKgQntyTotal as decimal no-undo
    get.
    set.

  define property TankWaterVolTotal as decimal no-undo
    get.
    set.

  define property DocDensityAvg as decimal no-undo
    get.
    set.

  define property DocQntyLine as decimal no-undo
    get.
    set.

  define property DocDensLine as decimal no-undo
    get.
    set.

  define property DocCliLine as decimal no-undo
    get.
    set.

  define property StartRealDate as date no-undo
    get.
    private set.

  define property StartRealTime as integer no-undo
    get.
    private set.

  define property EndRealDate as date no-undo
    get.
    private set.

  define property EndRealTime as integer no-undo
    get.
    private set.

  define property CliQntyInput as logical no-undo
    get.
    set.

  define property DensityInput  as logical no-undo
    get.
    set.

  define property DocQntyInput as logical no-undo
    get.
    set.
    
  define property NormalWastage as decimal no-undo
    get.
    set.

  define property IsRNAlgo as logical no-undo
    get.
    set.
    
  define property PercAcc as decimal no-undo
    get.
    set.

  define property IsActnComm as logical no-undo init false
    get.
    set.

  define property AccShip as decimal no-undo
    get.
    set.    

  define property CarNum as character no-undo
    get.
    set.    

  define property IsFlagKPChg as logical no-undo
    get.
    set.    

  define property RdcDnstvalue as character no-undo
    get.
    set.

  define property ObjType as character no-undo
    get.
    set.
    
  define property ObjCode as integer no-undo
    get.
    set.

  define property ParNl as class partpnloss no-undo
    get.
    set.
    
  define property TPNormPLSum as decimal no-undo
    get.
    set.

  define property TPNormAutoSum as decimal no-undo
    get.
    set.
    
  define property TPNormSum as decimal no-undo
    get.
    set.
    
  define property IsSGDKK as logical no-undo
    get.
    set.
    
  define property IsKP as logical no-undo
    get.
    set.
    
  define property IsKPrvs as logical no-undo
    get.
    set.
    
  define property lRepeatAsi as logical no-undo
    get.
    set.
    
  define property petrol_block-nozzle as logical no-undo
    get.
    set.
    
  define property mRepeatAsi as character no-undo
    get.
    set.

  define property PrtlPropObj as class ptrlprop no-undo
    get.
    private set.

  define property FuelType as character no-undo
    get.
    private set.
    
  define property in-line-handle as widget-handle no-undo
    get.
    set.

  define property TempForPomi as decimal no-undo
    get:
      if PrtlPropObj:ptrlprop-temp-for-pomi = 1
        then return 15.
        else return 20.
    end.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  
  define private variable NLStorage as class normloss no-undo.
  
  
  constructor public InfoSectionsTotal (inTrnDocNum as char, inGdsCode as int, inMode as char):
    
    Mode = inMode.
    
    Initialization (inTrnDocNum, inGdsCode).
    
  end.

  constructor public InfoSectionsTotal ():
    
  end.
  
  method public void Initialization (inTrnDocNum as char, inGdsCode as int):
    
    define variable rdc-dnstvalue as character no-undo.
    define variable rdc-dnsttype as character no-undo.
    define variable v-gds-attr-value as character no-undo .
    define variable v-gds-attr-type  as character no-undo .

    assign
      TrnDocNum = inTrnDocNum
      GdsCode = inGdsCode
    .
    find first buf_trn no-lock where buf_trn.doc-code = TrnDocNum.
    ObjCode = buf_trn.obj-code.
    ObjType = buf_trn.obj-type.

    NLStorage = new normloss ().
    
    Parnl = new partpnloss ().
    PrtlPropObj = ptrlpropproc:GetPropPtrl(ObjType, ObjCode).

    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
      (input  GdsCode
      ,input  {&attr-fuel-type}
      ,output v-gds-attr-value
      ,output v-gds-attr-type
      ) no-error .
    if error-status :error
    then do:
      FuelType = "".
    end.
    else FuelType = v-gds-attr-value.
    run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
    if error-status:error or lookup (FuelType, "metan,propan,lgas") > 0 then 
    do:
      rdc-dnstvalue = "not".
    end.
    RdcDnstvalue = rdc-dnstvalue.
    GetDBAllAttr ().
    CalculateTotal().
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  method public void Initialization (inTrnDocNum as char, inArtic as char, inObjType as char, inObjCode as int):
    
    find first buf_goods no-lock where
                               buf_goods.artic= inArtic
                           and buf_goods.prod-code = inObjCode
                           and buf_goods.prod-type = inObjType no-error.
                           
    Initialization (inTrnDocNum, buf_goods.gds-code).
    
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void GetDBAllAttr():
    
    define variable ii as integer no-undo.
    clearObj().

    find first buf_doc-line-attr where buf_doc-line-attr.doc-code = TrnDocNum 
      and buf_doc-line-attr.gds-code = GdsCode 
      and buf_doc-line-attr.attr-code = "n" no-error.
    
    if available (buf_doc-line-attr)
      then assign SectionNum = integer (buf_doc-line-attr.attr-value).
    else SectionNum = 1.
    
    if available (buf_doc-line-attr) and buf_doc-line-attr.attr-value = '0'  
      then SectionNum = 1.

    do ii = 1 to SectionNum :

      InfoSectionCurr = new InfoSection().
      InfoSectionCurr:infoSectionTotal = this-object.
      
      InfoSectionCurr:idSec = ii.
      
      for each buf_doc-line-attr where buf_doc-line-attr.doc-code = TrnDocNum 
        and buf_doc-line-attr.gds-code = GdsCode
        and not buf_doc-line-attr.attr-code = "n" 
        and (SectionNum = 1 or (num-entries (buf_doc-line-attr.attr-code, {&delim-par}) > 1 and (entry (2, buf_doc-line-attr.attr-code, {&delim-par})) = string (ii) and SectionNum > 1)):
        
        def var attrCode as char no-undo.
        assign
          attrCode = entry (1, buf_doc-line-attr.attr-code, {&delim-par}) no-error.
        if error-status:error then next.
        
        InfoSectionCurr:SetProp (attrCode, buf_doc-line-attr.attr-value).

      end.

      /*if SectionNum = 1
      then do:
        find first buf_goods no-lock where buf_goods.gds-code = GdsCode no-error. 
        find first buf_doc-line no-lock where
                                   buf_doc-line.doc-code = TrnDocNum 
                               and buf_goods.artic= buf_doc-line.artic
                               and buf_goods.prod-code = buf_doc-line.prod-code
                               and buf_goods.prod-type = buf_doc-line.prod-type no-error.
        if available (buf_doc-line) then 
          assign
            InfoSectionCurr:CliQnty = buf_doc-line.cli-qnty
/*            InfoSectionCurr:FactQnty = buf_doc-line.fact-qnty*/
            InfoSectionCurr:DocDensity = buf_doc-line.doc-density
            InfoSectionCurr:DocQnty = buf_doc-line.doc-qnty
/*            InfoSectionCurr:FactDensity = buf_doc-line.fact-density*/
/*            InfoSectionCurr:FactKgQnty = buf_doc-line.fact-density * buf_doc-line.fact-qnty*/
          .
      end.*/
      
      create ttObjInfoSecProp.
      assign
        ttObjInfoSecProp.iSecNum = ii 
        ttObjInfoSecProp.objInfoSecProp = cast (InfoSectionCurr, Progress.Lang.Object).
      
    end.
    CalculateTotal ().


  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void NewSection(  ):

    InfoSectionCurr = new InfoSection().
    assign 
      SectionNum = SectionNum + 1.
    create ttObjInfoSecProp.
    assign
      ttObjInfoSecProp.iSecNum = SectionNum
      ttObjInfoSecProp.objInfoSecProp = InfoSectionCurr
    .
    idSecCurr = SectionNum.
    InfoSectionCurr:idSec = SectionNum.
    InfoSectionCurr:infoSectionTotal = this-object.
    if InfoSectionCurr:AccShip = 0
    or InfoSectionCurr:AccShip = ?
    then
      InfoSectionCurr:AccShip = 0.25.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public class InfoSection GetInfoSectionProp ():
    
    return GetInfoSectionProp (1).
    
  end.

  method public class InfoSection GetInfoSectionProp (inSecNum as integer):
    
    define variable objInfoSec as class InfoSection.
    
    for first ttObjInfoSecProp where ttObjInfoSecProp.iSecNum = inSecNum:
      objInfoSec = cast ( ttObjInfoSecProp.objInfoSecProp, InfoSection ).
      InfoSectionCurr = objInfoSec.
      idSecCurr = inSecNum.
      return objInfoSec.
    end.

  end method.
  
  method public character GetInfoSectionProp (inTankCord1 as char):
    define variable objInfoSec as class InfoSection no-undo.
    define variable listIdSec as character no-undo.
    listIdSec = "".
    for each ttObjInfoSecProp :
      objInfoSec = cast ( ttObjInfoSecProp.objInfoSecProp, InfoSection ).
      InfoSectionCurr = objInfoSec.
      if InfoSectionCurr:ListTank = inTankCord1
      then do:
        listIdSec = listIdSec + {&delim-par} + string (ttObjInfoSecProp.iSecNum).
/*        idSecCurr = ttObjInfoSecProp.iSecNum.*/
      end.  
    end.
    listIdSec = trim (listIdSec, {&delim-par}).
    return listIdSec.
  end method.  
  
  
  

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void DeleteSection( inNum as int  ):
    
    def var ii as integer no-undo.
    define variable objInfoSec as class InfoSection.
        
    find first ttObjInfoSecProp where ttObjInfoSecProp.iSecNum = inNum.
    delete object ttObjInfoSecProp.objInfoSecProp.
    delete ttObjInfoSecProp.
    ii = 0.
    for each ttObjInfoSecProp use-index pi:
      assign
        ii = ii + 1
        ttObjInfoSecProp.iSecNum = ii.
        idSecCurr = ttObjInfoSecProp.iSecNum.
        objInfoSec = cast ( ttObjInfoSecProp.objInfoSecProp, InfoSection ).
        objInfoSec:idSec = ii.
    end.
    SectionNum = SectionNum - 1.


  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void CalculateTotal ():
    
    def var ii as integer no-undo.
    
    assign
      CarVolTotal = 0
      TankVolTotal = 0
      TankWaterVolTotal = 0
      TankWeightTotal = 0
      DocQntyTotal = 0
      CliQntyTotal = 0
      FactQntyTotal = 0
      FactKgQntyTotal = 0
      DocDensityAvg = 0
      EndRealDate = ?
      EndRealTime = ?
      StartRealTime = ?
      StartRealDate = ?
      TPNormPLSum = 0
      TPNormAutoSum = 0
      TPNormSum = 0
    .
    do ii = 1 to SectionNum :
      GetInfoSectionProp (ii).
      if not CliQntyInput
      then do:
        InfoSectionCurr:CliQnty = round(InfoSectionCurr:DocDensity * InfoSectionCurr:DocQnty, 3).
      end.
      else do:
        InfoSectionCurr:DocDensity = InfoSectionCurr:CliQnty / InfoSectionCurr:DocQnty.
      end.
      assign
        CarVolTotal = InfoSectionCurr:CarVol + CarVolTotal
        TankVolTotal = InfoSectionCurr:TankVol + TankVolTotal
        TankWaterVolTotal = InfoSectionCurr:TankWater + TankWaterVolTotal
        TankWeightTotal = InfoSectionCurr:TankWeight + TankWeightTotal
        DocQntyTotal = InfoSectionCurr:DocQnty + DocQntyTotal
        FactQntyTotal = InfoSectionCurr:FactQnty + FactQntyTotal
        FactKgQntyTotal = InfoSectionCurr:FactKgQnty + FactKgQntyTotal
        TPNormPLSum = InfoSectionCurr:TPNormPL + TPNormPLSum
        TPNormAutoSum = InfoSectionCurr:TPNormAuto + TPNormAutoSum
        TPNormSum = InfoSectionCurr:TPNorm + TPNormSum
      .
      CliQntyTotal = InfoSectionCurr:CliQnty + CliQntyTotal.
      if StartRealDate = ? or datetime (InfoSectionCurr:DateStart, InfoSectionCurr:TimeStart) < datetime (StartRealDate, StartRealTime) 
      then do:
        assign
          StartRealTime = InfoSectionCurr:TimeStart
          StartRealDate = InfoSectionCurr:DateStart
        .
      end.
      if EndRealDate = ? or datetime (InfoSectionCurr:DateEnd, InfoSectionCurr:TimeEnd) > datetime (EndRealDate, EndRealTime)
      then do:
        assign
          EndRealTime = InfoSectionCurr:TimeEnd
          EndRealDate = InfoSectionCurr:DateEnd
        .
      end.
    end.
    assign
      CliQntyTotal = round(CliQntyTotal, 3)
      CarVolTotal = round(CarVolTotal, 3)
      TankVolTotal = round(TankVolTotal, 3)
      TankWaterVolTotal = round(TankWaterVolTotal, 3)
      TankWeightTotal = round(TankWeightTotal, 3)
      DocQntyTotal = round(DocQntyTotal, 3)
      FactQntyTotal = round(FactQntyTotal, 3)
      FactKgQntyTotal = round(FactKgQntyTotal, 3)
      TPNormPLSum = round(TPNormPLSum, 3)
      TPNormAutoSum = round(TPNormAutoSum, 3)
      TPNormSum = round(TPNormSum, 3)
    .
    DocDensityAvg = CliQntyTotal / DocQntyTotal .


  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void clearObj ():
    
    release buf_doc-line-attr.
    for each ttObjInfoSecProp use-index pi:
      if ttObjInfoSecProp.objInfoSecProp <> ? then delete object ttObjInfoSecProp.objInfoSecProp.
      delete ttObjInfoSecProp.
    end.
    SectionNum = 0.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private void putheader(input inpGetInfoSectionProp as class InfoSection ):

    put stream log-algo unformatted
          {&new-line}
          "-----------------------------------------------"
          {&new-line}
          now {&new-line}
          "Номер документа: " TrnDocNum {&new-line}
          "Секция: " inpGetInfoSectionProp:SectionName {&new-line}
          "Флаг комиссионного приема: " inpGetInfoSectionProp:IsKP {&new-line}
          inpGetInfoSectionProp:RnAlgo {&new-line}.
  
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void SaveDB():
    find first buf_goods no-lock where buf_goods.gds-code = GdsCode. 
    if not can-find (first buf_doc-line no-lock where
                               buf_doc-line.doc-code = TrnDocNum
                           and buf_goods.artic = buf_doc-line.artic
                           and buf_goods.prod-code = buf_doc-line.prod-code
                           and buf_goods.prod-type = buf_doc-line.prod-type)
    then do:
      return error substitute ("Линия по накладной не существует. Не возможно сохранить в базу данных данные по секциям для накладной &1 товар артикул &2 произовдитель &3&4", TrnDocNum, buf_goods.artic, buf_goods.prod-type, buf_goods.prod-code).
    end.
    SaveDBNoCheck().
  end.
  
  method public void SaveDBNoCheck():

    define variable ii as integer no-undo.
    
    for each buf_doc-line-attr where buf_doc-line-attr.doc-code = TrnDocNum 
      and buf_doc-line-attr.gds-code = GdsCode 
      :
       
      if buf_doc-line-attr.attr-code = "propan-perc"
      or buf_doc-line-attr.attr-code = "connect-hoses"
      then next .
      
      delete buf_doc-line-attr.
      
    end.

    create buf_doc-line-attr.
    assign
      buf_doc-line-attr.doc-code = TrnDocNum
      buf_doc-line-attr.gds-code = GdsCode
      buf_doc-line-attr.attr-code = "n"
      buf_doc-line-attr.attr-value = string (SectionNum)
    .
    
    do ii = 1 to SectionNum:
      GetInfoSectionProp (ii).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'car-vol' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:CarVol).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tests' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:Tests).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'certif-fuel' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:CertifFuel.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'norm-doc' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:NormDoc.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'num-passport' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:NumPassport.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'validity-certif' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:ValidityCertif.      
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'passport-plotn' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:PassportPlotn.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'place-si' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:PlaceSi).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'kol-prob' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:KolProb).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'num-print-prob' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:NumPrintProb).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'date-prob' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:DateProb).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'hour-prob' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:HourProb).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'min-prob' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:MinProb).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'date-pov-plotn' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:DatePovPlotn).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'num-plotn' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:NumPlotn.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'place-si-temp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:PlaceSiTemp).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'passport-plotn-temp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:PassportPlotnTemp.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'date-pov-plotn-temp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:DatePovPlotnTemp).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'num-plotn-temp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:NumPlotnTemp.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'date-start' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:DateStart).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'time-start' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TimeStart ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'date-end' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:DateEnd ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'time-end' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TimeEnd ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-vol' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankVol ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-temp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankTemp ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'avg-temp-rvs' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:AvgTempRvs ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-water' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankWater ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-density' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankDensity ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-weight' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankWeight ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-weight-rvs' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankWeightRvs ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'mouth' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:Mouth ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'a-b-tarir' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:ABTarir ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'diameter' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:Diameter ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-density-pomi' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankDensityPomi ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-vol-pomi' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankVolPomi ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-vol-pomi-real' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankVolPomiReal ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tank-vol-pomi-rvs' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TankVolPomiRvs ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'dens-temp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:DensTemp ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'section-name' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = InfoSectionCurr:SectionName.
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'doc-qnty' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:DocQnty ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'doc-dens' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:DocDensity ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'fact-dens' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:FactDensity ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'fact-qnty' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:FactQnty).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'acc-pomi' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:AccPOMI).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'acc-pomi-real' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:AccPomiReal).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'acc-ship' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:AccShip).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'rn-algo' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:RnAlgo).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'dop-info' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:AccAbsFact) + ',' + string ( InfoSectionCurr:NaturalLoss) 
              + ',' + (if InfoSectionCurr:Deficit <> 0 then string ( - InfoSectionCurr:Deficit) else string ( InfoSectionCurr:Excess)).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'is-kp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:IsKP).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'acc-meth' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:AccMeth).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'list-tank' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:ListTank).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'ttn-temp' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TTNTemp ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tp-norm-pl' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TPNormPL).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'tp-norm-auto' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:TPNormAuto).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'pour' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:Pour).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'shape' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:Shape).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'dop-volume' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string (InfoSectionCurr:DopVolume).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'doc-dens-st' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:DocDensST ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'pasp-dens' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:PaspDens ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'pressure' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:Pressure ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'group-np' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:GroupNP ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'doc-volume' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:DocVolume ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'cmom-nb' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:cmom-nb ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'alarm-SGDKK' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:alarm-SGDKK ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'aukkey' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:AukKey ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'KPnoMeas' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:KPnoMeas ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'pokmi-warnings' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:PokmiWarnings ).
      create buf_doc-line-attr.
      assign
        buf_doc-line-attr.doc-code = TrnDocNum
        buf_doc-line-attr.gds-code = GdsCode
        buf_doc-line-attr.attr-code = 'pokmi-warnings-rvs' + if SectionNum > 1 then {&delim-par} + string (ii) else "".
      buf_doc-line-attr.attr-value = string ( InfoSectionCurr:PokmiWarningsRVS ).
      release buf_doc-line-attr.
      
    end.

  end method.

  method public void RNAlgo (ii as int, output MP as decimal):

    RNAlgo(ii, MP, no).
    
  end.
  
  
  method public void RNAlgo (ii as int, output MP as decimal, IsManual as log):

    def var dMP  as decimal no-undo.
    def var MF   as decimal no-undo.
    def var dMF  as decimal no-undo.
    def var MTTH as decimal no-undo.
    def var md   as decimal no-undo.
    def var dmd  as decimal no-undo.
    def var dF   as decimal no-undo.
    def var NPE  as decimal no-undo.
    def var ME   as decimal no-undo.
    def var dMEd as decimal no-undo.
    def var I    as decimal no-undo.
    def var H    as decimal no-undo.
    def var v-ok as logical no-undo.
    
    assign
      MTTH = InfoSectionCurr:DocQnty * InfoSectionCurr:DocDensity
      MF = InfoSectionCurr:TankWeight
      dF = 0.65
      NPE = NormalWastage
      dmd = MF * dF * 0.01
      dMP = MF - MTTH
      dMEd = MTTH * NPE * 0.001
      ME = MTTH - MF - dmd
    .
    if ME < 0 then ME = 0 .

    if not InfoSectionCurr:IsKP or IsManual
    then do: 
      if abs (dMP) <= dmd /* условие (26) */
      then do:
        MP = MTTH.
        InfoSectionCurr:AccAbsFact = dmd.
        InfoSectionCurr:RnAlgo = "условие 26".
        output stream log-algo to value ("log-algo-pomi.txt") append.
        putheader(InfoSectionCurr).
        put stream log-algo unformatted
          "MTTH  = " string(MTTH) {&new-line}
          "MF  = " string(MF) {&new-line}
          "dF  = " string(dF) {&new-line}
          "NPE  = " string(NPE) {&new-line}
          "dmd  = " string(dmd) {&new-line}
          "dMP  = " string(dMP) {&new-line}
          "dMEd  = " string(dMEd) {&new-line}
          "ME = " string(ME) {&new-line}
        .
        output stream log-algo close.
        return.
      end.
      
      if abs (dMP) <= dmd + dMed /* условие (29) */
      then do:
        MP = MTTH - ME.
        InfoSectionCurr:AccAbsFact = dmd + dMed.
/*        if InfoSectionCurr:TankWeight <= 0 or InfoSectionCurr:TankWeight = ? then ME = 0 .*/
        InfoSectionCurr:NaturalLoss = ME.
        InfoSectionCurr:RnAlgo = "условие 29".
        output stream log-algo to value ("log-algo-pomi.txt") append.
        putheader(InfoSectionCurr).
        put stream log-algo unformatted
          "MTTH  = " string(MTTH) {&new-line}
          "MF  = " string(MF) {&new-line}
          "dF  = " string(dF) {&new-line}
          "NPE  = " string(NPE) {&new-line}
          "dmd  = " string(dmd) {&new-line}
          "dMP  = " string(dMP) {&new-line}
          "dMEd  = " string(dMEd) {&new-line}
          "ME = " string(ME) {&new-line}
        .
        output stream log-algo close.
        return.
      end.
    end.

    if not InfoSectionCurr:IsKP and not isManual
    then do: 
      message substitute ("Имеются расхождения с документарным количеством больше допустимого. Требуется комиссионный прием нефтепродукта. Продолжить (для секции &1 будет установлен флаг комиссионного приема)?", ii)
      view-as alert-box question buttons yes-no update v-ok .
      if not v-ok
      then do:
        MP = ?.
        return.
      end.
      IsFlagKPChg = true.
      assign
        InfoSectionCurr:IsKP = true
      .
      MP = ?.
      return.
    end.
    
    IsFlagKPChg = false.
    
    if not IsActnComm
    then do:
/*      message substitute ( "По секции &1 включен комиссионный прием нефтепродукта. У пользователя отсутвует право <<Комиссионный прием нефтепродукта>>. Продолжение невозможно.", ii ).*/
      MP = ?.
      return.
    end.
    
    def var MKP    as decimal no-undo.
    def var dMKP   as decimal no-undo.
    def var dmKPd  as decimal no-undo.
    def var delKP  as decimal no-undo.
    def var delTTH as decimal no-undo.
    def var dTTH   as decimal no-undo.
    def var dKP    as decimal no-undo.
    def var MKPK   as decimal no-undo.
    def var dmTTHd as decimal no-undo.
    def var X1     as decimal no-undo.
    def var X2     as decimal no-undo.
    def var X3     as decimal no-undo.
    def var X4     as decimal no-undo.
    
    if InfoSectionCurr:AccMeth = 1
    then
    assign
      MF = InfoSectionCurr:TankWeightRvs
      dMP = MF - MTTH
    .
    
    InfoSectionCurr:Deficit = 0 .
    InfoSectionCurr:Excess  = 0 .

    MKP = MF.
    dMKP = MKP - MTTH.
    dKP = InfoSectionCurr:AccPomi. /*if AccComm = ? then 0 else AccComm.*/
    
    dmKPd = MKP * dF * 0.01.
    delKP = dF * MKP * 0.01. /*одно и тоже для наглядности с документацией*/


    if abs(dMKP) <= dmKPd /* условие (34) */
    then do:
      MP = MTTH.
      InfoSectionCurr:AccAbsFact = dmKPd.
      InfoSectionCurr:RnAlgo = "условие 34".
      output stream log-algo to value ("log-algo-pomi.txt") append.
      putheader(InfoSectionCurr).
      put stream log-algo unformatted
        "MTTH  = " string(MTTH) {&new-line}
        "MF  = " string(MF) {&new-line}
        "dF  = " string(dF) {&new-line}
        "NPE  = " string(NPE) {&new-line}
        "dmd  = " string(dmd) {&new-line}
        "dMP  = " string(dMP) {&new-line}
        "dMEd  = " string(dMEd) {&new-line}
        "ME = " string(ME) {&new-line}
        "MKP = " string(MKP) {&new-line}
        "dMKP = " string(dMKP) {&new-line}
        "dmKPd = " string(dmKPd) {&new-line}
        "dTTH = " string(dTTH) {&new-line}
        "dKP = " string(dKP) {&new-line}
        "MKPK = " string(MKPK) {&new-line}
        "dmTTHd = " string(dmTTHd) {&new-line}
        "MP = " string(MP) {&new-line}
        "I = " string(I) {&new-line}
        "H = " string(H) {&new-line}
      .
      output stream log-algo close.
      return.
    end.
    else do : /* не соблюдается условие (34) */
      if MTTH < MKP /* условие (36) */
      then do :
        MKPK = MKP - dmKPd .
        I = MKPK - MTTH.
        MP = MKPK.
        InfoSectionCurr:AccAbsFact = dmKPd.
        InfoSectionCurr:Excess = I.
        InfoSectionCurr:RnAlgo = " нет условие 34 и условие 36".
        output stream log-algo to value ("log-algo-pomi.txt") append.
        putheader(InfoSectionCurr).
        put stream log-algo unformatted
          "MTTH  = " string(MTTH) {&new-line}
          "MF  = " string(MF) {&new-line}
          "dF  = " string(dF) {&new-line}
          "NPE  = " string(NPE) {&new-line}
          "dmd  = " string(dmd) {&new-line}
          "dMP  = " string(dMP) {&new-line}
          "dMEd  = " string(dMEd) {&new-line}
          "ME = " string(ME) {&new-line}
          "MKP = " string(MKP) {&new-line}
          "dMKP = " string(dMKP) {&new-line}
          "dmKPd = " string(dmKPd) {&new-line}
          "delKP = " string(delKP) {&new-line}
          "dKP = " string(dKP) {&new-line}
          "MKPK = " string(MKPK) {&new-line}
          "dmTTHd = " string(dmTTHd) {&new-line}
          "I = " string(I) {&new-line}
          "H = " string(H) {&new-line}
        .
        output stream log-algo close.
        return.
      end .
      
      if MTTH > MKP /* условие (40) */
      then do :
        if abs(dMKP) <= (dmKPd + dMed) /* условие (41)*/
        then do :
          ME = MTTH - MKP - dmKPd .
          MP = MTTH - ME .
          InfoSectionCurr:AccAbsFact = dmKPd + dMed .
/*          if InfoSectionCurr:TankWeight <= 0 or InfoSectionCurr:TankWeight = ? then ME = 0 .*/
          InfoSectionCurr:NaturalLoss = ME .
          InfoSectionCurr:RnAlgo = " нет условие 34, условие 40 и условие 41".
          output stream log-algo to value ("log-algo-pomi.txt") append.
          putheader(InfoSectionCurr).
          put stream log-algo unformatted
            "MTTH  = " string(MTTH) {&new-line}
            "MF  = " string(MF) {&new-line}
            "dF  = " string(dF) {&new-line}
            "NPE  = " string(NPE) {&new-line}
            "dmd  = " string(dmd) {&new-line}
            "dMP  = " string(dMP) {&new-line}
            "dMEd  = " string(dMEd) {&new-line}
            "ME = " string(ME) {&new-line}
            "MKP = " string(MKP) {&new-line}
            "dMKP = " string(dMKP) {&new-line}
            "dmKPd = " string(dmKPd) {&new-line}
            "dKP = " string(dKP) {&new-line}
            "MKPK = " string(MKPK) {&new-line}
            "dmTTHd = " string(dmTTHd) {&new-line}
            "I = " string(I) {&new-line}
            "H = " string(H) {&new-line}
          .
          output stream log-algo close.
          return.
        end .
        else do : /* не соблюдается условие (41)*/
          MKPK = MKP + dmKPd .
          ME = dMed .
          H = MTTH - MKPK - ME .
          MP = MKPK .
          InfoSectionCurr:AccAbsFact = dmKPd + dMed.
/*          if InfoSectionCurr:TankWeight <= 0 or InfoSectionCurr:TankWeight = ? then ME = 0 .*/
          InfoSectionCurr:NaturalLoss = ME.
          InfoSectionCurr:Deficit = H.
          InfoSectionCurr:RnAlgo = " нет условие 34, условие 40 и нет условие 41".
          output stream log-algo to value ("log-algo-pomi.txt") append.
          putheader(InfoSectionCurr).
          put stream log-algo unformatted
            "MTTH  = " string(MTTH) {&new-line}
            "MF  = " string(MF) {&new-line}
            "dF  = " string(dF) {&new-line}
            "NPE  = " string(NPE) {&new-line}
            "dmd  = " string(dmd) {&new-line}
            "dMP  = " string(dMP) {&new-line}
            "dMEd  = " string(dMEd) {&new-line}
            "ME = " string(ME) {&new-line}
            "MKP = " string(MKP) {&new-line}
            "dMKP = " string(dMKP) {&new-line}
            "dmKPd = " string(dmKPd) {&new-line}
            "delKP = " string(delKP) {&new-line}
            "dKP = " string(dKP) {&new-line}
            "MKPK = " string(MKPK) {&new-line}
            "dmTTHd = " string(dmTTHd) {&new-line}
            "I = " string(I) {&new-line}
            "H = " string(H) {&new-line}
          .
          output stream log-algo close.
          return.
        end .
      end .
    end .
    
/*    dTTH = InfoSectionCurr:AccShip.                                                            */
/*    dmTTHd = MTTH * dTTH * 0.01.                                                               */
/*                                                                                               */
/*    X3 = MKP - dmKPd.                                                                          */
/*    X4 = MTTH + dmTTHd.                                                                        */
/*                                                                                               */
/*    delTTH = dTTH * MTTH * 0.01.                                                               */
/*                                                                                               */
/*    MKPK = X3 + dF * ((X4 - X3) / (dTTH + dF)).                                                */
/*                                                                                               */
/*                                                                                               */
/*    if abs (dMKP) <= delTTH + delKP /* условие (32)*/ and MTTH < MKP /* условие (35) */        */
/*    then do:                                                                                   */
/*      I = MKPK - MTTH.                                                                         */
/*      MP = MKPK.                                                                               */
/*      InfoSectionCurr:AccAbsFact = delTTH + delKP.                                             */
/*      InfoSectionCurr:Excess = I.                                                              */
/*      InfoSectionCurr:RnAlgo = "условие 32 и условие 35".                                      */
/*      output stream log-algo to value ("log-algo-pomi.txt") append.                            */
/*      putheader(InfoSectionCurr).                                                              */
/*      put stream log-algo unformatted                                                          */
/*        "MTTH  = " string(MTTH) {&new-line}                                                    */
/*        "MF  = " string(MF) {&new-line}                                                        */
/*        "dF  = " string(dF) {&new-line}                                                        */
/*        "NPE  = " string(NPE) {&new-line}                                                      */
/*        "dmd  = " string(dmd) {&new-line}                                                      */
/*        "dMP  = " string(dMP) {&new-line}                                                      */
/*        "dMEd  = " string(dMEd) {&new-line}                                                    */
/*        "ME = " string(ME) {&new-line}                                                         */
/*        "MKP = " string(MKP) {&new-line}                                                       */
/*        "dMKP = " string(dMKP) {&new-line}                                                     */
/*        "dmKPd = " string(dmKPd) {&new-line}                                                   */
/*        "delKP = " string(delKP) {&new-line}                                                   */
/*        "delTTH = " string(delTTH) {&new-line}                                                 */
/*        "dTTH = " string(dTTH) {&new-line}                                                     */
/*        "dKP = " string(dKP) {&new-line}                                                       */
/*        "MKPK = " string(MKPK) {&new-line}                                                     */
/*        "dmTTHd = " string(dmTTHd) {&new-line}                                                 */
/*        "X1 = " string(X1) {&new-line}                                                         */
/*        "X2 = " string(X2) {&new-line}                                                         */
/*        "X3 = " string(X3) {&new-line}                                                         */
/*        "X4 = " string(X4) {&new-line}                                                         */
/*        "MP = " string(MP) {&new-line}                                                         */
/*        "I = " string(I) {&new-line}                                                           */
/*        "H = " string(H) {&new-line}                                                           */
/*      .                                                                                        */
/*      output stream log-algo close.                                                            */
/*      return.                                                                                  */
/*    end.                                                                                       */
/*                                                                                               */
/*                                                                                               */
/*    if not abs (dmKP) <= delTTH + delKP /* условие (32)*/ and MTTH < MKP /* условие (35) */    */
/*    then do:                                                                                   */
/*      MP = MKP - delKP.                                                                        */
/*      I = MKP - MTTH - delKP.                                                                  */
/*      InfoSectionCurr:AccAbsFact = delTTH + delKP.                                             */
/*      InfoSectionCurr:Excess = I.                                                              */
/*      InfoSectionCurr:RnAlgo = "нет условие 32 и условие 35".                                  */
/*      output stream log-algo to value ("log-algo-pomi.txt") append.                            */
/*      putheader(InfoSectionCurr).                                                              */
/*      put stream log-algo unformatted                                                          */
/*        "MTTH  = " string(MTTH) {&new-line}                                                    */
/*        "MF  = " string(MF) {&new-line}                                                        */
/*        "dF  = " string(dF) {&new-line}                                                        */
/*        "NPE  = " string(NPE) {&new-line}                                                      */
/*        "dmd  = " string(dmd) {&new-line}                                                      */
/*        "dMP  = " string(dMP) {&new-line}                                                      */
/*        "dMEd  = " string(dMEd) {&new-line}                                                    */
/*        "ME = " string(ME) {&new-line}                                                         */
/*        "MKP = " string(MKP) {&new-line}                                                       */
/*        "dMKP = " string(dMKP) {&new-line}                                                     */
/*        "dmKPd = " string(dmKPd) {&new-line}                                                   */
/*        "delKP = " string(delKP) {&new-line}                                                   */
/*        "delTTH = " string(delTTH) {&new-line}                                                 */
/*        "dTTH = " string(dTTH) {&new-line}                                                     */
/*        "dKP = " string(dKP) {&new-line}                                                       */
/*        "MKPK = " string(MKPK) {&new-line}                                                     */
/*        "dmTTHd = " string(dmTTHd) {&new-line}                                                 */
/*        "X1 = " string(X1) {&new-line}                                                         */
/*        "X2 = " string(X2) {&new-line}                                                         */
/*        "X3 = " string(X3) {&new-line}                                                         */
/*        "X4 = " string(X4) {&new-line}                                                         */
/*        "MP = " string(MP) {&new-line}                                                         */
/*        "I = " string(I) {&new-line}                                                           */
/*        "H = " string(H) {&new-line}                                                           */
/*      .                                                                                        */
/*      output stream log-algo close.                                                            */
/*      return.                                                                                  */
/*    end.                                                                                       */
/*                                                                                               */
/*    if abs (dmKP) <= delTTH + delKP /* условие (32)*/ and MTTH > MKP /* условие (44) */        */
/*    then do:                                                                                   */
/*      if abs (dMKP) <= dmKPd + dMed /* условие (45) */                                         */
/*      then do:                                                                                 */
/*        ME = MTTH - MKP - dmKPd.                                                               */
/*        MP = MTTH - ME.                                                                        */
/*        InfoSectionCurr:AccAbsFact = dmKPd + dMed.                                             */
/*        InfoSectionCurr:NaturalLoss = ME.                                                      */
/*        InfoSectionCurr:RnAlgo = "условие 32 и условие 44 и условие 45".                       */
/*        output stream log-algo to value ("log-algo-pomi.txt") append.                          */
/*        putheader(InfoSectionCurr).                                                            */
/*        put stream log-algo unformatted                                                        */
/*          "MTTH  = " string(MTTH) {&new-line}                                                  */
/*          "MF  = " string(MF) {&new-line}                                                      */
/*          "dF  = " string(dF) {&new-line}                                                      */
/*          "NPE  = " string(NPE) {&new-line}                                                    */
/*          "dmd  = " string(dmd) {&new-line}                                                    */
/*          "dMP  = " string(dMP) {&new-line}                                                    */
/*          "dMEd  = " string(dMEd) {&new-line}                                                  */
/*          "ME = " string(ME) {&new-line}                                                       */
/*          "MKP = " string(MKP) {&new-line}                                                     */
/*          "dMKP = " string(dMKP) {&new-line}                                                   */
/*          "dmKPd = " string(dmKPd) {&new-line}                                                 */
/*          "delKP = " string(delKP) {&new-line}                                                 */
/*          "delTTH = " string(delTTH) {&new-line}                                               */
/*          "dTTH = " string(dTTH) {&new-line}                                                   */
/*          "dKP = " string(dKP) {&new-line}                                                     */
/*          "MKPK = " string(MKPK) {&new-line}                                                   */
/*          "dmTTHd = " string(dmTTHd) {&new-line}                                               */
/*          "X1 = " string(X1) {&new-line}                                                       */
/*          "X2 = " string(X2) {&new-line}                                                       */
/*          "X3 = " string(X3) {&new-line}                                                       */
/*          "X4 = " string(X4) {&new-line}                                                       */
/*          "MP = " string(MP) {&new-line}                                                       */
/*          "I = " string(I) {&new-line}                                                         */
/*          "H = " string(H) {&new-line}                                                         */
/*        .                                                                                      */
/*        output stream log-algo close.                                                          */
/*        return.                                                                                */
/*      end.                                                                                     */
/*      else do:                                                                                 */
/*                                                                                               */
/*        X1 = MTTH - dmTTHd.                                                                    */
/*        X2 = MKP + dmKPd.                                                                      */
/*                                                                                               */
/*        MKPK = X1 + dTTH * ((X2 - X1) / (dTTH + dKP)).                                         */
/*                                                                                               */
/*        MP = MKPK.                                                                             */
/*        ME = dMEd.                                                                             */
/*        H = MTTH - MKPK - ME.                                                                  */
/*        InfoSectionCurr:AccAbsFact = dmKPd + dMed.                                             */
/*        InfoSectionCurr:NaturalLoss = ME.                                                      */
/*        InfoSectionCurr:Deficit = H.                                                           */
/*        InfoSectionCurr:RnAlgo = "условие 32 и условие 44 и нет условие 45".                   */
/*        output stream log-algo to value ("log-algo-pomi.txt") append.                          */
/*        putheader(InfoSectionCurr).                                                            */
/*        put stream log-algo unformatted                                                        */
/*          "MTTH  = " string(MTTH) {&new-line}                                                  */
/*          "MF  = " string(MF) {&new-line}                                                      */
/*          "dF  = " string(dF) {&new-line}                                                      */
/*          "NPE  = " string(NPE) {&new-line}                                                    */
/*          "dmd  = " string(dmd) {&new-line}                                                    */
/*          "dMP  = " string(dMP) {&new-line}                                                    */
/*          "dMEd  = " string(dMEd) {&new-line}                                                  */
/*          "ME = " string(ME) {&new-line}                                                       */
/*          "MKP = " string(MKP) {&new-line}                                                     */
/*          "dMKP = " string(dMKP) {&new-line}                                                   */
/*          "dmKPd = " string(dmKPd) {&new-line}                                                 */
/*          "delKP = " string(delKP) {&new-line}                                                 */
/*          "delTTH = " string(delTTH) {&new-line}                                               */
/*          "dTTH = " string(dTTH) {&new-line}                                                   */
/*          "dKP = " string(dKP) {&new-line}                                                     */
/*          "MKPK = " string(MKPK) {&new-line}                                                   */
/*          "dmTTHd = " string(dmTTHd) {&new-line}                                               */
/*          "X1 = " string(X1) {&new-line}                                                       */
/*          "X2 = " string(X2) {&new-line}                                                       */
/*          "X3 = " string(X3) {&new-line}                                                       */
/*          "X4 = " string(X4) {&new-line}                                                       */
/*          "MP = " string(MP) {&new-line}                                                       */
/*          "I = " string(I) {&new-line}                                                         */
/*          "H = " string(H) {&new-line}                                                         */
/*        .                                                                                      */
/*        output stream log-algo close.                                                          */
/*        return.                                                                                */
/*      end.                                                                                     */
/*                                                                                               */
/*    end.                                                                                       */
/*                                                                                               */
/*    if not ( abs (dmKP) <= delTTH + delKP ) /* условие (32)*/ and MTTH > MKP /* условие (44) */*/
/*    then do:                                                                                   */
/*      ME = dMEd.                                                                               */
/*      MP = MKP + delKP.                                                                        */
/*      H = MTTH - MKP - delKP - ME.                                                             */
/*      InfoSectionCurr:AccAbsFact = delTTH + delKP.                                             */
/*      InfoSectionCurr:NaturalLoss = ME.                                                        */
/*      InfoSectionCurr:Deficit = H.                                                             */
/*      InfoSectionCurr:RnAlgo =  "нет условие 32 и условие 44".                                 */
/*      output stream log-algo to value ("log-algo-pomi.txt") append.                            */
/*      putheader(InfoSectionCurr).                                                              */
/*      put stream log-algo unformatted                                                          */
/*        "MTTH  = " string(MTTH) {&new-line}                                                    */
/*        "MF  = " string(MF) {&new-line}                                                        */
/*        "dF  = " string(dF) {&new-line}                                                        */
/*        "NPE  = " string(NPE) {&new-line}                                                      */
/*        "dmd  = " string(dmd) {&new-line}                                                      */
/*        "dMP  = " string(dMP) {&new-line}                                                      */
/*        "dMEd  = " string(dMEd) {&new-line}                                                    */
/*        "ME = " string(ME) {&new-line}                                                         */
/*        "MKP = " string(MKP) {&new-line}                                                       */
/*        "dMKP = " string(dMKP) {&new-line}                                                     */
/*        "dmKPd = " string(dmKPd) {&new-line}                                                   */
/*        "delKP = " string(delKP) {&new-line}                                                   */
/*        "delTTH = " string(delTTH) {&new-line}                                                 */
/*        "dTTH = " string(dTTH) {&new-line}                                                     */
/*        "dKP = " string(dKP) {&new-line}                                                       */
/*        "MKPK = " string(MKPK) {&new-line}                                                     */
/*        "dmTTHd = " string(dmTTHd) {&new-line}                                                 */
/*        "X1 = " string(X1) {&new-line}                                                         */
/*        "X2 = " string(X2) {&new-line}                                                         */
/*        "X3 = " string(X3) {&new-line}                                                         */
/*        "X4 = " string(X4) {&new-line}                                                         */
/*        "MP = " string(MP) {&new-line}                                                         */
/*        "I = " string(I) {&new-line}                                                           */
/*        "H = " string(H) {&new-line}                                                           */
/*      .                                                                                        */
/*      output stream log-algo close.                                                            */
/*      return.                                                                                  */
/*    end.                                                                                       */

    finally:
      
      find first ub.place no-lock where ub.place.obj-type = ObjType and ub.place.obj-code = ObjCode and ub.place.loc1 = InfoSectionCurr:ListTank no-error. 
      if available (ub.place)
      then do:
        assign
          Parnl:ObjType = ObjType 
          Parnl:ObjCode = ObjCode
          Parnl:GdsCode = GdsCode
          Parnl:AutoNum = CarNum
          Parnl:OnDate = buf_trn.doc-date
        .
        
        Parnl:PlCode = ub.place.pl-code no-error.
        release ub.place.
        Parnl:SecNum = InfoSectionCurr:SectionName.
        Parnl:GroupNP = InfoSectionCurr:GroupNP.
        NLStorage:getNormLoss(Parnl).
        InfoSectionCurr:TPNormAuto = Parnl:AutoNormLoss.
        InfoSectionCurr:TPNormPL = (InfoSectionCurr:TankWeight / 1000 * ParNl:PLNormLoss).
        output stream log-algo to value ("log-algo-pomi.txt") append.
        put stream log-algo unformatted
          "MTP = " InfoSectionCurr:TPNorm {&new-line}
          "NHH = " string(Parnl:AutoNormLoss) {&new-line}
          "NPR = " string(Parnl:PLNormLoss) {&new-line}.
        output stream log-algo close.      
      end.
    end finally.
      
    

  end method.
  
  method public void CalcWeight ():  
    define variable ToolType                as integer no-undo.
    define variable DeltaAbs_R              as decimal no-undo.
    define variable DeltaOtn_R              as decimal no-undo.
    define variable DeltaAbs_Tv             as decimal no-undo.
    define variable DeltaAbs_Tr             as decimal no-undo.
    define variable NeckType                as integer no-undo.
    define variable Dgor                    as decimal no-undo.
    define variable NeckWidth               as decimal no-undo.
    define variable NeckHeight              as decimal no-undo.
    define variable ToolAutomationLevel_R   as integer no-undo.
    define variable ToolAutomationLevel_Tv  as integer no-undo.
    define variable ToolAutomationLevel_Tr  as integer no-undo.
    define variable error-string            as character no-undo.
    define variable v-proc as character no-undo.
    define variable v-TankVol-m3            as decimal decimals 10 no-undo .
    define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].
    define buffer buf_sr-izmerenia    for ub.sr-izmerenia .
    
    define variable A_Reservoir             as decimal no-undo init 0.0000125 .
    
    define variable DeltaOtn_N               as decimal no-undo init 0.05 .
    define variable V_real as decimal no-undo.
    
    define variable vErr as character no-undo .
    define variable vWrn as character no-undo .
    define variable vDllVersion as character no-undo .
    
    define variable DeltaV_GT as decimal no-undo.          
    define variable DeltaV as decimal no-undo.            
    define variable Vcy as decimal no-undo.              
    define variable Rcy as decimal no-undo.      
    define variable Rcy20 as decimal no-undo.    
    define variable V as decimal no-undo.      
    define variable CTL_base_alt as decimal no-undo.   
    define variable CPL_base_alt as decimal no-undo.
    define variable CTPL_base_alt as decimal no-undo.
    define variable Fp_base_alt as decimal no-undo. 
    define variable CTL_obs_base as decimal no-undo.
    define variable CPL_obs_base as decimal no-undo.
    define variable CTPL_obs_base as decimal no-undo.
    define variable Fp_obs_base as decimal no-undo. 
    define variable VolumetricExpansion as decimal no-undo.
    define variable Rv as decimal no-undo.         
    define variable DeltaOtn_Vcy as decimal no-undo.
    define variable M as decimal no-undo.            
    define variable DeltaOtn_M as decimal no-undo.

    case RdcDnstvalue:
      when "pomi-rn" then do:
        _trpomi :
          do on error undo, return no-apply :
    
  
            /*данные по средству измерения резервуара для ПОкМИ*/
          find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = InfoSectionCurr:PlaceSi no-error.
          if not available buf_sr-izmerenia then do :
            message
              substitute( 'Не найдено средство измерения плотности с кодом &1', InfoSectionCurr:PlaceSi ) skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          else do :
            if buf_sr-izmerenia.sr-type-izm = 2 then 
            do:
              message
                "При расчете по методу CMethodOfMetering31N ~"Расчет массы и объема нефтепродуктов в автомобильных цистернах~"" skip
                "не предусматривается использование СИ с типом ~"Измерительная система~""
              view-as alert-box error.
              undo _trpomi, return no-apply  .
            end.    
            
            assign
              ToolType               = buf_sr-izmerenia.sr-type-id
              DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
              DeltaOtn_R             = buf_sr-izmerenia.sr-relative-err-dens
              ToolAutomationLevel_R  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].
              ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].
              ToolAutomationLevel_Tr = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            .
            if DeltaOtn_R = ? then DeltaOtn_R = 0 .
          end.
          
          find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = InfoSectionCurr:PlaceSiTemp no-error.
          if not available buf_sr-izmerenia then do :
            message
              substitute( 'Не найдено средство измерения температуры с кодом &1', InfoSectionCurr:PlaceSiTemp ) skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          else do :
            assign
              DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
              ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
              ToolAutomationLevel_Tr = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            .
          end.
          
          /*..........................................*/
          
          v-proc = "CMethodOfMetering31N" .
    
          if InfoSectionCurr:Pour = "" then do :
            message 
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Введите тип налива"  skip
            view-as alert-box error.
            undo _trpomi, return no-apply .
          end.
          
          if InfoSectionCurr:Shape = "" then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Укажите форму горловины"  skip
            view-as alert-box error.
          end.
          if InfoSectionCurr:CarVol = ? or InfoSectionCurr:CarVol = 0 then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Введите Объем по свидетельству о поверке в литрах"  skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          
          if InfoSectionCurr:ABTarir = ? then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Введите Уровень цистерны относительно тарировочной планки"  skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
/*              assign                                         */
/*              f-size              = string (decimal (f-size))*/
/*              f-size:screen-value = string (decimal (f-size))*/
/*              no-error.                                      */
          decimal(InfoSectionCurr:Diameter) no-error .
          if error-status:error then 
          do:
            assign
              NeckType = 1
              NeckWidth = decimal (entry (1, replace(InfoSectionCurr:Diameter, "\", "/"), "/")) 
              NeckHeight = decimal (entry (2, replace(InfoSectionCurr:Diameter, "\", "/"), "/"))
              Dgor = 0
            no-error .
          end.
          else do: 
          assign 
            NeckType = 0 
            Dgor = decimal (InfoSectionCurr:Diameter).
          end.  
/*            if InfoSectionCurr:Diameter = ? or InfoSectionCurr:Diameter = "0" then do :*/
/*              message                                                                  */
/*                "Заполнены не все поля, необходимые " skip                             */
/*                "для работы библиотеки ПОкМИ"         skip                             */
/*                "Введите Внутренний диаметр горловины"  skip                           */
/*              view-as alert-box error.                                                 */
/*              undo _trpomi, return no-apply  .                                         */
/*            end.                                                                       */
          if InfoSectionCurr:TankTemp = ? then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Введите Температуру"  skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          if InfoSectionCurr:DensTemp = ? then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Введите Температуру"  skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          if InfoSectionCurr:TankDensity = ? or InfoSectionCurr:TankDensity = 0 then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Введите Плотность топлива для ПОкМИ"  skip
            view-as alert-box error.
            undo _trpomi, return no-apply .
          end.

          if  InfoSectionCurr:ListTank = "" then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПОкМИ"         skip
              "Выберите резервуар"  skip
            view-as alert-box error.
            undo _trpomi, return no-apply .
          end.

          define variable v-auto-error as decimal no-undo.
          find first ub.auto-tank-attr no-lock
               where ub.auto-tank-attr.auto-num = CarNum
                 and ub.auto-tank-attr.attr-code = "auto-error" no-error.
          
          if available (ub.auto-tank-attr)
          then do:
            assign v-auto-error = decimal (ub.auto-tank-attr.attr-value) no-error.
            if error-status:error
              then v-auto-error = 0.4 .
          end.
          else do:
            v-auto-error = 0.4 .
          end.
          
          find first ub.auto-tank-attr no-lock
               where ub.auto-tank-attr.auto-num = CarNum
                 and ub.auto-tank-attr.attr-code = "auto-temp" no-error.
          
          if available (ub.auto-tank-attr)
          then do:
            assign A_Reservoir = decimal (ub.auto-tank-attr.attr-value) no-error.
            if error-status:error
              then A_Reservoir = 0.0000125 .
          end.
          else do:
            A_Reservoir = 0.0000125 .
          end.
          if A_Reservoir <> 0.0000125
          and A_Reservoir <> 0.000023
          then do :
            A_Reservoir = 0.0000125 .
          end .

          if infoSectionCurr:Pour = "Нижний налив"
          then do:
            assign
              V_real = (InfoSectionCurr:CarVol + InfoSectionCurr:DopVolume) / 1000
            .
          end.
          else do:
            assign
              V_real = InfoSectionCurr:CarVol / 1000
            .
          end.
   
          if InfoSectionCurr:Shape = entry (1, {&list-shape})
          then do :
            InfoSectionCurr:GetCalibTable(InfoSectionCurr:ABTarir) .
          end .
          
          MM31N
            (
            input V_real,
            input if InfoSectionCurr:Shape = entry (1, {&list-shape}) then 2 else 1, /* DeltaCorrectionType */
            input InfoSectionCurr:CalibTable, /* CalibrationTable */
            input InfoSectionCurr:ABTarir, /* DeltaH */
            input if InfoSectionCurr:Shape = entry (1, {&list-shape}) then 0 else InfoSectionCurr:NeckArea,
            input infoSectionCurr:TankTemp,
            input InfoSectionCurr:DensTemp,
            input InfoSectionCurr:TankDensity * 1000,
            input TempForPomi,
            input 0.0, /* Pr */
            input 0.0, /* Pv */
            input ToolType,
            input A_Reservoir, /* A_Reservoir */
            input v-auto-error, /* DeltaOtn_V */
            input ToolAutomationLevel_R,
            input ToolAutomationLevel_Tv,
            input ToolAutomationLevel_Tr,
            input DeltaAbs_R,
            input DeltaOtn_R,
            input DeltaAbs_Tv,
            input DeltaAbs_Tr,
            input DeltaOtn_N,
            input 1, /* Round_M */
            input 2, /* Round_T */
            input 2, /* Round_R */
            
            output DeltaV_GT,
            output DeltaV,
            output Vcy,
            output Rcy,
            output Rcy20,
            output V,
            output CTL_base_alt,
            output CPL_base_alt,
            output CTPL_base_alt,
            output Fp_base_alt,
            output CTL_obs_base,
            output CPL_obs_base,
            output CTPL_obs_base,
            output Fp_obs_base,
            output VolumetricExpansion,
            output Rv,
            output DeltaOtn_Vcy,
            output M,
            output DeltaOtn_M,
            
            output vErr,
            output vWrn,
            output vDllVersion
            )
          .
          
          output stream outstream to value ("pomi.log") append.
          put stream outstream unformatted
            {&new-line}
                                       now                     skip
            'Процедура: '              v-proc                  skip
            'Версия dll: '             vDllVersion     skip
            'V_real                 = ' V_real            skip
            'DeltaCorrectionType    = ' if InfoSectionCurr:Shape = entry (1, {&list-shape}) then 2 else 1 skip
            'CalibrationTable       = ' InfoSectionCurr:CalibTable skip
            'DeltaH                 = ' InfoSectionCurr:ABTarir skip
            'NeckArea               = ' (if InfoSectionCurr:Shape = entry (1, {&list-shape}) then 0 else InfoSectionCurr:NeckArea) skip
            'Tv                     = ' InfoSectionCurr:TankTemp skip
            'Tr                     = ' InfoSectionCurr:DensTemp skip
            'R                      = ' trim(string(( InfoSectionCurr:TankDensity * 1000 ), ">>>9.9<")) skip
            'Tcy                    = ' TempForPomi skip
            'ToolType               = ' ToolType                skip
            'A_Reservoir            = ' string (A_Reservoir)    skip
            'DeltaOtn_V             = ' string (v-auto-error)   skip
            'ToolAutomationLevel_R  = ' ToolAutomationLevel_R skip
            'ToolAutomationLevel_Tv = ' ToolAutomationLevel_Tv skip
            'ToolAutomationLevel_Tr = ' ToolAutomationLevel_Tr skip
            'DeltaAbs_R             = ' DeltaAbs_R              skip
            'DeltaOtn_R             = ' DeltaOtn_R              skip
            'DeltaAbs_Tv            = ' DeltaAbs_Tv             skip
            'DeltaAbs_Tr            = ' DeltaAbs_Tr             skip
            'DeltaOtn_N             = ' DeltaOtn_N              skip
            'Round_M                = ' 1                       skip
            'Round_T                = ' 2                       skip
            'Round_R                = ' 2                       skip
            'DeltaV_GT              = ' DeltaV_GT         skip  
            'DeltaV                 = ' DeltaV            skip  
            'Vcy                    = ' Vcy               skip 
            'Rcy                    = ' Rcy               skip
            'Rcy20                  = ' Rcy20             skip
            'V                      = ' V                 skip
            'CTL_base_alt           = ' CTL_base_alt      skip 
            'CPL_base_alt           = ' CPL_base_alt      skip 
            'CTPL_base_alt          = ' CTPL_base_alt     skip
            'Fp_base_alt            = ' Fp_base_alt       skip
            'CTL_obs_base           = ' CTL_obs_base      skip
            'CPL_obs_base           = ' CPL_obs_base      skip
            'CTPL_obs_base          = ' CTPL_obs_base     skip
            'VolumetricExpansion    = ' VolumetricExpansion skip
            'Fp_obs_base            = ' Fp_obs_base       skip
            'Rv                     = ' Rv                skip
            'DeltaOtn_Vcy           = ' DeltaOtn_Vcy      skip 
            'M                      = ' M                 skip
            'DeltaOtn_M             = ' DeltaOtn_M        skip
            'Warnings               = ' vWrn              skip
          .    

          output stream outstream close.
          if trim(vErr) > "" then do :
            error-string = replace(vErr,";0x","~n0x") .
            output stream outstream to value ("pomi.log") append.
            put stream outstream error-string format "x(1024)" skip.

            output stream outstream close.
            message
              substitute('Ошибка работы библиотеки ПОкМИ &1',error-string) skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          else do :
            assign
              InfoSectionCurr:cmom-nb = v-proc
              InfoSectionCurr:TankDensityPomi = Rcy / 1000
              InfoSectionCurr:TankVolPomi     = Vcy * 1000
              InfoSectionCurr:TankWeight      = M
/*                InfoSectionCurr:AccPomi         = round (v-mm:DeltaOtn_M, 3) ZI-2815*/
              InfoSectionCurr:AccPomi         = 0.65
              InfoSectionCurr:AccPomiReal     = round(DeltaOtn_M, 2)
              InfoSectionCurr:TankVolPomiReal = V * 1000
              InfoSectionCurr:PokmiWarnings   = vWrn
            .
/*            output stream outstream to value ("pomi.log") append.*/
/*              put stream outstream                               */
/*              "Rcy" InfoSectionCurr:TankDensityPomi       skip   */
/*              "Vcy" InfoSectionCurr:TankVolPomi           skip   */
/*              "Mcy" InfoSectionCurr:TankWeight            skip   */
/*              "DeltaOtn_M" InfoSectionCurr:AccPomi skip .        */
/*            output stream outstream close.                       */
          end.
        end.
      end.
      when "th" then do:
          
          def var v-tank-density-pomi as decimal no-undo.
          def var v-tank-vol-pomi as decimal no-undo.
          
          if lookup (FuelType, "petrol,diesel-sum,diesel-wint") > 0
          then do:
            message
              substitute('Ошибка определения типа топлива &1 или не верный тип товлива &2', return-value, FuelType) 
            view-as alert-box error.
            undo, return error return-value .
          end.
          
          run str/rdcdnst.p (input InfoSectionCurr:TankDensityPomi * 1000
                        ,input InfoSectionCurr:DensTemp
                        ,input InfoSectionCurr:TankVol
                        ,input InfoSectionCurr:TankTemp
                        ,input FuelType
                        ,output v-tank-density-pomi 
                        ,output v-tank-vol-pomi)
          no-error.
          if not error-status:error then do:
            InfoSectionCurr:TankDensityPomi = v-tank-density-pomi.
            InfoSectionCurr:TankVolPomi = v-tank-vol-pomi.
            InfoSectionCurr:TankWeight = InfoSectionCurr:TankDensityPomi * InfoSectionCurr:TankVolPomi . 
            
/*            display                  */
/*              f-tank-vol-pomi        */
/*              f-tank-density-pomi    */
/*              f-tank-weight          */
/*            with frame {&frame-name}.*/

          end.
          else do:
            message
              substitute('Ошибка при рассчете приведенных значений плотности и объема: &1', return-value) 
            view-as alert-box error.
            undo, return no-apply  .
          end.
      end.
      when "manual" then do:
        InfoSectionCurr:TankWeight = InfoSectionCurr:TankDensityPomi * InfoSectionCurr:TankVolPomi . 
      end.
      
      
    end case.
    
    
    def var dMP  as decimal no-undo.
    def var MF   as decimal no-undo.
    def var dMF  as decimal no-undo.
    def var MTTH as decimal no-undo.
    def var md   as decimal no-undo.
    def var dmd  as decimal no-undo.
    def var dF   as decimal no-undo.
    def var NPE  as decimal no-undo.
    def var ME   as decimal no-undo.
    def var dMEd as decimal no-undo.
    
    assign
      MTTH = InfoSectionCurr:DocQnty * InfoSectionCurr:DocDensity
      MF = InfoSectionCurr:TankWeight
      dF = InfoSectionCurr:AccPomi
      NPE = NormalWastage
      dmd = MF * dF * 0.01
      dMP = MF - MTTH
      dMEd = MTTH * NPE * 0.001.
      ME = MTTH - MF - dmd.
    .
    
    if MTTH > MF
    and abs(dMP) > dmd + dMed
    then do:
      ME = dMEd.
    end.
    if ME < 0 then ME = 0 .
/*    if InfoSectionCurr:TankWeight <= 0 or InfoSectionCurr:TankWeight = ? then ME = 0 .*/
    
    InfoSectionCurr:NaturalLoss = ME.
    
    find first ub.place no-lock where ub.place.obj-type = ObjType and ub.place.obj-code = ObjCode and ub.place.loc1 = InfoSectionCurr:ListTank no-error. 
    if available (ub.place)
    then do:
      assign
        Parnl:ObjType = ObjType 
        Parnl:ObjCode = ObjCode
        Parnl:GdsCode = GdsCode
        Parnl:AutoNum = CarNum
        Parnl:OnDate = buf_trn.doc-date
      .
      
      Parnl:PlCode = ub.place.pl-code no-error.
      release ub.place.
      Parnl:SecNum = InfoSectionCurr:SectionName.
      Parnl:GroupNP = InfoSectionCurr:GroupNP.
      NLStorage:getNormLoss(Parnl).
      InfoSectionCurr:TPNormAuto = Parnl:AutoNormLoss.
      InfoSectionCurr:TPNormPL = (InfoSectionCurr:TankWeight / 1000 * ParNl:PLNormLoss).
/*      output stream log-algo to value ("log-algo-pomi.txt") append.*/
      output stream outstream to value ("pomi.log") append.
      put stream outstream unformatted
        "MTP = " InfoSectionCurr:TPNorm {&new-line}
        "NHH = " string(Parnl:AutoNormLoss) {&new-line}
        "NPR = " string(Parnl:PLNormLoss) {&new-line}.
      output stream outstream close.
    end.

  
  
  end.
  
  method public void CalcTP () :
    find first ub.place no-lock where ub.place.obj-type = ObjType and ub.place.obj-code = ObjCode and ub.place.loc1 = InfoSectionCurr:ListTank no-error. 
    if available (ub.place)
    then do:
      assign
        Parnl:ObjType = ObjType 
        Parnl:ObjCode = ObjCode
        Parnl:GdsCode = GdsCode
        Parnl:AutoNum = CarNum
        Parnl:OnDate = buf_trn.doc-date
      .
      
      Parnl:PlCode = ub.place.pl-code no-error.
      release ub.place.
      Parnl:SecNum = InfoSectionCurr:SectionName.
      Parnl:GroupNP = InfoSectionCurr:GroupNP.
      NLStorage:getNormLoss(Parnl).
      InfoSectionCurr:TPNormAuto = Parnl:AutoNormLoss.
      InfoSectionCurr:TPNormPL = (InfoSectionCurr:TankWeight / 1000 * ParNl:PLNormLoss).
      output stream log-algo to value ("log-algo-pomi.txt") append.
      put stream log-algo unformatted
        "MTP = " InfoSectionCurr:TPNorm {&new-line}
        "NHH = " string(Parnl:AutoNormLoss) {&new-line}
        "NPR = " string(Parnl:PLNormLoss) {&new-line}.
      output stream log-algo close.      
    end.
  end method .
  
  method public logical CheckNameSec (arg1 as int, arg2 as char): /*проверка на совпадения названия секция по все линиям накладной*/
      
      def var ii as int no-undo.
      
      do ii = 1 to this-object:SectionNum:
        this-object:GetInfoSectionProp(ii).
        if this-object:idSecCurr = arg1
          then next.
        if  trim (arg2) <> "" and trim (this-object:InfoSectionCurr:SectionName) = trim (arg2)
        then do:
          return false.
        end. 
      end.
      
      return not can-find (first buf_doc-line-attr no-lock where
            buf_doc-line-attr.doc-code = TrnDocNum
        and buf_doc-line-attr.gds-code <> GdsCode
        and buf_doc-line-attr.attr-code begins "section-name" 
        and trim (arg2) = trim (buf_doc-line-attr.attr-value)).
    
  end.
  
  method public void GetArea ( output NeckArea as decimal, input v-boxshape as integer, input v-size as character ):
  
    define variable v-mm as com-handle.
    define variable v-proc as character no-undo.
    define variable error-string as character no-undo.
    
    define variable vErr as character no-undo .
    define variable vWrn as character no-undo .
    define variable vDllVersion as character no-undo .
    
    define variable Diameter      as decimal no-undo .
    define variable Length        as decimal no-undo .
    define variable Width         as decimal no-undo .
    define variable Circumference as decimal no-undo .
    define variable Wall          as decimal no-undo .
    
    if not RdcDnstvalue = "pomi-rn" 
    then do:
      case v-boxshape:
        when 1 then do:
          NeckArea = decimal(entry(3, v-size, "/")) * decimal(entry(4, v-size, "/")) * 0.000001 no-error.
        end .
        when 3 then do:
          NeckArea = 3.14159 * decimal(entry(2, v-size, "/")) * decimal(entry(2, v-size, "/")) * 0.000001 / 4 no-error .
        end .
        otherwise do :
          NeckArea = 0 .
        end .
      end case .
      if NeckArea = ? then NeckArea = 0 .
      return.
    end.
    
    if v-size = ""
    or v-size = ?
    then do :
      v-size = "////" .
    end .
    
    v-proc = "CMethodOfMetering26A" .
    
    def var v-diameter as decimal no-undo.
    def var v-circumference as decimal no-undo.
    def var v-wall as decimal no-undo.
    case v-boxshape:
      when 1 then do:
        assign
          Diameter      = 0.0
          Length        = decimal (entry (3, v-size, "/"))
          Width         = decimal (entry (4, v-size, "/"))
          Circumference = 0.0
          Wall          = decimal (entry (2, v-size, "/"))
        .
      end.
      when 2 then do:
        assign
          Diameter      = 0.0
          Length        = decimal (entry (3, v-size, "/"))
          Width         = decimal (entry (4, v-size, "/"))
          Circumference = 0.0
          Wall          = decimal (entry (2, v-size, "/"))
        .
      end.
      when 3 then do:
        case true:
          when decimal (entry (3, v-size, "/")) > 0 and decimal (entry (5, v-size, "/")) > 0 then do:
            v-diameter = decimal (entry (3, v-size, "/")).
            v-wall = decimal (entry (5, v-size, "/")).
            v-circumference = 0.
          end.
          when decimal (entry (2, v-size, "/")) > 0 then do:
            v-diameter = decimal (entry (2, v-size, "/")).
            v-wall = 0.
            v-circumference = 0.
          end.
          when decimal (entry (4, v-size, "/")) > 0 then do:
            v-diameter = 0.
            v-wall = decimal (entry (5, v-size, "/")).
            v-circumference = decimal (entry (4, v-size, "/")).
            v-boxshape = 4.     
          end.
          otherwise do:
            v-diameter = if decimal (entry (3, v-size, "/")) > 0 then decimal (entry (3, v-size, "/")) else decimal (entry (2, v-size, "/")).
            v-wall = decimal (entry (5, v-size, "/")).
            v-circumference = decimal (entry (4, v-size, "/")).   
          end.
        end case.
  
        assign
          Diameter      = v-diameter
          Length        = 0.0
          Width         = 0.0
          Circumference = v-circumference
          Wall          = v-wall
        .
      end.
      when 0 then do:
        NeckArea = 0.
        return.
      end.
      otherwise do:
        message
          substitute('Неверный тип горловины')
        view-as alert-box error.
        undo, return no-apply .
      end.
    end case.
    
    MM26A
      (
      input v-boxshape,
      input Diameter,
      input Length,
      input Width,
      input Circumference,
      input Wall,
      
      output NeckArea,
      
      output vErr,
      output vWrn,
      output vDllVersion
      )
    .
    output stream outstream to value ("pomi.log") append.
    put stream outstream unformatted
      {&new-line}
      now skip
      'Процедура: '             v-proc             skip
      'Type                 = ' v-boxshape         skip
      'Diameter             = ' Diameter      skip
      'Length               = ' Length        skip
      'Width                = ' Width         skip
      'Circumference        = ' Circumference skip
      'Wall                 = ' Wall          skip
    .
    output stream outstream close.
    if trim(vErr) > "" then do :
      error-string = vErr .
      output stream outstream to value ("pomi.log") append.
        put stream outstream error-string format "x(1024)" skip.
      output stream outstream close.
      message
        substitute('Ошибка работы библиотеки ПОкМИ &1',error-string) skip
      view-as alert-box error.
      undo, return no-apply  .
    end.
    else do :
      output stream outstream to value ("pomi.log") append.
        put stream outstream
        "Area             = " string (NeckArea)      skip.
      output stream outstream close.
    end.
    
  end method.
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  destructor public InfoSectionsTotal ( ):

    clearObj().

  end destructor.
  
  { str/pokmi-dyn.i class }
  { str/calibrationbelt.i class }
  
  method public void CalcPomiRvs(
    input p-sec-num as integer,
    input p-doc-code as character,
    input p-gds-code as integer,
    input-output infoSectionTotal as class ibs.th.str.InfoSectionsTotal,
    output p-tank-weight-rvs as decimal,
    output p-tank-vol-pomi-rvs as decimal )
  :
    define buffer buf_place             for ub.place .
    define buffer buf2_place            for ub.place .
    define buffer buf_clob-bind         for ub.clob-bind .
    define buffer buf_place-attr        for ub.place-attr .
    
    define buffer bf_goods              for ub.goods .
    
    define buffer bf_bef_rvs-doc        for ub.rvs-doc  .
    define buffer bf_aft_rvs-doc        for ub.rvs-doc  .
    define buffer bf_bef_rvs-line       for ub.rvs-line .
    define buffer bf_aft_rvs-line       for ub.rvs-line .
    define buffer bf_rvs-line-attr      for ub.rvs-line-attr .
    
    define buffer buf_sr-izmerenia      for sr-izmerenia .
    define buffer dens_sr-izmerenia     for sr-izmerenia .
    define buffer temp_sr-izmerenia     for sr-izmerenia .
    define buffer level_sr-izmerenia    for sr-izmerenia .
    define buffer temp-dens_sr-izmerenia for sr-izmerenia .
    
    define buffer water1_pl-level       for ub.pl-level .
    define buffer water2_pl-level       for ub.pl-level .
    define buffer total1_pl-level       for ub.pl-level .
    define buffer total2_pl-level       for ub.pl-level .
    define buffer buf_pl-level-attr     for ub.pl-level-attr .
    define buffer buf_pl-level          for ub.pl-level .
    
    define variable CalibTable               as character no-undo initial "".
    define variable CalibBelt                as character no-undo initial "".
    define variable DeltaOtn_K               as decimal no-undo.
    define variable DeltaOtn_N               as decimal no-undo init 0.05 .
    
    define variable ToolType1                as integer no-undo.
    define variable LevelToolType1           as integer no-undo.
    define variable DeltaAbs_H1              as decimal no-undo.
    define variable DeltaAbs_H_Water1        as decimal no-undo.
    define variable DeltaAbs_R1              as decimal no-undo.
    define variable DeltaAbs_Tv1             as decimal no-undo.
    define variable DeltaAbs_Tr1             as decimal no-undo.
    define variable DeltaOtn_H1              as decimal no-undo.
    define variable DeltaOtn_H_Water1        as decimal no-undo.
    define variable DeltaOtn_R1              as decimal no-undo.
    define variable ToolAutomationLevel_H1   as integer no-undo.
    define variable ToolAutomationLevel_H_Water1 as integer no-undo.
    define variable ToolAutomationLevel_R1   as integer no-undo.
    define variable ToolAutomationLevel_Tv1  as integer no-undo.
    define variable ToolAutomationLevel_Tr1  as integer no-undo.
    define variable DeltaAbs_H_CalcType1     as integer no-undo.
    define variable DeltaAbs_H_Water_CalcType1   as integer no-undo.
    
    define variable ToolType2                as integer no-undo.
    define variable LevelToolType2           as integer no-undo.
    define variable DeltaAbs_H2              as decimal no-undo.
    define variable DeltaAbs_H_Water2        as decimal no-undo.
    define variable DeltaAbs_R2              as decimal no-undo.
    define variable DeltaAbs_Tv2             as decimal no-undo.
    define variable DeltaAbs_Tr2             as decimal no-undo.
    define variable DeltaOtn_H2              as decimal no-undo.
    define variable DeltaOtn_H_Water2        as decimal no-undo.
    define variable DeltaOtn_R2              as decimal no-undo.
    define variable ToolAutomationLevel_H2   as integer no-undo.
    define variable ToolAutomationLevel_H_Water2 as integer no-undo.
    define variable ToolAutomationLevel_R2   as integer no-undo.
    define variable ToolAutomationLevel_Tv2  as integer no-undo.
    define variable ToolAutomationLevel_Tr2  as integer no-undo.
    define variable DeltaAbs_H_CalcType2     as integer no-undo.
    define variable DeltaAbs_H_Water_CalcType2   as integer no-undo.
    
    define variable v-temp-izm-vol1         as decimal no-undo .
    define variable v-temp-izm-vol2         as decimal no-undo .
    define variable place-SI                as integer no-undo .
    define variable v-place-type            as integer no-undo .
    define variable pl-rvd-dens-1           as logical no-undo .
    define variable pl-rvd-lvl-1            as logical no-undo .
    define variable pl-rvd-temp-1           as logical no-undo .
    define variable pl-rvd-dens-2           as logical no-undo .
    define variable pl-rvd-lvl-2            as logical no-undo .
    define variable pl-rvd-temp-2           as logical no-undo .
    define variable v-mi-lvl-1              as integer no-undo .
    define variable v-mi-lvl-2              as integer no-undo .
    define variable v-mi-dnst-1             as integer no-undo .
    define variable v-mi-dnst-2             as integer no-undo .
    define variable v-mi-tmp-1              as integer no-undo .
    define variable v-mi-tmp-2              as integer no-undo .
    define variable v-mi-tmp-dnst-1         as integer no-undo .
    define variable v-mi-tmp-dnst-2         as integer no-undo .
    
    define variable DeltaV1                 as decimal no-undo .
    define variable DeltaV2                 as decimal no-undo .
    define variable WaterDeltaV1            as decimal no-undo .
    define variable WaterDeltaV2            as decimal no-undo .
    
    define variable Tv1                     as decimal no-undo .
    define variable Tr1                     as decimal no-undo .
    define variable R1                      as decimal no-undo .
    define variable Tv2                     as decimal no-undo .
    define variable Tr2                     as decimal no-undo .
    define variable R2                      as decimal no-undo .
    
    define variable temp-for-pomi           as integer no-undo.
    define variable error-string            as character no-undo.
    define variable v-is-meas               as logical no-undo.
    define variable v-mm-density            as decimal no-undo.
    
    define variable v-proc as character no-undo.
    define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].
    
    define variable v-com-tanks    as character no-undo init "":U .
    define variable v-pl-code-list as character no-undo init "":U .
    define variable ii             as integer   no-undo .
    define variable v-avg-temp     as decimal   no-undo .
    
    define variable v-ok as logical no-undo .
    define variable v-sec as character no-undo .
    define variable infoSecObj as class ibs.th.str.InfoSection no-undo .
    
    define variable v-value as character no-undo .
    
    define variable vErr as character no-undo .
    define variable vWrn as character no-undo .
    define variable vDllVersion as character no-undo .
    
    define variable V_total1   as decimal no-undo .
    define variable V_total2   as decimal no-undo .
    define variable V_water1   as decimal no-undo .
    define variable V_water2   as decimal no-undo .
    define variable Delta_V1   as decimal no-undo .
    define variable Delta_V2   as decimal no-undo .
    define variable M          as decimal no-undo . 
    define variable DeltaOtn_M as decimal no-undo .
    
    define variable v-warnings as character no-undo .
    
    _trpomi :
    do on error undo, return error :
      
      infoSecObj = infoSectionTotal:GetInfoSectionProp(p-sec-num) .
        
      v-sec = infoSecObj:SectionName .
      
      find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = {&rvs-before-doc}
                                          and bf_bef_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 3
                                          and entry(2, bf_bef_rvs-doc.rvs-code, "-") = v-sec
                                          no-error .
      if not available bf_bef_rvs-doc
      then do :
        find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = {&rvs-before-doc}
                                            and bf_bef_rvs-doc.out-code = p-doc-code
                                            and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 2
                                            no-error .
      end .
      
      find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = {&rvs-after-doc}
                                          and bf_aft_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 3 
                                          and entry(2, bf_aft_rvs-doc.rvs-code, "-") = v-sec
                                          no-error .
      if not available bf_aft_rvs-doc
      then do :
        find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = {&rvs-after-doc}
                                            and bf_aft_rvs-doc.out-code = p-doc-code
                                            and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 2
                                            no-error .
      end .
      
      if not available bf_bef_rvs-doc
      or not available bf_aft_rvs-doc
      then do :
        if infoSecObj:AccMeth = 1
        then do :
          message "Не найдены сверки по документу!" view-as alert-box error .
        end .
        undo _trpomi, return error .
      end .
      
      find first buf_place no-lock where buf_place.obj-type = infoSectionTotal:ObjType
                                     and buf_place.obj-code = infoSectionTotal:ObjCode
                                     and buf_place.loc1     = infoSecObj:ListTank
                                     and buf_place.status_  = ""
                                     no-error .
      if not available buf_place
      then do :
        message substitute("Не найден текущий резервуар с кодом &1!", infoSecObj:ListTank) view-as alert-box error .
        undo _trpomi, return error .
      end .
      
      assign v-pl-code-list = v-pl-code-list + string(buf_place.pl-code) + "," .
      
      v-ok = no .
      find first buf_place-attr no-lock where buf_place-attr.attr-code   = "place-com-tanks"
                                          and buf_place-attr.obj-code    = buf_place.obj-code
                                          and buf_place-attr.obj-type    = buf_place.obj-type
                                          and buf_place-attr.pl-code     = buf_place.pl-code no-error.
      if available buf_place-attr then do :
        v-com-tanks = buf_place-attr.attr-value .
        v-ok = yes .
      end.
      if v-ok
      and v-com-tanks > ""
      then do :
        do ii = 1 to num-entries(v-com-tanks) :
          find first buf2_place no-lock where buf2_place.obj-type = buf_place.obj-type
                                          and buf2_place.obj-code = buf_place.obj-code
                                          and buf2_place.loc1     = entry(ii, v-com-tanks)
                                          and buf2_place.status_  = ""
                                          no-error .
          if available buf2_place
          then do :
            assign v-pl-code-list = v-pl-code-list + string(buf2_place.pl-code) + "," .
          end .
        end .
      end .
      
      assign v-pl-code-list = trim(v-pl-code-list, ",") .
      assign
        p-tank-weight-rvs   = 0.0
        p-tank-vol-pomi-rvs = 0.0
      .
      
      place_ :
      do ii = 1 to num-entries(v-pl-code-list) :
        find first buf_place no-lock where buf_place.pl-code = integer(entry(ii, v-pl-code-list)) no-error .
        if not available buf_place
        then do :
          undo _trpomi, return error .
        end .
        
        assign
          CalibTable = ""
          CalibBelt  = ""
        .
        
        v-ok = no .
        find first buf_place-attr no-lock where buf_place-attr.attr-code   = "place-type"
                                            and buf_place-attr.obj-code    = buf_place.obj-code
                                            and buf_place-attr.obj-type    = buf_place.obj-type
                                            and buf_place-attr.pl-code     = buf_place.pl-code no-error.
        if available buf_place-attr then do :
          v-place-type = integer(buf_place-attr.attr-value) .
          v-ok = yes .
        end.
        
        v-proc = "CMethodOfMetering7" .
        if v-ok
        and v-place-type = 1
        then
          v-proc = "CMethodOfMetering14"
        .
        
        v-ok = no .
        place-si = ? .
        find first buf_place-attr no-lock where buf_place-attr.attr-code   = "place-SI"
                                            and buf_place-attr.obj-code    = buf_place.obj-code
                                            and buf_place-attr.obj-type    = buf_place.obj-type
                                            and buf_place-attr.pl-code     = buf_place.pl-code no-error.
        if available buf_place-attr then do :
          place-si = integer(buf_place-attr.attr-value) .
          v-ok = yes .
        end.
        
        find first bf_bef_rvs-line no-lock where bf_bef_rvs-line.rvs-code = bf_bef_rvs-doc.rvs-code
                                             and bf_bef_rvs-line.obj-type = bf_bef_rvs-doc.obj-type
                                             and bf_bef_rvs-line.obj-code = bf_bef_rvs-doc.obj-code
                                             and bf_bef_rvs-line.pl-code  = buf_place.pl-code
                                             and bf_bef_rvs-line.gds-code = p-gds-code
                                             no-error .
        if not available bf_bef_rvs-line
        then do :
          if infoSecObj:AccMeth = 1
          then do :
            message "Не заполнена сверка До!" view-as alert-box error .
          end .
          undo _trpomi, return error .
        end .
        
        if bf_bef_rvs-line.state-measure-qnty = ?
        or bf_bef_rvs-line.state-measure-qnty <= 0
        or bf_bef_rvs-line.state-measure-cli-qnty = ?
        or bf_bef_rvs-line.state-measure-cli-qnty <= 0
        or bf_bef_rvs-line.state-level-total = ?
        or bf_bef_rvs-line.state-level-total <= 0
        or bf_bef_rvs-line.state-level-water = ?
        or bf_bef_rvs-line.state-temperature = ?
        then do :
          if infoSecObj:AccMeth = 1
          then do :
            message "Не заполнена сверка До!" view-as alert-box error .
          end .
          undo _trpomi, return error .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "temp-izm-vol"
        :
          v-temp-izm-vol1 = decimal(bf_rvs-line-attr.attr-value) .
        end .
        
        find first bf_aft_rvs-line no-lock where bf_aft_rvs-line.rvs-code = bf_aft_rvs-doc.rvs-code
                                             and bf_aft_rvs-line.obj-type = bf_aft_rvs-doc.obj-type
                                             and bf_aft_rvs-line.obj-code = bf_aft_rvs-doc.obj-code
                                             and bf_aft_rvs-line.pl-code  = buf_place.pl-code
                                             and bf_aft_rvs-line.gds-code = p-gds-code
                                             no-error .
        if not available bf_aft_rvs-line
        then do :
          if infoSecObj:AccMeth = 1
          then do :
            message "Не заполнена сверка После!" view-as alert-box error .
          end .
          undo _trpomi, return error .
        end .
        
        if bf_aft_rvs-line.state-measure-qnty = ?
        or bf_aft_rvs-line.state-measure-qnty <= 0
        or bf_aft_rvs-line.state-measure-cli-qnty = ?
        or bf_aft_rvs-line.state-measure-cli-qnty <= 0
        or bf_aft_rvs-line.state-level-total = ?
        or bf_aft_rvs-line.state-level-total <= 0
        or bf_aft_rvs-line.state-level-water = ?
        or bf_aft_rvs-line.state-temperature = ?
        then do :
          if infoSecObj:AccMeth = 1
          then do :
            message "Не заполнена сверка После!" view-as alert-box error .
          end .
          undo _trpomi, return error .
        end .
        
        if bf_bef_rvs-line.state-measure-cli-qnty = bf_aft_rvs-line.state-measure-cli-qnty
        then do :
          next place_ .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "temp-izm-vol"
        :
          v-temp-izm-vol2 = decimal(bf_rvs-line-attr.attr-value) .
        end .
        
        if bf_bef_rvs-line.state-level-water > 0
        then do :
          find last water1_pl-level no-lock where water1_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                              and water1_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                              and water1_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                              and water1_pl-level.pl-level <= bf_bef_rvs-line.state-level-water
                                              no-error .
          if available water1_pl-level
          then do :
            WaterDeltaV1 = ? .
            for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                                  and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                                  and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                                  and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "deltaV"
                                                  :      
              WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
            end .
          end .
          if (available water1_pl-level 
          and water1_pl-level.pl-level <> bf_bef_rvs-line.state-level-water)
          or bf_bef_rvs-line.state-level-water < 1
          then do :
            find first water2_pl-level no-lock where water2_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                                 and water2_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                                 and water2_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                                 and water2_pl-level.pl-level >= bf_bef_rvs-line.state-level-water
                                                 no-error .
            if available water2_pl-level
            then do :
              WaterDeltaV2 = ? .
              for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                    and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                    and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                    and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                    and buf_pl-level-attr.attr-code = "deltaV"
                                                    :      
                WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
              end .
            end .
          end .
        end .  
        
        find last total1_pl-level no-lock where total1_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                            and total1_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                            and total1_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                            and total1_pl-level.pl-level <= bf_bef_rvs-line.state-level-total
                                            no-error . 
        if not available total1_pl-level
        then do :
          if bf_bef_rvs-line.state-level-total >= 1
          then do :
            find first bf_goods no-lock where bf_goods.gds-code = bf_bef_rvs-line.gds-code no-error .
            message 
              substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                         ,(if available buf_place then buf_place.loc1 else "?")
                         ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                         ,(if available bf_goods then bf_goods.gds-name else "?") )
            view-as alert-box .
            undo _trpomi, return .
          end .
        end .
        
        DeltaOtn_K = ? .                                    
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "tarir-delta"
                                              :      
          DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) . 
        end .   
        if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .   
        
        DeltaV1 = ? .                                    
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :      
          DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
        end . 
                                   
        find first total2_pl-level no-lock where total2_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                            and total2_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                            and total2_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                            and total2_pl-level.pl-level > bf_bef_rvs-line.state-level-total
                                            no-error .   
        if not available total2_pl-level
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_bef_rvs-line.gds-code no-error .
          message 
            substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                       ,(if available buf_place then buf_place.loc1 else "?")
                       ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                       ,(if available bf_goods then bf_goods.gds-name else "?") )
          view-as alert-box .
          undo _trpomi, return .
        end .   
        
        DeltaV2 = ? .                                    
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :      
          DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
        end .  
            
        if available water2_pl-level
        then do :
          CalibTable = Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + {&new-line} + CalibTable .
        end .                              
        if available water1_pl-level
        then do :
          CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + {&new-line} + CalibTable .
        end . 
        if available total1_pl-level
        then do :
          CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + {&new-line} . 
        end .
        CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") + {&new-line} .
    
        if bf_bef_rvs-line.state-level-total < 1
        or bf_bef_rvs-line.state-level-water < 1
        then do :
          find first buf_pl-level no-lock where buf_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                           and buf_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                           and buf_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                           and buf_pl-level.pl-level = 0
                                           no-error .
          if not available buf_pl-level
          then do :
            CalibTable = "0=0" + {&new-line} + CalibTable .
          end .                                  
        end .
        
        if bf_aft_rvs-line.state-level-water > 0
        and bf_aft_rvs-line.state-level-water <> bf_bef_rvs-line.state-level-water
        then do :
          find last water1_pl-level no-lock where water1_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                              and water1_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                              and water1_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                              and water1_pl-level.pl-level <= bf_aft_rvs-line.state-level-water
                                              no-error .
          if available water1_pl-level
          then do :
            WaterDeltaV1 = ? .
            for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                                  and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                                  and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                                  and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "deltaV"
                                                  :      
              WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
            end .
          end .
          if (available water1_pl-level 
          and water1_pl-level.pl-level <> bf_aft_rvs-line.state-level-water)
          or bf_aft_rvs-line.state-level-water < 1
          then do :
            find first water2_pl-level no-lock where water2_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                                 and water2_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                                 and water2_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                                 and water2_pl-level.pl-level >= bf_aft_rvs-line.state-level-water
                                                 no-error .
            if available water2_pl-level
            then do :
              WaterDeltaV2 = ? .
              for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                    and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                    and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                    and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                    and buf_pl-level-attr.attr-code = "deltaV"
                                                    :      
                WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
              end .
            end .
          end .
        end .  
        
        find last total1_pl-level no-lock where total1_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                            and total1_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                            and total1_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                            and total1_pl-level.pl-level <= bf_aft_rvs-line.state-level-total
                                            no-error . 
        if not available total1_pl-level
        then do :
          if bf_aft_rvs-line.state-level-total >= 1
          then do :
            find first bf_goods no-lock where bf_goods.gds-code = bf_aft_rvs-line.gds-code no-error .
            message 
              substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                         ,(if available buf_place then buf_place.loc1 else "?")
                         ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                         ,(if available bf_goods then bf_goods.gds-name else "?") )
            view-as alert-box .
            undo _trpomi, return .
          end .
        end .
        
        DeltaOtn_K = ? .                                    
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "tarir-delta"
                                              :      
          DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) . 
        end .   
        if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .       
        
        DeltaV1 = ? .                                    
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :      
          DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
        end . 
                               
        find first total2_pl-level no-lock where total2_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                            and total2_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                            and total2_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                            and total2_pl-level.pl-level > bf_aft_rvs-line.state-level-total
                                            no-error .   
        if not available total2_pl-level
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_aft_rvs-line.gds-code no-error .
          message 
            substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                       ,(if available buf_place then buf_place.loc1 else "?")
                       ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                       ,(if available bf_goods then bf_goods.gds-name else "?") )
          view-as alert-box .
          undo _trpomi, return .
        end . 
        
        DeltaV2 = ? .                                    
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :      
          DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
        end .  
                                        
        if available water2_pl-level
        then do :
          CalibTable = Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + {&new-line} + CalibTable .
        end .  
        if available water1_pl-level
        then do :
          CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + {&new-line} + CalibTable .
        end . 
        if available total1_pl-level
        then do :
          CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + {&new-line} . 
        end .
        CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") .     
        
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "input-type-p"
        :
          if bf_rvs-line-attr.attr-value = "р"
          or bf_rvs-line-attr.attr-value = "ак"
          or bf_rvs-line-attr.attr-value = "фк"
          then do :
            pl-rvd-dens-1 = yes .
          end .
          else do :
            pl-rvd-dens-1 = no .
          end .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "input-type-p"
        :
          if bf_rvs-line-attr.attr-value = "р"
          or bf_rvs-line-attr.attr-value = "ак"
          or bf_rvs-line-attr.attr-value = "фк"
          then do :
            pl-rvd-dens-2 = yes .
          end .
          else do :
            pl-rvd-dens-2 = no .
          end .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "input-type-t"
        :
          if bf_rvs-line-attr.attr-value = "р"
          or bf_rvs-line-attr.attr-value = "ак"
          or bf_rvs-line-attr.attr-value = "фк"
          then do :
            pl-rvd-temp-1 = yes .
          end .
          else do :
            pl-rvd-temp-1 = no .
          end .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "input-type-t"
        :
          if bf_rvs-line-attr.attr-value = "р"
          or bf_rvs-line-attr.attr-value = "ак"
          or bf_rvs-line-attr.attr-value = "фк"
          then do :
            pl-rvd-temp-2 = yes .
          end .
          else do :
            pl-rvd-temp-2 = no .
          end .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "input-type-l"
        :
          if bf_rvs-line-attr.attr-value = "р"
          or bf_rvs-line-attr.attr-value = "ак"
          or bf_rvs-line-attr.attr-value = "фк"
          then do :
            pl-rvd-lvl-1 = yes .
          end .
          else do :
            pl-rvd-lvl-1 = no .
          end .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "input-type-l"
        :
          if bf_rvs-line-attr.attr-value = "р"
          or bf_rvs-line-attr.attr-value = "ак"
          or bf_rvs-line-attr.attr-value = "фк"
          then do :
            pl-rvd-lvl-2 = yes .
          end .
          else do :
            pl-rvd-lvl-2 = no .
          end .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-lvl"
        :
          v-mi-lvl-1 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-lvl"
        :
          v-mi-lvl-2 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-dnst"
        :
          v-mi-dnst-1 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-dnst"
        :
          v-mi-dnst-2 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-tmp"
        :
          v-mi-tmp-1 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-tmp"
        :
          v-mi-tmp-2 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-tmp-dnst"
        :
          v-mi-tmp-dnst-1 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "mi-tmp-dnst"
        :
          v-mi-tmp-dnst-2 = integer(bf_rvs-line-attr.attr-value) .
        end .
        
        if pl-rvd-lvl-1 and v-mi-lvl-1 > 0 and pl-rvd-lvl-2 and v-mi-lvl-2 > 0
        and pl-rvd-dens-1 and v-mi-dnst-1 > 0 and pl-rvd-dens-2 and v-mi-dnst-2 > 0
        and pl-rvd-temp-1 and v-mi-tmp-1 > 0 and pl-rvd-temp-2 and v-mi-tmp-2 > 0
        then do : end .
        else do :
          if place-si = 0
          or place-si = ?
          then do :
            message
              substitute ("Для складского места &1 не заданно средство измерения",buf_place.pl-code)
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
            if not available buf_sr-izmerenia then do :
              message
              "Ошибка работы с библиотекой ПОкМИ"
              substitute( 'Не найдено средство измерения с кодом &1', place-si ) skip
              view-as alert-box error.
              undo _trpomi, return error.
            end.
            else do :
              assign
                ToolType1               = buf_sr-izmerenia.sr-type-id
                LevelToolType1          = buf_sr-izmerenia.sr-type-level-measuring
                ToolAutomationLevel_H1  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                ToolAutomationLevel_H_Water1 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_H1             = buf_sr-izmerenia.sr-abs-err-neft-water
                DeltaAbs_H_Water1       = buf_sr-izmerenia.sr-abs-err-water
                ToolAutomationLevel_R1  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_R1             = buf_sr-izmerenia.sr-abs-err-dens
                ToolAutomationLevel_Tv1 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_Tv1            = buf_sr-izmerenia.sr-abs-err-temp-vol
                ToolAutomationLevel_Tr1 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_Tr1            = buf_sr-izmerenia.sr-abs-err-temp-dens
                DeltaOtn_H1             = buf_sr-izmerenia.sr-relative-err-neft-water
                DeltaOtn_H_Water1       = buf_sr-izmerenia.sr-relative-err-water
                DeltaOtn_R1             = buf_sr-izmerenia.sr-relative-err-dens
                DeltaAbs_H_CalcType1    = buf_sr-izmerenia.sr-type-level-measuring + 1
                DeltaAbs_H_Water_CalcType1 = buf_sr-izmerenia.sr-type-level-measuring + 1
                
                ToolType2               = buf_sr-izmerenia.sr-type-id
                LevelToolType2          = buf_sr-izmerenia.sr-type-level-measuring
                ToolAutomationLevel_H2  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                ToolAutomationLevel_H_Water2 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_H2             = buf_sr-izmerenia.sr-abs-err-neft-water
                DeltaAbs_H_Water2       = buf_sr-izmerenia.sr-abs-err-water
                ToolAutomationLevel_R2  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_R2             = buf_sr-izmerenia.sr-abs-err-dens
                ToolAutomationLevel_Tv2 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_Tv2            = buf_sr-izmerenia.sr-abs-err-temp-vol
                ToolAutomationLevel_Tr2 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
                DeltaAbs_Tr2            = buf_sr-izmerenia.sr-abs-err-temp-dens
                DeltaOtn_H2             = buf_sr-izmerenia.sr-relative-err-neft-water
                DeltaOtn_H_Water2       = buf_sr-izmerenia.sr-relative-err-water
                DeltaOtn_R2             = buf_sr-izmerenia.sr-relative-err-dens
                DeltaAbs_H_CalcType2    = buf_sr-izmerenia.sr-type-level-measuring + 1
                DeltaAbs_H_Water_CalcType2 = buf_sr-izmerenia.sr-type-level-measuring + 1
                
                DeltaOtn_N              = 0.05
              .
            end.
          end.
        end.
        
        if (pl-rvd-lvl-1
        and v-mi-lvl-1 > 0
        and v-mi-lvl-1 <> place-si)
        or not available buf_sr-izmerenia
        then do :
          find first level_sr-izmerenia no-lock where level_sr-izmerenia.node-code = v-mi-lvl-1 no-error.
          if not available level_sr-izmerenia then do :
            message
            "Ошибка работы с библиотекой ПОкМИ"
            substitute( 'Не найдено средство измерения с кодом &1', v-mi-lvl-1 ) skip
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            assign
              DeltaAbs_H1                  = level_sr-izmerenia.sr-abs-err-neft-water
              DeltaAbs_H_Water1            = level_sr-izmerenia.sr-abs-err-water
              DeltaOtn_H1                  = level_sr-izmerenia.sr-relative-err-neft-water
              DeltaOtn_H_Water1            = level_sr-izmerenia.sr-relative-err-water
              LevelToolType1               = level_sr-izmerenia.sr-type-level-measuring 
              ToolAutomationLevel_H1       = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
              ToolAutomationLevel_H_Water1 = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_H_CalcType1         = level_sr-izmerenia.sr-type-level-measuring + 1
              DeltaAbs_H_Water_CalcType1   = level_sr-izmerenia.sr-type-level-measuring + 1
            .
          end.
        end .
        
        if (pl-rvd-lvl-2
        and v-mi-lvl-2 > 0
        and v-mi-lvl-2 <> place-si)
        or not available buf_sr-izmerenia
        then do :
          find first level_sr-izmerenia no-lock where level_sr-izmerenia.node-code = v-mi-lvl-2 no-error.
          if not available level_sr-izmerenia then do :
            message
            "Ошибка работы с библиотекой ПОкМИ"
            substitute( 'Не найдено средство измерения с кодом &1', v-mi-lvl-2 ) skip
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            assign
              DeltaAbs_H2                  = level_sr-izmerenia.sr-abs-err-neft-water
              DeltaAbs_H_Water2            = level_sr-izmerenia.sr-abs-err-water
              DeltaOtn_H2                  = level_sr-izmerenia.sr-relative-err-neft-water
              DeltaOtn_H_Water2            = level_sr-izmerenia.sr-relative-err-water
              LevelToolType2               = level_sr-izmerenia.sr-type-level-measuring 
              ToolAutomationLevel_H2       = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
              ToolAutomationLevel_H_Water2 = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_H_CalcType2         = level_sr-izmerenia.sr-type-level-measuring + 1
              DeltaAbs_H_Water_CalcType2   = level_sr-izmerenia.sr-type-level-measuring + 1
            .
          end.
        end .
        
        if (pl-rvd-dens-1
        and v-mi-dnst-1 > 0
        and v-mi-dnst-1 <> place-si)
        or not available buf_sr-izmerenia
        then do :
          find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst-1 no-error.
          if not available dens_sr-izmerenia then do :
            message
            "Ошибка работы с библиотекой ПОкМИ"
            substitute( 'Не найдено средство измерения с кодом &1', v-mi-dnst-1 ) skip
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            assign
              ToolType1               = dens_sr-izmerenia.sr-type-id
              DeltaAbs_R1             = dens_sr-izmerenia.sr-abs-err-dens
              DeltaOtn_R1             = dens_sr-izmerenia.sr-relative-err-dens
              ToolAutomationLevel_R1  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1]
            .
          end.
        end .
        
        if (pl-rvd-dens-2
        and v-mi-dnst-2 > 0
        and v-mi-dnst-2 <> place-si)
        or not available buf_sr-izmerenia
        then do :
          find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst-2 no-error.
          if not available dens_sr-izmerenia then do :
            message
            "Ошибка работы с библиотекой ПОкМИ"
            substitute( 'Не найдено средство измерения с кодом &1', v-mi-dnst-2 ) skip
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            assign
              ToolType2               = dens_sr-izmerenia.sr-type-id
              DeltaAbs_R2             = dens_sr-izmerenia.sr-abs-err-dens
              DeltaOtn_R2             = dens_sr-izmerenia.sr-relative-err-dens
              ToolAutomationLevel_R2  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1]
            .
          end.
        end .
        
        if (pl-rvd-temp-1
        and v-mi-tmp-1 > 0
        and v-mi-tmp-1 <> place-si) 
        or not available buf_sr-izmerenia
        then do :
          find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp-1 no-error.
          if not available temp_sr-izmerenia then do :
            message
            "Ошибка работы с библиотекой ПОкМИ"
            substitute( 'Не найдено средство измерения с кодом &1', v-mi-tmp-1 ) skip
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            assign
              DeltaAbs_Tv1            = temp_sr-izmerenia.sr-abs-err-temp-vol
              DeltaAbs_Tr1            = temp_sr-izmerenia.sr-abs-err-temp-dens
              ToolAutomationLevel_Tr1 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
              ToolAutomationLevel_Tv1 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
            .
          end.
        end .
        
        if (pl-rvd-temp-2
        and v-mi-tmp-2 > 0
        and v-mi-tmp-2 <> place-si) 
        or not available buf_sr-izmerenia
        then do :
          find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp-2 no-error.
          if not available temp_sr-izmerenia then do :
            message
            "Ошибка работы с библиотекой ПОкМИ"
            substitute( 'Не найдено средство измерения с кодом &1', v-mi-tmp-2 ) skip
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            assign
              DeltaAbs_Tv2            = temp_sr-izmerenia.sr-abs-err-temp-vol
              DeltaAbs_Tr2            = temp_sr-izmerenia.sr-abs-err-temp-dens
              ToolAutomationLevel_Tr2 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
              ToolAutomationLevel_Tv2 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
            .
          end.
        end .
        
        if v-mi-tmp-dnst-1 > 0
        and v-mi-tmp-dnst-1 <> v-mi-tmp-1
        then do :
          for first temp-dens_sr-izmerenia no-lock where temp-dens_sr-izmerenia.node-code = v-mi-tmp-dnst-1 :
            assign 
              DeltaAbs_Tr1 = temp-dens_sr-izmerenia.sr-abs-err-temp-dens when temp-dens_sr-izmerenia.sr-abs-err-temp-dens > 0
              ToolAutomationLevel_Tr1 = vAutomationDegree[temp-dens_sr-izmerenia.sr-type-izm + 1]
            .
          end .
        end .
        
        if v-mi-tmp-dnst-2 > 0
        and v-mi-tmp-dnst-2 <> v-mi-tmp-2
        then do :
          for first temp-dens_sr-izmerenia no-lock where temp-dens_sr-izmerenia.node-code = v-mi-tmp-dnst-2 :
            assign 
              DeltaAbs_Tr2 = temp-dens_sr-izmerenia.sr-abs-err-temp-dens when temp-dens_sr-izmerenia.sr-abs-err-temp-dens > 0
              ToolAutomationLevel_Tr2 = vAutomationDegree[temp-dens_sr-izmerenia.sr-type-izm + 1]
            .
          end .
        end .
        
        CalibBelt = getCalibrationBelt( buf_place.obj-type, 
                                        buf_place.obj-code,
                                        buf_place.pl-code,
                                        bf_bef_rvs-line.state-level-total,
                                        bf_bef_rvs-line.state-level-water
                                       ).
        CalibBelt = CalibBelt + {&new-line} + getCalibrationBelt( buf_place.obj-type, 
                                                                  buf_place.obj-code,
                                                                  buf_place.pl-code,
                                                                  bf_aft_rvs-line.state-level-total,
                                                                  bf_aft_rvs-line.state-level-water
                                                                 ).
        
        if DeltaAbs_H1       = ? then DeltaAbs_H1 = 0 .
        if DeltaAbs_H_Water1 = ? then DeltaAbs_H_Water1 = 0 .
        if DeltaAbs_R1       = ? then DeltaAbs_R1 = 0 .
        if DeltaAbs_Tv1      = ? then DeltaAbs_Tv1 = 0 .
        if DeltaAbs_Tr1      = ? then DeltaAbs_Tr1 = 0 .
        if DeltaOtn_H1       = ? then DeltaOtn_H1 = 0 .
        if DeltaOtn_H_Water1 = ? then DeltaOtn_H_Water1 = 0 .
        if DeltaOtn_R1       = ? then DeltaOtn_R1 = 0 .
        if LevelToolType1    = ? then LevelToolType1 = 0 .
        if ToolType1         = ? then ToolType1 = 0 .
        if ToolAutomationLevel_Tr1      = ? then ToolAutomationLevel_Tr1 =0.
        if ToolAutomationLevel_H1       = ? then ToolAutomationLevel_H1 = 0.
        if ToolAutomationLevel_H_Water1 = ? then ToolAutomationLevel_H_Water1 = 0.
        if ToolAutomationLevel_Tv1      = ? then ToolAutomationLevel_Tv1 = 0.
        if ToolAutomationLevel_R1       = ? then ToolAutomationLevel_R1 = 0.
        if DeltaAbs_H_CalcType1         = ? then DeltaAbs_H_CalcType1 = 0.
        if DeltaAbs_H_Water_CalcType1   = ? then DeltaAbs_H_Water_CalcType1 = 0.
        
        if DeltaAbs_H2       = ? then DeltaAbs_H2 = 0 .
        if DeltaAbs_H_Water2 = ? then DeltaAbs_H_Water2 = 0 .
        if DeltaAbs_R2       = ? then DeltaAbs_R2 = 0 .
        if DeltaAbs_Tv2      = ? then DeltaAbs_Tv2 = 0 .
        if DeltaAbs_Tr2      = ? then DeltaAbs_Tr2 = 0 .
        if DeltaOtn_H2       = ? then DeltaOtn_H2 = 0 .
        if DeltaOtn_H_Water2 = ? then DeltaOtn_H_Water2 = 0 .
        if DeltaOtn_R2       = ? then DeltaOtn_R2 = 0 .
        if LevelToolType2    = ? then LevelToolType2 = 0 .
        if ToolType2         = ? then ToolType2 = 0 .
        if ToolAutomationLevel_Tr2      = ? then ToolAutomationLevel_Tr2 =0.
        if ToolAutomationLevel_H2       = ? then ToolAutomationLevel_H2 = 0.
        if ToolAutomationLevel_H_Water2 = ? then ToolAutomationLevel_H_Water2 = 0.
        if ToolAutomationLevel_Tv2      = ? then ToolAutomationLevel_Tv2 = 0.
        if ToolAutomationLevel_R2       = ? then ToolAutomationLevel_R2 = 0.
        if DeltaAbs_H_CalcType2         = ? then DeltaAbs_H_CalcType2 = 0.
        if DeltaAbs_H_Water_CalcType2   = ? then DeltaAbs_H_Water_CalcType2 = 0.
        
        if bf_bef_rvs-line.state-level-water = 0
        then do :
          ToolAutomationLevel_H_Water1 = 0 .
          DeltaAbs_H_Water_CalcType1 = 0 .
          DeltaAbs_H_Water1 = 0 .
        end .
        
        if bf_aft_rvs-line.state-level-water = 0
        then do :
          ToolAutomationLevel_H_Water2 = 0 .
          DeltaAbs_H_Water_CalcType2 = 0 .
          DeltaAbs_H_Water2 = 0 .
        end .
        
        if LevelToolType1 > 0
        then do :
          MM57
            (input bf_bef_rvs-line.state-level-total * 10,
             input LevelToolType1,
             output DeltaAbs_H1,
             output vErr,
             output vWrn,
             output vDllVersion)
          .  
          OUTPUT stream outstream to value ("pomi.log") append.
          PUT STREAM outstream unformatted
                      "    " SKIP
                      "    " SKIP
                      now   SKIP
                      'Процедура             "CMethodOfMetering57"'       SKIP
                      'Версия dll: '            vDllVersion   skip
                      'CODE_PL                = ' buf_place.pl-code                           SKIP
                      'H                      = ' bf_bef_rvs-line.state-level-total * 10                  SKIP
                      'ToolType               = ' LevelToolType1                                      SKIP
                          SKIP SKIP 
          .
          output stream outstream close.
            
          if trim(vErr) > "" then do :
            output stream outstream to value ("pomi.log")  append.
            put stream outstream vErr format "X(1024)" skip.
            output stream outstream close.
            message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
            undo _trpomi, return error .
          end.
          else do :
            OUTPUT stream outstream to value ("pomi.log")  append.
            PUT STREAM outstream unformatted
                "DeltaAbs_H = " DeltaAbs_H1  SKIP
            .
            OUTPUT stream outstream close.
          end .
        end . /* LevelToolType1 > 0 */
        
        if LevelToolType2 > 0
        then do :
          MM57
            (input bf_aft_rvs-line.state-level-total * 10,
             input LevelToolType2,
             output DeltaAbs_H2,
             output vErr,
             output vWrn,
             output vDllVersion)
          .  
          OUTPUT stream outstream to value ("pomi.log") append.
          PUT STREAM outstream unformatted
                      "    " SKIP
                      "    " SKIP
                      now   SKIP
                      'Процедура             "CMethodOfMetering57"'       SKIP
                      'Версия dll: '            vDllVersion   skip
                      'CODE_PL                = ' buf_place.pl-code                           SKIP
                      'H                      = ' bf_aft_rvs-line.state-level-total * 10                  SKIP
                      'ToolType               = ' LevelToolType2                                      SKIP
                          SKIP SKIP 
          .
          output stream outstream close.
            
          if trim(vErr) > "" then do :
            output stream outstream to value ("pomi.log")  append.
            put stream outstream vErr format "X(1024)" skip.
            output stream outstream close.
            message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
            undo _trpomi, return error .
          end.
          else do :
            OUTPUT stream outstream to value ("pomi.log")  append.
            PUT STREAM outstream unformatted
                "DeltaAbs_H = " DeltaAbs_H2  SKIP
            .
            OUTPUT stream outstream close.
          end .
        end . /* LevelToolType2 > 0 */
        
        assign
          Tr1 = bf_bef_rvs-line.state-temperature
          Tv1 = if v-temp-izm-vol1 <> ? then v-temp-izm-vol1 else bf_bef_rvs-line.state-temperature 
          R1  = ( bf_bef_rvs-line.state-density * 1000 )
          
          Tr2 = bf_aft_rvs-line.state-temperature
          Tv2 = if v-temp-izm-vol2 <> ? then v-temp-izm-vol2 else bf_aft_rvs-line.state-temperature 
          R2  = ( bf_aft_rvs-line.state-density * 1000 )
        .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "Tr"
        :
          assign Tr1 = decimal(bf_rvs-line-attr.attr-value) .
        end .
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "Tv"
        :
          assign Tv1 = decimal(bf_rvs-line-attr.attr-value) .
        end .
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "R"
        :
          assign R1 = decimal(bf_rvs-line-attr.attr-value) * 1000 .
        end .
        
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "Tr"
        :
          assign Tr2 = decimal(bf_rvs-line-attr.attr-value) .
        end .
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "Tv"
        :
          assign Tv2 = decimal(bf_rvs-line-attr.attr-value) .
        end .
        for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                             and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                             and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                             and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                             and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                             and bf_rvs-line-attr.attr-code = "R"
        :
          assign R2 = decimal(bf_rvs-line-attr.attr-value) * 1000 .
        end .
        
        if v-proc = "CMethodOfMetering14"
        then do :
          MM14
          (input bf_bef_rvs-line.state-measure-cli-qnty,
           input bf_aft_rvs-line.state-measure-cli-qnty,
           input bf_bef_rvs-line.state-level-total * 10,
           input bf_aft_rvs-line.state-level-total * 10,
           input if bf_bef_rvs-line.state-level-water <> ? then bf_bef_rvs-line.state-level-water * 10 else 0.0,
           input if bf_aft_rvs-line.state-level-water <> ? then bf_aft_rvs-line.state-level-water * 10 else 0.0,
           input CalibTable,
           input CalibBelt,
           input Tv1,
           input Tv2,
           input Tr1,
           input Tr2,
           input R1,
           input R2,
           input ToolType1,
           input ToolType2,
           input DeltaOtn_K,
           input 2,  /* OperDirection 2 = приём продукта */
           input ToolAutomationLevel_H1,
           input ToolAutomationLevel_H2,
           input ToolAutomationLevel_H_Water1,
           input ToolAutomationLevel_H_Water2,
           input ToolAutomationLevel_R1,
           input ToolAutomationLevel_R2,
           input ToolAutomationLevel_Tv1,
           input ToolAutomationLevel_Tv2,
           input ToolAutomationLevel_Tr1,
           input ToolAutomationLevel_Tr2,
           input DeltaAbs_H_CalcType1,
           input DeltaAbs_H_CalcType2,
           input DeltaAbs_H_Water_CalcType1,
           input DeltaAbs_H_Water_CalcType2,
           input DeltaAbs_H1,
           input DeltaAbs_H2,
           input DeltaAbs_H_Water1,
           input DeltaAbs_H_Water2,
           input DeltaAbs_R1,
           input DeltaAbs_R2,
           input DeltaAbs_Tv1,
           input DeltaAbs_Tv2,
           input DeltaAbs_Tr1,
           input DeltaAbs_Tr2,
           input DeltaOtn_N,
           input 1, /* Round_M */
           input 2, /* Round_T */
           input 2, /* Round_R */
           
           output V_total1,
           output V_total2,
           output V_water1,
           output V_water2,
           output Delta_V1,
           output Delta_V2,
           output M,
           output DeltaOtn_M,
           
           output vErr,
           output vWrn,
           output vDllVersion)
          no-error .
        end .
        else do :
          MM7
          (input bf_bef_rvs-line.state-measure-cli-qnty,
           input bf_aft_rvs-line.state-measure-cli-qnty,
           input bf_bef_rvs-line.state-level-total * 10,
           input bf_aft_rvs-line.state-level-total * 10,
           input if bf_bef_rvs-line.state-level-water <> ? then bf_bef_rvs-line.state-level-water * 10 else 0.0,
           input if bf_aft_rvs-line.state-level-water <> ? then bf_aft_rvs-line.state-level-water * 10 else 0.0,
           input CalibTable,
           input CalibBelt,
           input Tv1,
           input Tv2,
           input Tr1,
           input Tr2,
           input R1,
           input R2,
           input ToolType1,
           input ToolType2,
           input DeltaOtn_K,
           input 2,  /* OperDirection 2 = приём продукта */
           input ToolAutomationLevel_H1,
           input ToolAutomationLevel_H2,
           input ToolAutomationLevel_H_Water1,
           input ToolAutomationLevel_H_Water2,
           input ToolAutomationLevel_R1,
           input ToolAutomationLevel_R2,
           input ToolAutomationLevel_Tv1,
           input ToolAutomationLevel_Tv2,
           input ToolAutomationLevel_Tr1,
           input ToolAutomationLevel_Tr2,
           input DeltaAbs_H_CalcType1,
           input DeltaAbs_H_CalcType2,
           input DeltaAbs_H_Water_CalcType1,
           input DeltaAbs_H_Water_CalcType2,
           input DeltaAbs_H1,
           input DeltaAbs_H2,
           input DeltaAbs_H_Water1,
           input DeltaAbs_H_Water2,
           input DeltaAbs_R1,
           input DeltaAbs_R2,
           input DeltaAbs_Tv1,
           input DeltaAbs_Tv2,
           input DeltaAbs_Tr1,
           input DeltaAbs_Tr2,
           input DeltaOtn_N,
           input 1, /* Round_M */
           input 2, /* Round_T */
           input 2, /* Round_R */
           
           output V_total1,
           output V_total2,
           output V_water1,
           output V_water2,
           output Delta_V1,
           output Delta_V2,
           output M,
           output DeltaOtn_M,
           
           output vErr,
           output vWrn,
           output vDllVersion)
          no-error .
        end .
         
        output stream outstream to value ("pomi.log") append.
        put stream outstream unformatted
          "    " SKIP
          "    " SKIP
          now   SKIP
          'Процедура'                 v-proc                      FORMAT "x(128)"    SKIP
          'Версия dll: '              vDllVersion                            SKIP
          'CODE_PL                      = ' buf_place.pl-code                        SKIP
          'M1                           = ' bf_bef_rvs-line.state-measure-cli-qnty  SKIP
          'M2                           = ' bf_aft_rvs-line.state-measure-cli-qnty  SKIP
          'H1                           = ' bf_bef_rvs-line.state-level-total * 10  SKIP
          'H2                           = ' bf_aft_rvs-line.state-level-total * 10  SKIP
          'H1_water                     = ' if bf_bef_rvs-line.state-level-water <> ? then bf_bef_rvs-line.state-level-water * 10 else 0.0 SKIP
          'H2_water                     = ' if bf_aft_rvs-line.state-level-water <> ? then bf_aft_rvs-line.state-level-water * 10 else 0.0 SKIP
          'CalibrationTable             = ' CalibTable                    SKIP
          'CalibrationBelt              = ' CalibBelt                     SKIP
          'Tv1                          = ' Tv1                                 SKIP
          'Tv2                          = ' Tv2                                 SKIP
          'Tr1                          = ' Tr1                                 SKIP
          'Tr2                          = ' Tr2                                 skip
          'R1                           = ' trim(string(R1, ">>>9.9<"))         SKIP
          'R2                           = ' trim(string(R2, ">>>9.9<"))         SKIP
          'ToolType1                    = ' ToolType1                           SKIP
          'ToolType2                    = ' ToolType2                           SKIP
          'DeltaOtn_K                   = ' DeltaOtn_K                          SKIP
          'OperDirection                = ' 2                                   SKIP
          'ToolAutomationLevel_H1       = ' ToolAutomationLevel_H1              SKIP
          'ToolAutomationLevel_H2       = ' ToolAutomationLevel_H2              SKIP
          'ToolAutomationLevel_H_Water1 = ' ToolAutomationLevel_H_Water1        SKIP
          'ToolAutomationLevel_H_Water2 = ' ToolAutomationLevel_H_Water2        SKIP
          'ToolAutomationLevel_R1       = ' ToolAutomationLevel_R1              SKIP
          'ToolAutomationLevel_R2       = ' ToolAutomationLevel_R2              SKIP
          'ToolAutomationLevel_Tv1      = ' ToolAutomationLevel_Tv1             SKIP 
          'ToolAutomationLevel_Tv2      = ' ToolAutomationLevel_Tv2             SKIP 
          'ToolAutomationLevel_Tr1      = ' ToolAutomationLevel_Tr1             SKIP 
          'ToolAutomationLevel_Tr2      = ' ToolAutomationLevel_Tr2             SKIP 
          'DeltaAbs_H_CalcType1         = ' DeltaAbs_H_CalcType1                SKIP 
          'DeltaAbs_H_CalcType2         = ' DeltaAbs_H_CalcType2                SKIP 
          'DeltaAbs_H_Water_CalcType1   = ' DeltaAbs_H_Water_CalcType1          SKIP 
          'DeltaAbs_H_Water_CalcType2   = ' DeltaAbs_H_Water_CalcType2          SKIP 
          'DeltaAbs_H1                  = ' DeltaAbs_H1                         SKIP 
          'DeltaAbs_H2                  = ' DeltaAbs_H2                         SKIP 
          'DeltaAbs_H_Water1            = ' DeltaAbs_H_Water1                   SKIP 
          'DeltaAbs_H_Water2            = ' DeltaAbs_H_Water2                   SKIP 
          'DeltaAbs_R1                  = ' DeltaAbs_R1                         SKIP 
          'DeltaAbs_R2                  = ' DeltaAbs_R2                         SKIP 
          'DeltaAbs_Tv1                 = ' DeltaAbs_Tv1                        SKIP 
          'DeltaAbs_Tv2                 = ' DeltaAbs_Tv2                        SKIP 
          'DeltaAbs_Tr1                 = ' DeltaAbs_Tr1                        SKIP 
          'DeltaAbs_Tr2                 = ' DeltaAbs_Tr2                        SKIP 
          'DeltaOtn_N                   = ' DeltaOtn_N                          SKIP 
        .
        output stream outstream close.
        
        if trim(vErr) > "" then do :
          error-string = vErr .
          output stream outstream to value ("pomi.log")  append.
          put stream outstream error-string format "X(1024)" skip.
          error-string = replace(error-string, ";", (";" + {&new-line})) .
          message
          substitute('Ошибка работы библиотеки ПОкМИ. &1&2', {&new-line}, error-string)
          view-as alert-box error.
          output stream outstream close .
          undo _trpomi, return error .
        end.  
        
        output stream outstream to value ("pomi.log") append.
        if not (M = 0.0)
        then do :
          put stream outstream unformatted
            'V_total1                   = ' V_total1                          SKIP 
            'V_total2                   = ' V_total2                          SKIP 
            'V_water1                   = ' V_water1                          SKIP 
            'V_water2                   = ' V_water2                          SKIP
            'Delta_V1                   = ' Delta_V1                          SKIP 
            'Delta_V2                   = ' Delta_V2                          SKIP 
            'M                          = ' M                                 SKIP 
            'DeltaOtn_M                 = ' DeltaOtn_M                        SKIP 
            'Warnings                   = ' vWrn                              SKIP
          .
        end .
        else do :
          put stream outstream unformatted
            'V_total1                   = ' V_total1                          SKIP 
            'V_total2                   = ' V_total2                          SKIP 
            'V_water1                   = ' V_water1                          SKIP 
            'V_water2                   = ' V_water2                          SKIP
            'Delta_V1                   = ' Delta_V1                          SKIP 
            'Delta_V2                   = ' Delta_V2                          SKIP 
            'M                          = ' M                                 SKIP 
            'DeltaOtn_M                 = ' "?"                               SKIP 
            'Warnings                   = ' vWrn                              SKIP
          .
        end .
        output stream outstream close.
        
        assign
          p-tank-weight-rvs   = p-tank-weight-rvs + M
          p-tank-vol-pomi-rvs = p-tank-vol-pomi-rvs + (((V_total2 - V_water2) - (V_total1 - V_water1)) * 1000)
          v-avg-temp          = v-avg-temp + ((bf_bef_rvs-line.state-temperature + bf_aft_rvs-line.state-temperature) / 2)
        .
        
        assign v-warnings = (if v-warnings = "" then vWrn else v-warnings + {&new-line} + vWrn) .
        
      end . /* do ii = 1 to num-entries(v-pl-code-list) */
      
      assign v-avg-temp = v-avg-temp / num-entries(v-pl-code-list) .
        
      infoSecObj:TankWeightRvs = p-tank-weight-rvs .
      infoSecObj:TankVolPomiRvs = p-tank-vol-pomi-rvs .
      infoSecObj:AvgTempRvs = v-avg-temp .
      infoSecObj:PokmiWarningsRVS = v-warnings .
      
      def var dMP  as decimal no-undo.
      def var MF   as decimal no-undo.
      def var dMF  as decimal no-undo.
      def var MTTH as decimal no-undo.
      def var md   as decimal no-undo.
      def var dmd  as decimal no-undo.
      def var dF   as decimal no-undo.
      def var NPE  as decimal no-undo.
      def var ME   as decimal no-undo.
      def var dMEd as decimal no-undo.
      
      assign
        MTTH = infoSecObj:DocQnty * infoSecObj:DocDensity
        MF = p-tank-weight-rvs
        dF = 0.65
        NPE = infoSectionTotal:NormalWastage
        dmd = MF * dF * 0.01
        dMP = MF - MTTH
        dMEd = MTTH * NPE * 0.001
        ME = MTTH - MF - dmd
      .
      
      if MTTH > MF
      and abs(dMP) > dmd + dMed
      then do:
        ME = dMEd.
      end.
      if ME < 0 then ME = 0 .
/*      if InfoSectionCurr:TankWeight <= 0 or InfoSectionCurr:TankWeight = ? then ME = 0 .*/
      
      infoSecObj:NaturalLoss = ME.
/*      infoSecObj:NaturalLoss = 0 .*/
      
    end . /* _trpomi */
 
  end .


end class.