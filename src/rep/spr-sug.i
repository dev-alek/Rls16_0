
FUNCTION get-input-type RETURNS CHARACTER
  ( p-rec as recid ) :
  def    buffer loc-rvs-doc       for ub.rvs-doc  .
  define buffer loc-rvs-line      for ub.rvs-line .
  define buffer loc-rvs-line-attr for ub.rvs-line-attr .
  define variable v-doc-input-type  as character no-undo .
  define variable v-input-type-list as character no-undo .
    
  find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
  for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
    find first loc-rvs-line-attr no-lock
      where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
      and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
      and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
      and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
      and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
      and loc-rvs-line-attr.attr-code = 'input-type'
      no-error.
    if available loc-rvs-line-attr
      then 
    do :
      v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
    end.
  end.
  if trim(v-input-type-list) = ""
    then 
  do :
    for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
      find first loc-rvs-line-attr no-lock
        where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
        and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
        and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
        and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
        and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
        and loc-rvs-line-attr.attr-code = 'input-type-p'
        no-error.
      if available loc-rvs-line-attr
        then 
      do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
      find first loc-rvs-line-attr no-lock
        where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
        and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
        and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
        and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
        and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
        and loc-rvs-line-attr.attr-code = 'input-type-t'
        no-error.
      if available loc-rvs-line-attr
        then 
      do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
      find first loc-rvs-line-attr no-lock
        where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
        and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
        and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
        and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
        and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
        and loc-rvs-line-attr.attr-code = 'input-type-l'
        no-error.
      if available loc-rvs-line-attr
        then 
      do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
    end.
  end .
    
  if can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'а'.
    
  if can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'ф'.
    
  if  not can-do(v-input-type-list, 'ф')
    and can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'ак'.
    
  if ((can-do(v-input-type-list, 'ф')
    or can-do(v-input-type-list, 'п')) 
    and can-do(v-input-type-list, 'а'))
    or can-do(v-input-type-list, 'фк')
    then v-doc-input-type = 'фк'.
    
  if can-do(v-input-type-list, 'р')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'к')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'р'.
    
  if v-doc-input-type = 'а'
    and can-do(v-input-type-list, 'р') 
    then v-doc-input-type = 'ак'.
    
  if v-doc-input-type = 'ф'
    and can-do(v-input-type-list, 'р') 
    then v-doc-input-type = 'фк'.
    
  if v-doc-input-type = ? then v-doc-input-type = '' .
  return v-doc-input-type .
END FUNCTION.

FUNCTION getNunHoses RETURNS integer /*Получение кол-ва рукавов*/
  (p-doc-code as character) :
  define variable vGateValve as character no-undo.  
  define variable vOk        as logical   no-undo.  
  define variable vNumHoses  as integer   no-undo init 0.  
    
  define buffer buf_doc-pl        for ub.doc-pl.
  define buffer buf_place         for ub.place.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_goods         for ub.goods.
  define buffer buf_doc-line-attr for ub.doc-line-attr.

  find first buf_doc-pl where
    buf_doc-pl.out-code = p-doc-code
    no-lock no-error.
  if avail buf_doc-pl then
    find first buf_place where
      buf_place.obj-type = buf_doc-pl.obj-type
      and buf_place.obj-code = buf_doc-pl.obj-code
      and buf_place.pl-code  = buf_doc-pl.pl-code
      no-lock no-error.
  if avail buf_place then 
  do:
    run placelib_get-attr  ( 
      input {&place-gate-valve}
      ,input buf_place.obj-code
      ,input buf_place.obj-type
      ,input buf_place.pl-code
      ,output vGateValve
      ,output vOk      
      ) no-error.
    if not vOk or not logical(vGateValve) then
      vNumHoses = 1. 
    else 
    do:
      for first buf_doc-line where  
        buf_doc-line.doc-code = p-doc-code 
        no-lock,
        first buf_goods where 
        buf_goods.artic     =  buf_doc-line.artic
        and buf_goods.prod-code =  buf_doc-line.prod-code
        and buf_goods.prod-type =  buf_doc-line.prod-type 
        no-lock,
        first buf_doc-line-attr where
        buf_doc-line-attr.doc-code  = p-doc-code   
        and buf_doc-line-attr.gds-code  = buf_goods.gds-code
        and buf_doc-line-attr.attr-code = "connect-hoses"
        no-lock:
        vNumHoses = if buf_doc-line-attr.attr-value = "yes" then 1 else 0.
      end.         
    end.
  end. 

  RETURN vNumHoses.

