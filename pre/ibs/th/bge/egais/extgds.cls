using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ExtGds:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
  define private temp-table ttObjEgaisAlcProp no-undo
    field iExtGdsObj as integer
    field ExtGdsValueObj as class Progress.Lang.Object
    index pi is primary unique iExtGdsObj .
  define private buffer buf_ext-classif      for ub.ext-classif.
  define private buffer x_ext-classif        for ub.ext-classif.
  define private buffer buf_ext-classif-attr for ub.ext-classif-attr.
  define private buffer buf_gds for ub.goods.
  define private buffer buf_cli for ub.clients.
  define property ExtSystem as integer no-undo
    get.
    private set.
  define property DbNum as integer init 0 no-undo
    get.
    set.
  define property IsSilent as logical no-undo
    get.
    private set.
  define property GdsCodeItemQuery as integer no-undo init 0
    get.
    private set.
  define property AlcCodeItemQuery as character no-undo
    get.
    private set.
  define property NumBundles as integer no-undo
    get.
    private set.
  define property ReturnMsg as character no-undo
    get.
    private set.
  define property SettingsTTList as character no-undo init ";;;20,yes;23,yes;;;20,yes;20,no;;20,yes;;;;;20,yes;;;;;1,no;"
    get.
    private set.
  define temp-table tt-egaisgds-hndls no-undo
    field mark             as character format "X(1)" label "*"
    field gdsCode          as integer   label "Код товара" format "9999999999"
    field alcCode          as character label "Алк. код товара" format "x(21)"
    field gdsName          as character label "Название товара" format "x(256)"
    field egaisGdsName     as character label "Название товара ЕГАИС" format "x(256)"
    field artic            as character label "Артикл" format "x(15)"
    field prod             as character label "Производитель TH" format "x(21)"
    field prodName         as character label "Производитель TH" format "x(256)"
    field prodInnkpp       as character label "ИНН/КПП производителя TH" format "x(30)"
    field prodEgais        as character label "Код производитель ЕГАИС" format "x(21)"
    field prodEgaisName    as character label "Производитель ЕГАИС" format "x(256)"
    field egaisTypeProd    as character label "Тип"
    field regionProd       as character label "Регион"
    field prodInnkppEgais  as character label "ИНН/КПП производителя ЕГАИС" format "x(30)"
    field imporEgais       as character label "Код импортер ЕГАИС" format "x(21)"
    field imporEgaisName   as character label "Импортер ЕГАИС" format "x(256)"
    field egaisTypeImpor   as character label "Тип"
    field regionImpor      as character label "Регион"
    field imporInnkppEgais as character label "ИНН/КПП импортера ЕГАИС" format "x(30)"
    field verXSD           as integer   label "Вер. XSD" format "99"
    field ColorNum         as integer init ?
    field capacity         as decimal   label "Объем"
    index pi as primary
    gdsCode alcCode
    .
  constructor public ExtGds (inIsSilent as logical):
    ExtSystem = getExtSystem().
    IsSilent = inIsSilent.
    if ExtSystem = 0 or ExtSystem = ?
      then
    do:
      if not IsSilent
        then message "Отсутсвует ВС настроенная для обмена с ЕГАИС" view-as alert-box.
      return error "Отсутсвует ВС настроенная для обмена с ЕГАИС".
    end.
  end constructor.
  destructor public ExtGds ():
    ClearProp().
  end destructor.
  method public logical OpenQueryExtGds (inAlcCode as char):
    return OpenQueryExtGds (0, inAlcCode).
  end.
  method public logical OpenQueryExtGds (inGdsCode as int):
    return OpenQueryExtGds (inGdsCode, "").
  end.
  method public void GetHndlTable (inGdsCode as int, inAlcCode as char, input-output outTTHndl as handle):
    def var ExtGdsValueObj as class ExtGdsValue no-undo.
    assign
      ReturnMsg = ""
    .
    empty temp-table tt-egaisgds-hndls.
    for each buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'goods':U
      and buf_ext-classif.classif-name = 'exp-esys-gds-code':U
      and buf_ext-classif.db-num = 0
      and (inGdsCode = 0 or buf_ext-classif.key#_one = inGdsCode)
      and buf_ext-classif.key#_two = ExtSystem
      and buf_ext-classif.key#_three = 0
      and (inAlcCode = "" or buf_ext-classif.charkey_one = inAlcCode)
      and buf_ext-classif.charkey_two = ""
      and buf_ext-classif.charkey_three = ""
      and buf_ext-classif.nonunique = 0
      :
        find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = buf_ext-classif.classif-subject
          and buf_ext-classif-attr.classif-name = buf_ext-classif.classif-name
          and buf_ext-classif-attr.db-num = buf_ext-classif.db-num
          and buf_ext-classif-attr.Key#_One = buf_ext-classif.key#_one
          and buf_ext-classif-attr.Key#_two = buf_ext-classif.key#_two
          and buf_ext-classif-attr.Key#_three = buf_ext-classif.key#_three
          and buf_ext-classif-attr.CharKey_One = buf_ext-classif.charkey_one
          and buf_ext-classif-attr.CharKey_two = buf_ext-classif.charkey_two
          and buf_ext-classif-attr.CharKey_three = buf_ext-classif.charkey_three
          and buf_ext-classif-attr.nonunique = buf_ext-classif.nonunique
          and buf_ext-classif-attr.attr-code = 'egais-info'
          no-error .
        create tt-egaisgds-hndls.
        if available (buf_ext-classif-attr)
        then
          assign
            ExtGdsValueObj = GetInfoObj (buf_ext-classif-attr.attr-value)
          no-error.
        else
          assign
            ExtGdsValueObj = GetInfoObj ("")
          no-error.
        if error-status:error or not available (buf_ext-classif-attr)
          then
        do:
          ReturnMsg = "Товар" + string (buf_ext-classif.key#_one) + ". Выполните синхронизацию товаров.".
          if not IsSilent
            then message ReturnMsg view-as alert-box.
          tt-egaisgds-hndls.ColorNum = RED_COLOR.
        end.
        ExtGdsValueObj:AlcCode = buf_ext-classif.CharKey_One.
        ExtGdsValueObj:GdsCode = buf_ext-classif.Key#_One.
        assign
          tt-egaisgds-hndls.alcCode = ExtGdsValueObj:AlcCode
          tt-egaisgds-hndls.gdsCode = ExtGdsValueObj:GdsCode
          tt-egaisgds-hndls.prodEgaisName = ExtGdsValueObj:FullNameProd
          tt-egaisgds-hndls.prodEgais = ExtGdsValueObj:CliRegIdProd
          tt-egaisgds-hndls.imporEgais = ExtGdsValueObj:CliRegIdImpor
          tt-egaisgds-hndls.imporEgaisName = ExtGdsValueObj:FullNameImpor
          tt-egaisgds-hndls.imporInnkppEgais = ExtGdsValueObj:INNImpor + (if ExtGdsValueObj:KPPImpor <> "" then "/" + ExtGdsValueObj:KPPImpor else "")
          tt-egaisgds-hndls.prodInnkppEgais = ExtGdsValueObj:INNProd + (if ExtGdsValueObj:KPPProd <> "" then "/" + ExtGdsValueObj:KPPProd else "")
          tt-egaisgds-hndls.egaisGdsName = ExtGdsValueObj:FullNameGds
          tt-egaisgds-hndls.capacity = ExtGdsValueObj:Capacity
          tt-egaisgds-hndls.egaisTypeProd = ExtGdsValueObj:CliEgaisTypeProd
          tt-egaisgds-hndls.regionProd = ExtGdsValueObj:RegionProd
          tt-egaisgds-hndls.egaisTypeImpor = ExtGdsValueObj:CliEgaisTypeImpor
          tt-egaisgds-hndls.regionImpor = ExtGdsValueObj:RegionImpor
        .
        release buf_gds.
        find first buf_gds no-lock where buf_gds.gds-code = ExtGdsValueObj:GdsCode no-error.
        release buf_cli.
        find first buf_cli no-lock where buf_cli.obj-type = buf_gds.prod-type and buf_cli.obj-code = buf_gds.prod-code no-error.
        if valid-object (ExtGdsValueObj)
          then delete object ExtGdsValueObj.
        if tt-egaisgds-hndls.egaisTypeProd = ""
        then do:
          assign
            tt-egaisgds-hndls.verXSD = 1.
        end.
        else do:
          assign
            tt-egaisgds-hndls.verXSD = 2.
        end.
        if tt-egaisgds-hndls.prodInnkppEgais = "" and  tt-egaisgds-hndls.imporInnkppEgais = "" and tt-egaisgds-hndls.verXSD = 1
        then do:
          tt-egaisgds-hndls.ColorNum = RED_COLOR.
        end.
        if available (buf_gds)
        then
          assign
            tt-egaisgds-hndls.gdsName = buf_gds.gds-name
            tt-egaisgds-hndls.artic = buf_gds.artic
            tt-egaisgds-hndls.prod = buf_gds.prod-type + string (buf_gds.prod-code)
            tt-egaisgds-hndls.prodName = buf_cli.obj-name
          .
    end.
    outTTHndl = buffer tt-egaisgds-hndls:handle.
  end.
  method public logical OpenQueryExtGds (inGdsCode as int, inAlcCode as char):
    def var ii as int no-undo.
    ClearProp().
    assign
      ReturnMsg = ""
      AlcCodeItemQuery = inAlcCode
      GdsCodeItemQuery = inGdsCode
      ii = 0.
    for each buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'goods':U
      and buf_ext-classif.classif-name = 'exp-esys-gds-code':U
      and buf_ext-classif.db-num = 0
      and (GdsCodeItemQuery = 0 or buf_ext-classif.key#_one = GdsCodeItemQuery)
      and buf_ext-classif.key#_two = ExtSystem
      and buf_ext-classif.key#_three = 0
      and (AlcCodeItemQuery = "" or buf_ext-classif.charkey_one = AlcCodeItemQuery)
      and buf_ext-classif.charkey_two = ""
      and buf_ext-classif.charkey_three = ""
      and buf_ext-classif.nonunique = 0
      :
      find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = buf_ext-classif.classif-subject
        and buf_ext-classif-attr.classif-name = buf_ext-classif.classif-name
        and buf_ext-classif-attr.db-num = buf_ext-classif.db-num
        and buf_ext-classif-attr.Key#_One = buf_ext-classif.key#_one
        and buf_ext-classif-attr.Key#_two = buf_ext-classif.key#_two
        and buf_ext-classif-attr.Key#_three = buf_ext-classif.key#_three
        and buf_ext-classif-attr.CharKey_One = buf_ext-classif.charkey_one
        and buf_ext-classif-attr.CharKey_two = buf_ext-classif.charkey_two
        and buf_ext-classif-attr.CharKey_three = buf_ext-classif.charkey_three
        and buf_ext-classif-attr.nonunique = buf_ext-classif.nonunique
        and buf_ext-classif-attr.attr-code = 'egais-info'
        no-error .
      if not available (buf_ext-classif-attr)
        then
      do:
        ReturnMsg = "Отсутсвует атрибут egais-info - " + buf_ext-classif.charkey_one + "/" + string (buf_ext-classif.key#_one) + ". Выполните синхронизацию.".
        if not IsSilent
          then message ReturnMsg view-as alert-box.
      end.
      ii = ii + 1.
      setProp (ii) no-error.
      if ReturnMsg <> ""
        then
      do:
        if not IsSilent
          then message ReturnMsg view-as alert-box.
      end.
    end.
    NumBundles = ii.
    return true.
  end.
  method public class ExtGdsValue GetExtGdsValue () :
    return GetExtGdsValue (1).
  end.
  method public class ExtGdsValue GetExtGdsValue (inJJ as int) :
    find first ttObjEgaisAlcProp where ttObjEgaisAlcProp.iExtGdsObj = inJJ no-error.
    if not available (ttObjEgaisAlcProp)
      then return ?.
    return cast (ttObjEgaisAlcProp.ExtGdsValueObj, ibs.th.bge.egais.ExtGdsValue).
  end.
  method public logical CreateExtGds (inGdsCode as int, inAlcCode as char):
    define variable extGdsValueObj as class ExtGdsValue no-undo.
    define variable glog as logical no-undo.
    extGdsValueObj = new ExtGdsValue().
    extGdsValueObj:AlcCode = inAlcCode.
    extGdsValueObj:GdsCode = inGdsCode.
    glog = CreateExtGds(extGdsValueObj) .
    if not glog
      then if valid-object (extGdsValueObj)
                  then delete object extGdsValueObj.
    return glog.
  end.
  method public logical CreateExtGds (inExtGdsValueObj as class ExtGdsValue):
    ClearProp().
    assign
      ReturnMsg = ""
      AlcCodeItemQuery = inExtGdsValueObj:AlcCode
      GdsCodeItemQuery = inExtGdsValueObj:GdsCode
    .
    find first buf_gds no-lock where buf_gds.gds-code = inExtGdsValueObj:GdsCode no-error.
    if not available (buf_gds)
    then do:
      ReturnMsg = "Не найден товар TH - " + string (inExtGdsValueObj:GdsCode).
      if not IsSilent
        then message ReturnMsg view-as alert-box.
      AlcCodeItemQuery = "".
      GdsCodeItemQuery = 0.
      undo, return false.
    end.
    if inExtGdsValueObj:AlcCode = ? or inExtGdsValueObj:AlcCode = ""
    then do:
      ReturnMsg = "Неверное значение AlcCode".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
      AlcCodeItemQuery = "".
      GdsCodeItemQuery = 0.
      undo, return false.
    end.
    do trans:
      find first buf_ext-classif no-lock  where buf_ext-classif.classif-subject = 'goods':U
        and buf_ext-classif.classif-name = 'exp-esys-gds-code':U
        and buf_ext-classif.db-num = 0
        and buf_ext-classif.Key#_One = inExtGdsValueObj:GdsCode
        and buf_ext-classif.key#_two = ExtSystem
        and buf_ext-classif.key#_three = 0
        and buf_ext-classif.charkey_one = inExtGdsValueObj:AlcCode
        and buf_ext-classif.charkey_two = ""
        and buf_ext-classif.charkey_three = ""
        and buf_ext-classif.nonunique = 0
        no-error.
      if available (buf_ext-classif)
        then
      do:
        ReturnMsg = "Уже есть связка товара ЕГАИС - " + inExtGdsValueObj:AlcCode + " c товаром TH - " + string (inExtGdsValueObj:GdsCode).
        if not IsSilent
          then message ReturnMsg view-as alert-box.
        AlcCodeItemQuery = "".
        GdsCodeItemQuery = 0.
        undo, return false.
      end.
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-subject = 'goods':U
        buf_ext-classif.classif-name = 'exp-esys-gds-code':U
        buf_ext-classif.db-num = 0
        buf_ext-classif.Key#_One = inExtGdsValueObj:GdsCode
        buf_ext-classif.key#_two = ExtSystem
        buf_ext-classif.key#_three = 0
        buf_ext-classif.charkey_one = inExtGdsValueObj:AlcCode
        buf_ext-classif.charkey_two = ""
        buf_ext-classif.charkey_three = ""
        buf_ext-classif.nonunique = 0
        buf_ext-classif.uniq-key-rec = 'goods':U + chr(3) + string (inExtGdsValueObj:GdsCode)
      no-error.
      if error-status:error
        then
      do:
        delete buf_ext-classif.
        ReturnMsg = "Непредвиденная ошибка при создании связки  - " + inExtGdsValueObj:AlcCode + " TH - " + string (inExtGdsValueObj:GdsCode).
        if not IsSilent
          then message ReturnMsg view-as alert-box.
        AlcCodeItemQuery = "".
        GdsCodeItemQuery = 0.
        undo, return false.
      end.
      create buf_ext-classif-attr.
      assign
        buf_ext-classif-attr.classif-subject = buf_ext-classif.classif-subject
        buf_ext-classif-attr.classif-name    = buf_ext-classif.classif-name
        buf_ext-classif-attr.db-num          = buf_ext-classif.db-num
        buf_ext-classif-attr.Key#_One        = buf_ext-classif.key#_one
        buf_ext-classif-attr.Key#_two        = buf_ext-classif.key#_two
        buf_ext-classif-attr.Key#_three      = buf_ext-classif.key#_three
        buf_ext-classif-attr.CharKey_One     = buf_ext-classif.charkey_one
        buf_ext-classif-attr.CharKey_two     = buf_ext-classif.charkey_two
        buf_ext-classif-attr.CharKey_three   = buf_ext-classif.charkey_three
        buf_ext-classif-attr.nonunique       = buf_ext-classif.nonunique
        buf_ext-classif-attr.attr-code       = 'egais-info'
      no-error.
      if error-status:error
        then
      do:
        delete buf_ext-classif-attr.
        ReturnMsg = "Запись уже есть buf_ext-classif-attr. Создание будет продолжено. Непредвиденная ситуация при создании атрибута egais-info  - " + inExtGdsValueObj:AlcCode + " TH - " + string (inExtGdsValueObj:GdsCode).
        if not IsSilent
          then message ReturnMsg view-as alert-box.
        find first buf_ext-classif-attr where
          buf_ext-classif-attr.classif-subject = buf_ext-classif.classif-subject
          and buf_ext-classif-attr.classif-name    = buf_ext-classif.classif-name
          and buf_ext-classif-attr.db-num          = buf_ext-classif.db-num
          and buf_ext-classif-attr.Key#_One        = buf_ext-classif.key#_one
          and buf_ext-classif-attr.Key#_two        = buf_ext-classif.key#_two
          and buf_ext-classif-attr.Key#_three      = buf_ext-classif.key#_three
          and buf_ext-classif-attr.CharKey_One     = buf_ext-classif.charkey_one
          and buf_ext-classif-attr.CharKey_two     = buf_ext-classif.charkey_two
          and buf_ext-classif-attr.CharKey_three   = buf_ext-classif.charkey_three
          and buf_ext-classif-attr.nonunique       = buf_ext-classif.nonunique
          and buf_ext-classif-attr.attr-code       = 'egais-info'
        no-error.
      end.
      if not SaveEGAISInfoDB (inExtGdsValueObj)
        then do:
          AlcCodeItemQuery = "".
          GdsCodeItemQuery = 0.
          undo, return false.
        end.
    end.
    create ttObjEgaisAlcProp.
    NumBundles = 1.
    ttObjEgaisAlcProp.iExtGdsObj = 1.
    cast (ttObjEgaisAlcProp.ExtGdsValueObj, ibs.th.bge.egais.ExtGdsValue) = inExtGdsValueObj.
    return true.
  end.
  method public logical DeleteExtGds (inGdsCode as int):
    if DeleteExtGds ( inGdsCode, ? )
      then return true.
      else return false.
  end.
  method public logical DeleteExtGds (inAlcCode as char):
    if DeleteExtGds (  ?, inAlcCode )
      then return true.
      else return false.
  end.
  method public logical DeleteExtGds (inGdsCode as int, inAlcCode as char):
    ReturnMsg = "".
    do trans:
      for each buf_ext-classif-attr exclusive-lock where
            buf_ext-classif-attr.classif-subject = 'goods':U
        and buf_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
        and buf_ext-classif-attr.db-num = 0
        and (inGdsCode = ? or buf_ext-classif-attr.Key#_One = inGdsCode)
        and buf_ext-classif-attr.key#_two = ExtSystem
        and (inAlcCode = ? or buf_ext-classif-attr.charkey_one = inAlcCode)
        :
        delete buf_ext-classif-attr.
      end.
      for each buf_ext-classif exclusive-lock where
            buf_ext-classif.classif-subject = 'goods':U
        and buf_ext-classif.classif-name = 'exp-esys-gds-code':U
        and buf_ext-classif.db-num = 0
        and buf_ext-classif.key#_two = ExtSystem
        and (inGdsCode = ? or buf_ext-classif.Key#_One = inGdsCode)
        and (inAlcCode = ? or buf_ext-classif.charkey_one = inAlcCode)
        :
        delete buf_ext-classif.
      end.
    end.
    ClearProp ().
    return true.
  end.
  method public logical SaveEGAISInfo (inExtGdsValueObj as ExtGdsValue):
    def var glog as log no-undo.
    do trans:
      find first buf_ext-classif-attr where
            buf_ext-classif-attr.classif-subject = 'goods':U
        and buf_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
        and buf_ext-classif-attr.db-num = 0
        and buf_ext-classif-attr.Key#_One = inExtGdsValueObj:GdsCode
        and buf_ext-classif-attr.key#_two = ExtSystem
        and buf_ext-classif-attr.key#_three = 0
        and buf_ext-classif-attr.charkey_one = inExtGdsValueObj:AlcCode
        and buf_ext-classif-attr.charkey_two = ""
        and buf_ext-classif-attr.charkey_three = ""
        and buf_ext-classif-attr.attr-code = 'egais-info'
      no-error.
      if not available (buf_ext-classif-attr)
      then do:
        create buf_ext-classif-attr.
        assign
          buf_ext-classif-attr.classif-subject = 'goods':U
          buf_ext-classif-attr.classif-name = 'exp-esys-gds-code':U
          buf_ext-classif-attr.db-num = 0
          buf_ext-classif-attr.Key#_One = inExtGdsValueObj:GdsCode
          buf_ext-classif-attr.key#_two = ExtSystem
          buf_ext-classif-attr.key#_three = 0
          buf_ext-classif-attr.charkey_one = inExtGdsValueObj:AlcCode
          buf_ext-classif-attr.charkey_two = ""
          buf_ext-classif-attr.charkey_three = ""
          buf_ext-classif-attr.attr-code = 'egais-info'.
      end.
      glog = SaveEGAISInfoDB (inExtGdsValueObj).
    end.
    return glog.
  end.
  method private logical SaveEGAISInfoDB (inExtGdsValueObj as ExtGdsValue):
    def var v-prod  as char no-undo.
    def var v-impor as char no-undo.
    def var v-msg   as char no-undo.
    ReturnMsg = "".
    v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5).
    v-impor = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5).
    entry (1, v-prod, chr(5)) = inExtGdsValueObj:CliRegIdProd.
    entry (2, v-prod, chr(5)) = inExtGdsValueObj:INNProd.
    entry (3, v-prod, chr(5)) = inExtGdsValueObj:KPPProd.
    entry (4, v-prod, chr(5)) = inExtGdsValueObj:FullNameProd.
    entry (5, v-prod, chr(5)) = inExtGdsValueObj:CountryProd.
    entry (6, v-prod, chr(5)) = inExtGdsValueObj:DescrProd.
    entry (7, v-prod, chr(5)) = inExtGdsValueObj:CliEgaisTypeProd.
    entry (8, v-prod, chr(5)) = inExtGdsValueObj:RegionProd.
    entry (1, v-impor, chr(5)) = inExtGdsValueObj:CliRegIdImpor.
    entry (2, v-impor, chr(5)) = inExtGdsValueObj:INNImpor.
    entry (3, v-impor, chr(5)) = inExtGdsValueObj:KPPImpor.
    entry (4, v-impor, chr(5)) = inExtGdsValueObj:FullNameImpor.
    entry (5, v-impor, chr(5)) = inExtGdsValueObj:CountryImpor.
    entry (6, v-impor, chr(5)) = inExtGdsValueObj:DescrImpor.
    entry (7, v-impor, chr(5)) = inExtGdsValueObj:CliEgaisTypeImpor.
    entry (8, v-impor, chr(5)) = inExtGdsValueObj:RegionImpor.
    buf_ext-classif-attr.attr-value = v-prod + chr(4) + v-impor + chr(4) + inExtGdsValueObj:FullNameGds + chr(4) + string (inExtGdsValueObj:Capacity).
    release buf_ext-classif-attr.
  end.
  method public void Release_ ():
    ClearProp().
  end.
  method public logical CopyEgaisInfo (inExtGdsValueObjForm as ExtGdsValue, inExtGdsValueObjTo as class ExtGdsValue) :
    ReturnMsg = "".
    if not valid-object (inExtGdsValueObjForm) or not valid-object (inExtGdsValueObjTo)
    then do:
      ReturnMsg = "Не найден объект inExtGdsValueObjForm или inExtGdsValueObjTo".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
      return false.
    end.
    assign
      inExtGdsValueObjTo:CliRegIdImpor = inExtGdsValueObjForm:CliRegIdImpor
      inExtGdsValueObjTo:CliRegIdProd = inExtGdsValueObjForm:CliRegIdProd
      inExtGdsValueObjTo:CountryImpor = inExtGdsValueObjForm:CountryImpor
      inExtGdsValueObjTo:CountryProd = inExtGdsValueObjForm:CountryProd
      inExtGdsValueObjTo:DescrImpor = inExtGdsValueObjForm:DescrImpor
      inExtGdsValueObjTo:DescrProd = inExtGdsValueObjForm:DescrProd
      inExtGdsValueObjTo:FullNameGds = inExtGdsValueObjForm:FullNameGds
      inExtGdsValueObjTo:Capacity = inExtGdsValueObjForm:Capacity
      inExtGdsValueObjTo:FullNameImpor = inExtGdsValueObjForm:FullNameImpor
      inExtGdsValueObjTo:FullNameProd = inExtGdsValueObjForm:FullNameProd
      inExtGdsValueObjTo:INNImpor = inExtGdsValueObjForm:INNImpor
      inExtGdsValueObjTo:INNProd = inExtGdsValueObjForm:INNProd
      inExtGdsValueObjTo:KPPImpor = inExtGdsValueObjForm:KPPImpor
      inExtGdsValueObjTo:KPPProd = inExtGdsValueObjForm:KPPProd
      inExtGdsValueObjTo:CliEgaisTypeImpor = inExtGdsValueObjForm:CliEgaisTypeImpor
      inExtGdsValueObjTo:CliEgaisTypeProd = inExtGdsValueObjForm:CliEgaisTypeProd
      inExtGdsValueObjTo:RegionImpor = inExtGdsValueObjForm:RegionImpor
      inExtGdsValueObjTo:RegionProd = inExtGdsValueObjForm:RegionProd
    no-error.
    if error-status:error
    then do:
      ReturnMsg = "Ошибка присвоения свойств объекта inExtGdsValueObjTo".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
      return false.
    end.
    return true.
  end.
  method private integer GetExtSystem ():
    define variable v-value-character as character no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-value-type      as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-ext-sys         as integer   no-undo .
    empty temp-table thbjattr_thbj-attr.
    run adm/shattri.p (
      input "get":U
      ,input '':U
      ,input 0
      ,input 'egais':U
      ,input 'egais-exsys':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output table thbjattr_thbj-attr
      ) no-error .
    return v-value-integer .
  end.
  method private void setProp (inJJ as int):
    def var v-prod  as char no-undo.
    def var v-impor as char no-undo.
    def var v-msg   as char no-undo.
    def var hndlclsExtGdsValueObj as class ExtGdsValue no-undo.
    def var ExtGdsValueObj as class ExtGdsValue no-undo.
    v-prod = ''.
    v-impor = ''.
    ReturnMsg = "".
    hndlclsExtGdsValueObj = new ExtGdsValue().
    create ttObjEgaisAlcProp.
    assign
      ttObjEgaisAlcProp.iExtGdsObj = inJJ
      ttObjEgaisAlcProp.ExtGdsValueObj = cast (hndlclsExtGdsValueObj,Progress.Lang.Object).
    find current buf_ext-classif-attr no-lock no-error.
    if not available (buf_ext-classif-attr)
      then
    do:
      ReturnMsg = ReturnMsg + " Товар" + string (hndlclsExtGdsValueObj:AlcCode) + "/" + string (hndlclsExtGdsValueObj:GdsCode) + ". Выполните синхронизацию товаров.".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
    end.
    if available (buf_ext-classif-attr)
    then
      assign
        ExtGdsValueObj = GetInfoObj (buf_ext-classif-attr.attr-value)
      no-error.
    else
      assign
        ExtGdsValueObj = GetInfoObj ("")
      no-error.
    if ReturnMsg <> ""
      then
    do:
      ReturnMsg = ReturnMsg + " Товар" + string (buf_ext-classif.key#_one) + ". Выполните синхронизацию товаров.".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
    end.
    ExtGdsValueObj:AlcCode = buf_ext-classif.CharKey_One.
    ExtGdsValueObj:GdsCode = buf_ext-classif.Key#_One.
    assign
      hndlclsExtGdsValueObj:AlcCode = ExtGdsValueObj:AlcCode
      hndlclsExtGdsValueObj:GdsCode = ExtGdsValueObj:GdsCode
      hndlclsExtGdsValueObj:CliRegIdProd = ExtGdsValueObj:CliRegIdProd
      hndlclsExtGdsValueObj:INNProd = ExtGdsValueObj:INNProd
      hndlclsExtGdsValueObj:KPPProd = ExtGdsValueObj:KPPProd
      hndlclsExtGdsValueObj:FullNameProd = ExtGdsValueObj:FullNameProd
      hndlclsExtGdsValueObj:CountryProd = ExtGdsValueObj:CountryProd
      hndlclsExtGdsValueObj:DescrProd = ExtGdsValueObj:DescrProd
      hndlclsExtGdsValueObj:CliEgaisTypeProd = ExtGdsValueObj:CliEgaisTypeProd
      hndlclsExtGdsValueObj:RegionProd = ExtGdsValueObj:RegionProd
      hndlclsExtGdsValueObj:CliRegIdImpor = ExtGdsValueObj:CliRegIdImpor
      hndlclsExtGdsValueObj:INNImpor = ExtGdsValueObj:INNImpor
      hndlclsExtGdsValueObj:KPPImpor = ExtGdsValueObj:KPPImpor
      hndlclsExtGdsValueObj:FullNameImpor = ExtGdsValueObj:FullNameImpor
      hndlclsExtGdsValueObj:CountryImpor = ExtGdsValueObj:CountryImpor
      hndlclsExtGdsValueObj:DescrImpor = ExtGdsValueObj:DescrImpor
      hndlclsExtGdsValueObj:CliEgaisTypeImpor = ExtGdsValueObj:CliEgaisTypeImpor
      hndlclsExtGdsValueObj:RegionImpor = ExtGdsValueObj:RegionImpor
      hndlclsExtGdsValueObj:FullNameGds = ExtGdsValueObj:FullNameGds
      hndlclsExtGdsValueObj:Capacity = ExtGdsValueObj:Capacity
    .
    hndlclsExtGdsValueObj:extFormF1Obj:OpenQueryExtFormF1(ExtGdsValueObj:AlcCode).
    if valid-object (ExtGdsValueObj)
      then delete object ExtGdsValueObj.
  end.
  method private void ClearProp ():
    AlcCodeItemQuery = "".
    GdsCodeItemQuery = 0.
    NumBundles = 0.
    for each ttObjEgaisAlcProp:
      if valid-object (ttObjEgaisAlcProp.ExtGdsValueObj)
        then delete object ttObjEgaisAlcProp.ExtGdsValueObj.
    end.
    empty temp-table ttObjEgaisAlcProp.
  end.
  method public class ExtGdsValue GetInfoObj (inInfoValue as char):
    def var ExtGdsValueObj as class ExtGdsValue no-undo.
    def var v-msg   as char no-undo.
    def var v-prod  as char no-undo.
    def var v-impor as char no-undo.
    ExtGdsValueObj = new ExtGdsValue().
    if num-entries (inInfoValue, chr(4)) < 3
      then
    do:
      ReturnMsg = "Некорректный атрибут egais-info - " + inInfoValue.
      return ExtGdsValueObj.
    end.
    v-prod = entry (1, inInfoValue, chr(4)) no-error.
    if num-entries (v-prod, chr (5)) < 6
      then
    do:
      ReturnMsg = "Некорректный атрибут egais-info v-prod - " + inInfoValue.
      return ExtGdsValueObj.
    end.
    v-impor = entry (2, inInfoValue, chr(4)) no-error.
    if  num-entries (v-impor, chr (5)) < 6
      then
    do:
      ReturnMsg = "Некорректный атрибут egais-info v-impor - " + inInfoValue.
      return ExtGdsValueObj.
    end.
    ExtGdsValueObj:CliRegIdProd = entry (1, v-prod, chr(5)).
    ExtGdsValueObj:INNProd = entry (2, v-prod, chr(5)).
    ExtGdsValueObj:KPPProd = entry (3, v-prod, chr(5)).
    ExtGdsValueObj:FullNameProd = entry (4, v-prod, chr(5)).
    ExtGdsValueObj:CountryProd = entry (5, v-prod, chr(5)).
    ExtGdsValueObj:DescrProd = entry (6, v-prod, chr(5)).
    assign
    ExtGdsValueObj:CliEgaisTypeProd = entry (7, v-prod, chr(5)) when num-entries (v-prod, chr (5)) > 6
    ExtGdsValueObj:RegionProd = entry (8, v-prod, chr(5)) when num-entries (v-prod, chr (5)) > 7
    .
    ExtGdsValueObj:CliRegIdImpor = entry (1, v-impor, chr(5)).
    ExtGdsValueObj:INNImpor = entry (2, v-impor, chr(5)).
    ExtGdsValueObj:KPPImpor = entry (3, v-impor, chr(5)).
    ExtGdsValueObj:FullNameImpor = entry (4, v-impor, chr(5)).
    ExtGdsValueObj:CountryImpor = entry (5, v-impor, chr(5)).
    ExtGdsValueObj:DescrImpor = entry (6, v-impor, chr(5)).
    assign
    ExtGdsValueObj:CliEgaisTypeImpor = entry (7, v-impor, chr(5)) when num-entries (v-impor, chr (5)) > 6
    ExtGdsValueObj:RegionImpor = entry (8, v-impor, chr(5)) when num-entries (v-impor, chr (5)) > 7
    .
    ExtGdsValueObj:FullNameGds = entry (3, inInfoValue, chr(4)).
    if num-entries (inInfoValue, chr(4)) > 3
    then do:
      ExtGdsValueObj:Capacity = decimal (entry (4, inInfoValue, chr(4))) no-error.
      if error-status:error
      then do:
        ExtGdsValueObj:Capacity = 0.
      end.
    end.
    return ExtGdsValueObj.
  end.
end class.