END FUNCTION.

function tempRas RETURNS decimal /*температура*/
  (doc-code as character,
  gds-code as integer):
     
  define variable v-temp as decimal   no-undo .
  define variable ii     as integer   no-undo .
  define variable is-rvd as character no-undo .
  define buffer buf_rvs-line for ub.rvs-line .
  define buffer buf_rvs-doc  for ub.rvs-doc .

  
  for each buf_rvs-doc no-lock where buf_rvs-doc.out-code = doc-code and
    buf_rvs-doc.rvs-type = {&rvs-after-doc} :
    is-rvd = get-input-type(recid(buf_rvs-doc)) .
    
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
      buf_rvs-line.gds-code = gds-code:
      ii = ii + 1 .  
      v-temp = v-temp + if is-rvd = 'а' then buf_rvs-line.temperature else buf_rvs-line.state-temperature .
    end.
    return v-temp / ii.
  end.
  
  return 0 .
end function. 

function masRas RETURNS decimal /*массовая доля пропана*/
  (doc-code as character,
  gds-code as integer):
     
  define variable v-masDol as decimal no-undo .
  
  define buffer buf_doc-line-attr for ub.doc-line-attr .
    
  for first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = doc-code
    and buf_doc-line-attr.gds-code = gds-code
    and buf_doc-line-attr.attr-code = "propan-perc":
    v-masDol = decimal (buf_doc-line-attr.attr-value) .                                    
  end.
  return v-masDol .                                           

end function. 

function autoAttr RETURNS character /**/
  (doc-code as character,
  attr-code as character):
  
  define buffer buf_doc-attr       for ub.doc-attr .
  define buffer buf_auto-tank-attr for ub.auto-tank-attr .
  
  find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-car-num}
    and buf_doc-attr.doc-code = doc-code no-error .
  if available (buf_doc-attr) then 
  do:
    find first buf_auto-tank-attr no-lock where 
      buf_auto-tank-attr.attr-code = attr-code and
      buf_auto-tank-attr.auto-num = buf_doc-attr.attr-value no-error .
    if available (buf_auto-tank-attr) then return buf_auto-tank-attr.attr-value .
  end.
  return "" .
end function. 

function volumeGF RETURNS decimal /*Объем слитой ЖФ СУГ*/
  (doc-code as character,
  gds-code as integer):

  define buffer buf_goods    for ub.goods .
  define buffer buf_rvs-doc  for ub.rvs-doc .
  define buffer buf_rvs-line for ub.rvs-line .

  define variable volue     as decimal no-undo .
  define variable beforeVol as decimal no-undo .
  define variable afterVol  as decimal no-undo .

  find first buf_goods no-lock where buf_goods.gds-code = gds-code no-error .
  if available (buf_goods) then 
  do:
    find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = doc-code and
      buf_rvs-doc.rvs-type = {&rvs-before-doc} no-error .
    if available (buf_rvs-doc) then 
    do:
      for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
        buf_rvs-line.gds-code = buf_goods.gds-code:
                        
        beforeVol = beforeVol + buf_rvs-line.state-measure-qnty .

      end.
    end. 
    find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = doc-code and
      buf_rvs-doc.rvs-type = {&rvs-after-doc} no-error .
    if available (buf_rvs-doc) then 
    do:
      for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
        buf_rvs-line.gds-code = buf_goods.gds-code :
        if buf_rvs-line.state-measure-qnty = ? then
        afterVol = afterVol + buf_rvs-line.state-brutto-qnty .
        else 
        afterVol = afterVol + buf_rvs-line.state-measure-qnty .

      end.
    end.
  end.

  volue = (afterVol - beforeVol) / 1000 .
  return volue .
end function. 

procedure tp-rtr:
  /* ТП при продувке резинотканевых рукавов для удаления воздуха
  Таблица 6 Нормы тех. потерь СУГ при продувке рукавов
  Температура (С)		Массовая доля пропана (%)	Коэффициент
  от -40 до -20 (вкл)	от 0 до 50 (вкл)		0,040
  от -40 до -20 (вкл)	от 50 до 60 (вкл)		0,050
  от -40 до -20 (вкл)	Более 60			    0,060
  от -20 до 0 (вкл)	от 0 до 50 (вкл)		0,070
  от -20 до 0 (вкл)	от 50 до 60 (вкл)		0,080
  от -20 до 0 (вкл)	Более 60			    0,110
  от 0 до 20 (вкл)	от 0 до 50 (вкл)		0,130
  от 0 до 20 (вкл)	от 50 до 60 (вкл)		0,150
  от 0 до 20 (вкл)	Более 60			    0,200
  более 20         	от 0 до 50 (вкл)		0,210
  более 20	        от 50 до 60 (вкл)		0,240
  более 20	        Более 60			    0,310  */
  DEFINE INPUT  PARAMETER sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER mass-prop AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp >  -40 and sug-temp <= -20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.040 .
    if     sug-temp >  -40 and sug-temp <= -20  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.050  .
    if     sug-temp >  -40 and sug-temp <= -20  
      and mass-prop >  60
      then ktp = 0.060  .
    if      sug-temp  > -20 and sug-temp  <=  0  
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.070  .
    if      sug-temp  > -20 and sug-temp  <=  0  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.080 .
    if      sug-temp > -20 and sug-temp <=  0  
      and mass-prop > 60
      then ktp = 0.110 . 
    if      sug-temp >    0 and sug-temp <=  20  
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.130    .
    if      sug-temp >    0 and sug-temp <=  20  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.150        .       
    if      sug-temp >   0  and sug-temp <= 20  
      and mass-prop > 60
      then ktp = 0.2 .       
    if      sug-temp >   20 
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.210  .
    if      sug-temp >   20 
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.240   .       
    if  sug-temp >      20  
      and mass-prop > 60
      then ktp = 0.310  .       
  END.                                             
END PROCEDURE. 

procedure tp-arm:
  /* ТП при продувке СУГ участка арматуры между запорными устройствами 
  резинотканевых рукавов и АЦ для удаления воздуха
  Таблица 7 Нормы тех. потерь СУГ при продувке рукавов
  Температура (С)	        Массовая доля пропана (%)	Коэффициент
  от -40 до -20 (вкл)	от 0 до 50 (вкл)		0,040
  от -40 до -20 (вкл)	от 50 до 60 (вкл)		0,040
  от -40 до -20 (вкл)	Более 60			    0,050
  от -20 до 0 (вкл)	от 0 до 50 (вкл)		0,070
  от -20 до 0 (вкл)	от 50 до 60 (вкл)		0,070
  от -20 до 0 (вкл)	Более 60			    0,100
  от 0 до 20 (вкл)	от 0 до 50 (вкл)		0,120
  от 0 до 20 (вкл)	от 50 до 60 (вкл)		0,190
  от 0 до 20 (вкл)	Более 60			    0,220
  более 20		от 0 до 50 (вкл)		    0,210
  более 20		от 50 до 60 (вкл)		    0,240
  более 20		Более 60			        0,280 */
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  mass-prop AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp  >  -40 and sug-temp <= -20  
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.040   .
    if     sug-temp >  -40 and sug-temp <= -20  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.040   .
    if     sug-temp >  -40 and sug-temp <= -20  
      and mass-prop >  60
      then ktp = 0.050       .
    if      sug-temp  > -20 and sug-temp  <=  0  
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.070       .
    if      sug-temp  > -20 and sug-temp  <=  0  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.070  .
    if      sug-temp > -20 and sug-temp <=  0  
      and mass-prop > 60
      then ktp = 0.100  . 
    if      sug-temp  >   0 and sug-temp <=  20  
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.120    .
    if      sug-temp >    0 and sug-temp <=  20  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.190    .       
    if      sug-temp >    0  and sug-temp <=  20  
      and mass-prop >  60
      then ktp = 0.220   .       
    if      sug-temp >   20 and mass-prop >   0
      and mass-prop <= 50 
      then ktp = 0.210   .
    if      sug-temp >   20 
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.240   .       
    if      sug-temp >   20 and mass-prop >  60
      then ktp = 0.280   .              
  END.                                             
END PROCEDURE. 

procedure tp-emp:    
  /* ТП при опорожнении резинотканевых рукавов по окончании налива (слива) АЦ
  Таблица 8 Нормы тех. потерь СУГ при опорожнении рукавов
  Температура (С)	    Массовая доля пропана (%)	Длина рукава (м)    Коэффициент
  от -40 до -20 (вкл)	от 0 до 50 (вкл)	от 0 до 7 (вкл)		7,081
  от -40 до -20 (вкл)	от 0 до 50 (вкл)	более 7			    9,441
  от -40 до -20 (вкл)	от 50 до 60 (вкл)	от 0 до 7 (вкл)		7,087
  от -40 до -20 (вкл)	от 50 до 60 (вкл)	более 7			    9,449
  от -40 до -20 (вкл)	более 60		от 0 до 7 (вкл)		    7,099
  от -40 до -20 (вкл)	более 60		более 7			        9,466
  от -20 до 0 (вкл)	от 0 до 50 (вкл)	от 0 до 7 (вкл)		6,793
  от -20 до 0 (вкл)	от 0 до 50 (вкл)	более 7		    	9,057
  от -20 до 0 (вкл)	от 50 до 60 (вкл)	от 0 до 7 (вкл)		6,801
  от -20 до 0 (вкл)	от 50 до 60 (вкл)	более 7			9,068
  от -20 до 0 (вкл)	более 60		от 0 до 7 (вкл)		6,822
  от -20 до 0 (вкл)	более 60		более 7		    	9,096
  от 0 до 20 (вкл)	от 0 до 50 (вкл)	от 0 до 7 (вкл)		6,550
  от 0 до 20 (вкл)	от 0 до 50 (вкл)	более 7			    8,734
  от 0 до 20 (вкл)	от 50 до 60 (вкл)	от 0 до 7 (вкл)		6,566
  от 0 до 20 (вкл)	от 50 до 60 (вкл)	более 7		8,755
  от 0 до 20 (вкл)	более 60		от 0 до 7 (вкл)	6,605
  от 0 до 20 (вкл)	более 60		более 7			8,807
  более 20		от 0 до 50 (вкл)	от 0 до 7 (вкл)	6,294
  более 20		от 0 до 50 (вкл)	более 7			8,393
  более 20		от 50 до 60 (вкл)	от 0 до 7 (вкл)	6,317
  более 20		от 50 до 60 (вкл)	более 7			8,423
  более 20		более 60		от 0 до 7 (вкл)		6,377
  более 20		более 60		более 7			    8,502 */
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  mass-prop AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  length    AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp  > -40 AND sug-temp  <= -20
      and mass-prop >   0 and mass-prop <=  50
      and length    >=   0 and length    <=   7
      then ktp = 7.081    .
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >    0 and mass-prop <=  50
      and length    >    7
      then ktp = 9.441   .        
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 7.087   .       
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7
      then ktp = 9.449  .       
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   60 
      and length    >=    0 and length    <=   7
      then ktp = 7.099          .
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   60
      and length    >    7
      then ktp = 9.466    .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >    0 and mass-prop <=  50
      and length    >=    0 and length    <=   7
      then ktp = 6.793   .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >    0 and mass-prop <=  50
      and length    >    7
      then ktp = 9.057  .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 6.801   .              
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7 
      then ktp = 9.068  .               
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   60 
      and length    >=    0 and length    <=   7
      then ktp = 6.822   .                
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   60
      and length    >    7
      then ktp = 9.095    .                  
    if     sug-temp  >    0 AND sug-temp  <=  20
      and mass-prop >    0 and mass-prop <=  50
      and length    >=    0 and length    <=   7
      then ktp = 6.550    .
    if     sug-temp  >    0 AND sug-temp  <=  20
      and mass-prop >    0 and mass-prop <=  50
      and length    >    7
      then ktp = 8.734   .    
    if     sug-temp  >   0 AND sug-temp  <=  20
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 6.566 .   
    if     sug-temp  >    0 AND sug-temp  <=  20
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7
      then ktp = 8.755  .      
    if    sug-temp  >     0 AND sug-temp  <=  20
      and mass-prop >   60 
      and length    >=    0 and length    <=   7
      then ktp = 6.605 .         
    if    sug-temp   >    0 AND sug-temp  <=  20
      and mass-prop >   60
      and length    >    7
      then ktp = 8.807  .            
    if    sug-temp   >   20 
      and mass-prop >    0 and mass-prop <=  50
      and length    >=    0 and length    <=   7
      then ktp = 6.294  .                   
    if    sug-temp   >   20 
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 6.317  .               
    if    sug-temp   >   20 
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7
      then ktp = 8.423   .          
    if    sug-temp   >   20 
      and mass-prop >   60
      and length    >=    0 and length    <=   7
      then ktp = 6.377    .              
    if    sug-temp   >   20 
      and mass-prop <=  60
      and length    >=    0 and length    >    7
      then ktp = 8.502   .                     
  END.                                             
END PROCEDURE. 

procedure tp-ret:
  /* ТП при возврате АЦ 
  Таблица 9 Нормы тех. потерь СУГ при опорожнении рукавов
  Температура (С)		Коэффициент
  от -40 до -20 (вкл)	3,630
  от -20 до 0 (вкл)	3,350
  от 0 до 20 (вкл)	3,110
  более 20		    2,910  */
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if sug-temp > -40 and sug-temp <= -20 then ktp = 3.630 .                        
    if sug-temp > -20 and sug-temp <=   0 then ktp = 3.350 .                        
    if sug-temp >   0 and sug-temp <=  20 then ktp = 3.110 .                               
    if sug-temp >  20                     then ktp = 2.910 .                                      
  END.                                             
END PROCEDURE. 

procedure tp-chklv:
  /* ТП при проверке уровня наполнения с помощью контрольного вентиля АЦ
  Таблица 10 Нормы тех.потерь СУГ при проверке уровня наполнения АЦ
  Температура (С)	     Массовая доля пропана (%)	Коэффициент
  от -40 до -20 (вкл)	от 0 до 50 (вкл)	0,940
  от -40 до -20 (вкл)	от 50 до 60 (вкл)	1,050
  от -40 до -20 (вкл)	Более 60		1,280
  от -20 до 0 (вкл)	от 0 до 50 (вкл)	1,510
  от -20 до 0 (вкл)	от 50 до 60 (вкл)	1,660
  от -20 до 0 (вкл)	Более 60	        2,040
  от 0 до 20 (вкл)	от 0 до 50 (вкл)	2,500
  от 0 до 20 (вкл)	от 50 до 60 (вкл)	2,780
  от 0 до 20 (вкл)	Более 60		3,450
  более 20		от 0 до 50 (вкл)	3,760
  более 20		от 50 до 60 (вкл)       4,160
  более 20		Более 60	       	5,160 */
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  mass-prop AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp >  -40 and sug-temp <= -20  
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.940   .
    if  sug-temp >  -40 and sug-temp <= -20  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 1.050   .
    if  sug-temp >  -40 and sug-temp <= -20  
      and mass-prop >  60 
      then ktp = 1.280   .
    if  sug-temp >  -20 and sug-temp <=   0  
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 1.510         .
    if  sug-temp >  -20 and sug-temp <=   0  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 1.660   .
    if  sug-temp >  -20 and sug-temp <=   0  
      and mass-prop >  60
      then ktp = 2.040  .
    if  sug-temp >   0 and sug-temp <=  20  
      and mass-prop >  0 and mass-prop <= 50
      then ktp = 2.500    .
    if  sug-temp >    0 and sug-temp <=  20  
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 2.780   .
    if  sug-temp >    0 and sug-temp <=  20  
      and mass-prop >  60
      then ktp = 3.450   .
    if  sug-temp >   20 
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 3.760 .
    if  sug-temp >   20 
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 4.160  .
    if  sug-temp  > 20 
      and mass-prop > 60
      then ktp = 5.160  .       
  END.                                             
END PROCEDURE.

procedure doc-line-write:
  define input parameter doc-code as character no-undo .
  define input parameter attr-code as character no-undo .
  define input parameter gds-code as integer no-undo .
  define input parameter attr-value as character no-undo .
  find first ub.doc-line-attr exclusive-lock where ub.doc-line-attr.attr-code = attr-code
    and ub.doc-line-attr.doc-code = doc-code
    and ub.doc-line-attr.gds-code = gds-code no-error .
  if not available (ub.doc-line-attr) then 
  do:
    create ub.doc-line-attr .
    assign
      ub.doc-line-attr.attr-code = attr-code
      ub.doc-line-attr.doc-code  = doc-code
      ub.doc-line-attr.gds-code  = gds-code
      .
  end.
  ub.doc-line-attr.attr-value = attr-value .
end procedure .  

procedure doc-line-value:
  define input parameter doc-code as character no-undo .
  define input parameter attr-code as character no-undo .
  define input parameter gds-code as integer no-undo .
  define output parameter attr-value as character no-undo .
  find first ub.doc-line-attr exclusive-lock where ub.doc-line-attr.attr-code = attr-code
    and ub.doc-line-attr.doc-code = doc-code
    and ub.doc-line-attr.gds-code = gds-code no-error .
  if available (ub.doc-line-attr) then 
  do:
    if ub.doc-line-attr.attr-value <> ? then attr-value = ub.doc-line-attr.attr-value .
  end.

end procedure .  

procedure spr-sug:
  define input parameter doc-code as character no-undo .
  define input parameter reason-code as integer no-undo .
  define buffer buf_doc-pl   for ub.doc-pl .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_doc-attr for ub.doc-attr .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_clients-attr for ub.clients-attr .
  
  define variable numHoses    as integer   no-undo .
  define variable vBlowdown   as decimal   no-undo .
  define variable vFittings   as decimal   no-undo .
  define variable vEmptying   as decimal   no-undo .
  define variable vRefund     as decimal   no-undo .
  define variable vCtrlvalve  as decimal   no-undo .
  define variable vTemp       as decimal   no-undo .
  define variable vMasDol     as decimal   no-undo .
  define variable vVolue      as decimal   no-undo .
  define variable is-rvd      as logical   no-undo .
  define variable lengthRukav as decimal   no-undo .
  define variable ktp         as decimal   no-undo .
  define variable valve       as logical   no-undo .
  define variable clear-ac    as logical   no-undo .
  define variable GNS         as character no-undo .
  define variable own-supp    as logical   no-undo .
  
  numHoses = getNunHoses(doc-code) . /*кол-во рукавов*/
  lengthRukav = decimal (autoAttr(doc-code,"con-sleeve")) . /*длина рукава*/
  valve = if autoAttr(doc-code, "valve") = "" then false else logical(autoAttr(doc-code, "valve")) . /*заслонка*/

  find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-clear-ac} and
    buf_doc-attr.doc-code = doc-code no-error . /*Зачищена*/
    
  if available (buf_doc-attr) then clear-ac = logical (buf_doc-attr.attr-value) .

  find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-ptbobj} and
    buf_doc-attr.doc-code = doc-code no-error . /*Нефтебаза*/
  if available (buf_doc-attr) then GNS = buf_doc-attr.attr-value .

  for each buf_doc-line no-lock where buf_doc-line.doc-code = doc-code:
    find first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and
      ub.goods.prod-code = buf_doc-line.prod-code and
      ub.goods.prod-type = buf_doc-line.prod-type no-error .
      
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = doc-code no-error .
    if available (buf_trn-doc) then 
    do:
      find first buf_clients-attr where buf_clients-attr.obj-type = buf_trn-doc.cli-type
        and buf_clients-attr.obj-code = buf_trn-doc.cli-code
        and buf_clients-attr.attr-code = {&attr-own-supp} no-lock no-error .
      if available (buf_clients-attr) then 
        own-supp = logical(buf_clients-attr.attr-value).
      else own-supp = false .
    end.

    for first buf_doc-pl no-lock where buf_doc-pl.out-code = buf_doc-line.doc-code and
      buf_doc-pl.gds-code = ub.goods.gds-code:

      vTemp = tempRas(doc-code, ub.goods.gds-code) . /*Температура*/
      vMasDol = masRas(doc-code, ub.goods.gds-code) . /*масса*/
      vVolue = volumeGF(doc-code, ub.goods.gds-code) . /*объем*/
      
      run tp-rtr(vTemp, vMasDol, output ktp) .
      vBlowdown = ktp * numHoses . /*Значение технологических потерь при продувке резинотканевых рукавов для удаления воздуха*/
      run tp-arm(vTemp, vMasDol, output ktp) .
      vFittings = ktp * numHoses . /*Значение технологических потерь при продувке участка арматуры между запорными устройствами резинотканевых рукавов и АЦ для удаления воздуха*/
      run tp-emp(vTemp, vMasDol, lengthRukav, output ktp) .
      vEmptying = ktp * numHoses . /*Значение технологических потерь при опорожнении резинотканевых рукавов по окончании налива (слива) АЦ*/
      run tp-ret(vTemp, output ktp) .

/*      if not(own-supp) or (GNS > ""  and clear-ac) then vRefund = ktp * vVolue . /* зависел ои нефтебазы и зачищена или нет*/*/
/*      else vRefund = 0 .                                                                                                     */
      vRefund = ktp * vVolue .
      run tp-chklv(vTemp, vMasDol, output ktp) .
      if reason-code = 99 and valve then vCtrlvalve = ktp .
      else vCtrlvalve = 0 .
      
      run doc-line-write(doc-code, "blowdown", ub.goods.gds-code, string (vBlowdown)) .
      run doc-line-write(doc-code, "fittings", ub.goods.gds-code, string (vFittings)) .
      run doc-line-write(doc-code, "emptying", ub.goods.gds-code, string (vEmptying)) .
      run doc-line-write(doc-code, "refund", ub.goods.gds-code, string (vRefund)) .
      run doc-line-write(doc-code, "ctrlvalve", ub.goods.gds-code, string (vCtrlvalve)) .

    end.
  end.


/*    vBlowdown = blowdown(numHoses, vTemp, vMasDol) . */
end procedure .

function check-RVD returns logical
  (p-obj-code as integer,
  p-obj-type as character,
  p-pl-code as integer):
  
  define buffer buf_place       for ub.place .
  define buffer buf_place-attr  for ub.place-attr .
  define buffer buf_place-attr2 for ub.place-attr .

  
  find first buf_place-attr no-lock where buf_place-attr.obj-type = p-obj-type
    and buf_place-attr.obj-code = p-obj-code
    and buf_place-attr.attr-code = {&place-need-RVD-rvs}
    and buf_place-attr.pl-code = p-pl-code 
    and logical(buf_place-attr.attr-value) = yes 
    no-error .
  if available buf_place-attr then return true .
  for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = p-obj-type
    and buf_place-attr2.obj-code = p-obj-code
    and buf_place-attr2.pl-code  = p-pl-code
    and buf_place-attr2.attr-code = {&place-rvd-dnsty}
    and logical(buf_place-attr2.attr-value) = yes 
    :
    return true .
  end .
  for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = p-obj-type
    and buf_place-attr2.obj-code = p-obj-code
    and buf_place-attr2.pl-code  = p-pl-code
    and buf_place-attr2.attr-code = {&place-rvd-tmp}
    and logical(buf_place-attr2.attr-value) = yes 
    :
    return true .
  end .
  for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = p-obj-type
    and buf_place-attr2.obj-code = p-obj-code
    and buf_place-attr2.pl-code  = p-pl-code
    and buf_place-attr2.attr-code = {&place-rvd-lvl}
    and logical(buf_place-attr2.attr-value) = yes 
    :
    return true .
  end .

  return false .                      
  
end function .

