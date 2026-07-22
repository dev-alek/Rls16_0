using Progress.Lang.*.
using ibs.th.bge.egais.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ExtFormF1:
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
    field iExtFormF1Obj as integer
    field ExtFormF1ValueObj as class Progress.Lang.Object
    index pi is primary unique iExtFormF1Obj .
  define private buffer buf_ext-classif      for ub.ext-classif.
  define private buffer x_ext-classif        for ub.ext-classif.
  define private buffer buf_ext-classif-attr for ub.ext-classif-attr.
  define private buffer buf_gds for ub.goods.
  define private buffer buf_cli for ub.clients.
  define private variable listManagObj as class listmanager.
  define property ExtSystem as integer no-undo
    get.
    private set.
  define property DbNum as integer init 0 no-undo
    get.
    set.
  define property IsSilent as logical no-undo
    get.
    private set.
  define property FormF1CodeItemQuery as character no-undo
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
  define property SettingsTTList as character no-undo init ";;;;;23,yes;;;1,no"
    get.
    private set.
  define temp-table tt-egaisformf1-hndls no-undo
    field mark                as character format "X(1)" label "*"
    field formF1Code          as character label "Код справки 1" format "x(21)"
    field alcCode             as character label "Алк. код товара" format "x(21)"
    field BottlingDate        as character label "Дата розлива" format "x(10)"
    field CliEgaisTypeOrigCli as character label "Тип" format "x(2)"
    field CliRegIdOrigCli     as character label "Код клиента ЕГАИС" format "x(21)"
    field INNOrigCli          as character label "ИНН клиента ЕГАИС" format "x(10)"
    field KPPOrigCli          as character label "КПП клиента ЕГАИС" format "x(10)"
    field ColorNum            as integer init ?
    index pi as primary
    alcCode formF1Code
    .
  constructor public ExtFormF1 (inIsSilent as logical):
    ExtSystem = getExtSystem().
    IsSilent = inIsSilent.
    if ExtSystem = 0 or ExtSystem = ?
      then
    do:
      if not IsSilent
        then message "Отсутсвует ВС настроенная для обмена с ЕГАИС" view-as alert-box.
      return error "Отсутсвует ВС настроенная для обмена с ЕГАИС".
    end.
    listManagObj = new listmanager ().
  end constructor.
  destructor public ExtFormF1 ():
    if valid-object (listManagObj)
      then delete object listManagObj.
    ClearProp().
  end destructor.
  method public void GetHndlTable (inFormF1Code as char, inAlcCode as char, input-output outTTHndl as handle):
    def var ExtFormF1ValueObj as ExtFormF1Value no-undo.
    assign
      ReturnMsg = ""
    .
    empty temp-table tt-egaisformf1-hndls.
    for each buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'EGAIS':U
      and buf_ext-classif.classif-name = 'FormF1-esys':U
      and buf_ext-classif.db-num = 0
      and (inFormF1Code = "" or buf_ext-classif.CharKey_Two = inFormF1Code)
      and buf_ext-classif.key#_two = ExtSystem
      and buf_ext-classif.key#_three = 0
      and (inAlcCode = "" or buf_ext-classif.charkey_one = inAlcCode)
      and buf_ext-classif.Key#_One = 0
      and buf_ext-classif.charkey_three = ""
      and buf_ext-classif.nonunique = 0
      :
      find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = buf_ext-classif.classif-subject
        and buf_ext-classif-attr.classif-name = buf_ext-classif.classif-name
        and buf_ext-classif-attr.db-num = buf_ext-classif.db-num
        and buf_ext-classif-attr.Key#_One = buf_ext-classif-attr.Key#_One
        and buf_ext-classif-attr.Key#_two = buf_ext-classif.key#_two
        and buf_ext-classif-attr.Key#_three = buf_ext-classif.key#_three
        and buf_ext-classif-attr.CharKey_One = buf_ext-classif.charkey_one
        and buf_ext-classif-attr.CharKey_two = buf_ext-classif.charkey_two
        and buf_ext-classif-attr.CharKey_three = buf_ext-classif.charkey_three
        and buf_ext-classif-attr.nonunique = buf_ext-classif.nonunique
        and buf_ext-classif-attr.attr-code = 'egais-info'
        no-error .
        create tt-egaisformf1-hndls.
        if available (buf_ext-classif-attr)
        then
          assign
            ExtFormF1ValueObj = GetInfoObj (buf_ext-classif-attr.attr-value)
          no-error.
        else
          assign
            ExtFormF1ValueObj = GetInfoObj ("")
          no-error.
        if error-status:error or not available (buf_ext-classif-attr)
          then
        do:
          ReturnMsg = " Справка 1" + string (buf_ext-classif.CharKey_Two) + ". Выполните синхронизацию товаров.".
          if not IsSilent
            then message ReturnMsg view-as alert-box.
          tt-egaisformf1-hndls.ColorNum = RED_COLOR.
        end.
        ExtFormF1ValueObj:AlcCode = buf_ext-classif.CharKey_One.
        ExtFormF1ValueObj:FormF1Code = buf_ext-classif.CharKey_Two.
        assign
          tt-egaisformf1-hndls.alcCode = ExtFormF1ValueObj:AlcCode
          tt-egaisformf1-hndls.formF1Code = ExtFormF1ValueObj:FormF1Code
          tt-egaisformf1-hndls.BottlingDate = ExtFormF1ValueObj:BottlingDate
          tt-egaisformf1-hndls.CliEgaisTypeOrigCli = ExtFormF1ValueObj:CliEgaisTypeOrigCli
          tt-egaisformf1-hndls.CliRegIdOrigCli = ExtFormF1ValueObj:CliRegIdOrigCli
          tt-egaisformf1-hndls.INNOrigCli = ExtFormF1ValueObj:INNOrigCli
          tt-egaisformf1-hndls.KPPOrigCli = ExtFormF1ValueObj:KPPOrigCli
          tt-egaisformf1-hndls.ColorNum = RED_COLOR when ExtFormF1ValueObj:INNOrigCli = ""
        .
    end.
    outTTHndl = buffer tt-egaisformf1-hndls:handle.
    if valid-object (ExtFormF1ValueObj)
      then delete object ExtFormF1ValueObj.
  end.
  method public logical OpenQueryExtFormF1 (inFormF1Code as char):
    return OpenQueryExtFormF1 (inFormF1Code, "").
  end.
  method public logical OpenQueryExtFormF1 (inFormF1Code as char, inAlcCode as char):
    def var ii as int no-undo.
    ClearProp().
    assign
      ReturnMsg = ""
      AlcCodeItemQuery = inAlcCode
      FormF1CodeItemQuery = inFormF1Code
      ii = 0.
    for each buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'EGAIS':U
      and buf_ext-classif.classif-name = 'FormF1-esys':U
      and buf_ext-classif.db-num = 0
      and (FormF1CodeItemQuery = "" or buf_ext-classif.CharKey_Two = FormF1CodeItemQuery)
      and buf_ext-classif.key#_two = ExtSystem
      and buf_ext-classif.key#_three = 0
      and (AlcCodeItemQuery = "" or buf_ext-classif.charkey_one = AlcCodeItemQuery)
      and buf_ext-classif.Key#_One = 0
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
  method public class ExtFormF1Value GetExtFormF1Value () :
    return GetExtFormF1Value (1).
  end.
  method public class ExtFormF1Value GetExtFormF1Value (inJJ as int) :
    find first ttObjEgaisAlcProp where ttObjEgaisAlcProp.iExtFormF1Obj = inJJ no-error.
    if not available (ttObjEgaisAlcProp)
      then return ?.
    return cast (ttObjEgaisAlcProp.ExtFormF1ValueObj, ibs.th.bge.egais.ExtFormF1Value).
  end.
  method public logical CreateExtFormF1 (inFormF1Code as character, inAlcCode as char):
    define variable extFormF1ValueObj as class ExtFormF1Value no-undo.
    define variable glog as logical no-undo.
    extFormF1ValueObj = new ExtFormF1Value().
    extFormF1ValueObj:AlcCode = inAlcCode.
    extFormF1ValueObj:FormF1Code = inFormF1Code.
    glog = CreateExtFormF1(extFormF1ValueObj) .
    if not glog
      then if valid-object (extFormF1ValueObj)
                  then delete object extFormF1ValueObj.
    return glog.
  end.
  method public logical WriteExtFormF1 (inExtFormF1ValueObj as class ExtFormF1Value):
    OpenQueryExtFormF1(inExtFormF1ValueObj:FormF1Code, inExtFormF1ValueObj:AlcCode).
    if NumBundles = 1
    then do:
      if not SaveEGAISInfoDB (inExtFormF1ValueObj)
      then do:
        AlcCodeItemQuery = "".
        FormF1CodeItemQuery = "".
        undo, return false.
      end.
      return true.
    end.
    else do:
      if not CreateExtFormF1 (inExtFormF1ValueObj)
      then do:
        AlcCodeItemQuery = "".
        FormF1CodeItemQuery = "".
        undo, return false.
      end.
      return true.
    end.
    return false.
  end.
  method public logical CreateExtFormF1 (inExtFormF1ValueObj as class ExtFormF1Value):
    ClearProp().
    assign
      ReturnMsg = ""
      AlcCodeItemQuery = inExtFormF1ValueObj:AlcCode
      FormF1CodeItemQuery = inExtFormF1ValueObj:FormF1Code
    .
    if inExtFormF1ValueObj:AlcCode = ? or inExtFormF1ValueObj:AlcCode = ""
    then do:
      ReturnMsg = "Неверное значение AlcCode".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
      AlcCodeItemQuery = "".
      FormF1CodeItemQuery = "".
      undo, return false.
    end.
    do trans:
      find first buf_ext-classif no-lock  where buf_ext-classif.classif-subject = 'EGAIS':U
        and buf_ext-classif.classif-name = 'FormF1-esys':U
        and buf_ext-classif.db-num = 0
        and buf_ext-classif.Key#_One = 0
        and buf_ext-classif.key#_two = ExtSystem
        and buf_ext-classif.key#_three = 0
        and buf_ext-classif.charkey_one = inExtFormF1ValueObj:AlcCode
        and buf_ext-classif.charkey_two = inExtFormF1ValueObj:FormF1Code
        and buf_ext-classif.charkey_three = ""
        and buf_ext-classif.nonunique = 0
        no-error.
      if available (buf_ext-classif)
        then
      do:
        ReturnMsg = "Уже есть запись товара ЕГАИС - " + inExtFormF1ValueObj:AlcCode + " cо справкой 1 - " + string (inExtFormF1ValueObj:FormF1Code).
        if not IsSilent
          then message ReturnMsg view-as alert-box.
        AlcCodeItemQuery = "".
        FormF1CodeItemQuery = "".
        undo, return false.
      end.
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-subject = 'EGAIS':U
        buf_ext-classif.classif-name = 'FormF1-esys':U
        buf_ext-classif.db-num = 0
        buf_ext-classif.Key#_One = 0
        buf_ext-classif.key#_two = ExtSystem
        buf_ext-classif.key#_three = 0
        buf_ext-classif.charkey_one = inExtFormF1ValueObj:AlcCode
        buf_ext-classif.charkey_two = inExtFormF1ValueObj:FormF1Code
        buf_ext-classif.charkey_three = ""
        buf_ext-classif.nonunique = 0
        buf_ext-classif.uniq-key-rec = 'EGAIS':U + chr(3) + string (inExtFormF1ValueObj:FormF1Code)
      no-error.
      if error-status:error
        then
      do:
        delete buf_ext-classif.
        ReturnMsg = "Непредвиденная ошибка при создании связки  - " + inExtFormF1ValueObj:AlcCode + " TH - " + string (inExtFormF1ValueObj:FormF1Code).
        if not IsSilent
          then message ReturnMsg view-as alert-box.
        AlcCodeItemQuery = "".
        FormF1CodeItemQuery = "".
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
        ReturnMsg = "Запись уже есть buf_ext-classif-attr. Создание будет продолжено. Непредвиденная ситуация при создании атрибута egais-info  - " + inExtFormF1ValueObj:AlcCode + " TH - " + string (inExtFormF1ValueObj:FormF1Code).
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
      if not SaveEGAISInfoDB (inExtFormF1ValueObj)
        then do:
          AlcCodeItemQuery = "".
          FormF1CodeItemQuery = "".
          undo, return false.
        end.
    end.
    create ttObjEgaisAlcProp.
    NumBundles = 1.
    ttObjEgaisAlcProp.iExtFormF1Obj = 1.
    cast (ttObjEgaisAlcProp.ExtFormF1ValueObj, ibs.th.bge.egais.ExtFormF1Value) = inExtFormF1ValueObj.
    return true.
  end.
  method public logical DeleteExtFormF1 (inFormF1Code as character, inAlcCode as char):
    ReturnMsg = "".
    do trans:
      for each buf_ext-classif-attr exclusive-lock where
            buf_ext-classif-attr.classif-subject = 'EGAIS':U
        and buf_ext-classif-attr.classif-name = 'FormF1-esys':U
        and buf_ext-classif-attr.db-num = 0
        and (inFormF1Code = ? or inFormF1Code = "" or buf_ext-classif-attr.CharKey_Two = inFormF1Code)
        and buf_ext-classif-attr.key#_two = ExtSystem
        and (inAlcCode = ? or inAlcCode = "" or buf_ext-classif-attr.charkey_one = inAlcCode)
        :
        delete buf_ext-classif-attr.
      end.
      for each buf_ext-classif exclusive-lock where
            buf_ext-classif.classif-subject = 'EGAIS':U
        and buf_ext-classif.classif-name = 'FormF1-esys':U
        and buf_ext-classif.db-num = 0
        and buf_ext-classif.key#_two = ExtSystem
        and (inFormF1Code = ? or inFormF1Code = "" or buf_ext-classif.CharKey_Two = inFormF1Code)
        and (inAlcCode = ? or inAlcCode = "" or buf_ext-classif.charkey_one = inAlcCode)
        :
        delete buf_ext-classif.
      end.
    end.
    ClearProp ().
    return true.
  end.
  method public logical SaveEGAISInfo (inExtFormF1ValueObj as ExtFormF1Value):
    def var glog as log no-undo.
    do trans:
      find first buf_ext-classif-attr where
            buf_ext-classif-attr.classif-subject = 'EGAIS':U
        and buf_ext-classif-attr.classif-name = 'FormF1-esys':U
        and buf_ext-classif-attr.db-num = 0
        and buf_ext-classif-attr.Key#_One = 0
        and buf_ext-classif-attr.key#_two = ExtSystem
        and buf_ext-classif-attr.key#_three = 0
        and buf_ext-classif-attr.charkey_one = inExtFormF1ValueObj:AlcCode
        and buf_ext-classif-attr.charkey_two = inExtFormF1ValueObj:FormF1Code
        and buf_ext-classif-attr.charkey_three = ""
        and buf_ext-classif-attr.attr-code = 'egais-info' no-error
      .
      if not available (buf_ext-classif-attr)
        then do:
          create buf_ext-classif-attr.
          assign
            buf_ext-classif-attr.classif-subject = 'EGAIS':U
            buf_ext-classif-attr.classif-name = 'FormF1-esys':U
            buf_ext-classif-attr.db-num = 0
            buf_ext-classif-attr.Key#_One = 0
            buf_ext-classif-attr.key#_two = ExtSystem
            buf_ext-classif-attr.key#_three = 0
            buf_ext-classif-attr.charkey_one = inExtFormF1ValueObj:AlcCode
            buf_ext-classif-attr.charkey_two = inExtFormF1ValueObj:FormF1Code
            buf_ext-classif-attr.charkey_three = ""
            buf_ext-classif-attr.attr-code = 'egais-info'.
        end.
      glog = SaveEGAISInfoDB (inExtFormF1ValueObj).
    end.
    return glog.
  end.
  method private logical SaveEGAISInfoDB (inExtFormF1ValueObj as ExtFormF1Value):
    def var v-list-data  as char no-undo.
    def var v-msg   as char no-undo.
    ReturnMsg = "".
    listManagObj:WriteElement (v-list-data, "BottlingDate", inExtFormF1ValueObj:BottlingDate).
    listManagObj:WriteElement (v-list-data, "CliRegIdOrigCli", inExtFormF1ValueObj:CliRegIdOrigCli).
    listManagObj:WriteElement (v-list-data, "CliEgaisTypeOrigCli", inExtFormF1ValueObj:CliEgaisTypeOrigCli).
    listManagObj:WriteElement (v-list-data, "INNOrigCli", inExtFormF1ValueObj:INNOrigCli).
    listManagObj:WriteElement (v-list-data, "KPPOrigCli", inExtFormF1ValueObj:KPPOrigCli).
    listManagObj:WriteElement (v-list-data, "FullNameOrigCli", inExtFormF1ValueObj:FullNameOrigCli).
    listManagObj:WriteElement (v-list-data, "RegionOrigCli", inExtFormF1ValueObj:RegionOrigCli).
    listManagObj:WriteElement (v-list-data, "DescrOrigCli", inExtFormF1ValueObj:DescrOrigCli).
    buf_ext-classif-attr.attr-value = v-list-data.
    release buf_ext-classif-attr.
  end.
  method public void Release_ ():
    ClearProp().
  end.
  method public logical CopyEgaisInfo (inExtFormF1ValueObjForm as ExtFormF1Value, inExtFormF1ValueObjTo as ExtFormF1Value) :
    ReturnMsg = "".
    if not valid-object (inExtFormF1ValueObjForm) or not valid-object (inExtFormF1ValueObjTo)
    then do:
      ReturnMsg = "Не найден объект inExtFormF1ValueObjForm или inExtFormF1ValueObjTo".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
      return false.
    end.
    assign
      inExtFormF1ValueObjTo:BottlingDate = inExtFormF1ValueObjForm:BottlingDate
      inExtFormF1ValueObjTo:CliRegIdOrigCli = inExtFormF1ValueObjForm:CliRegIdOrigCli
      inExtFormF1ValueObjTo:CliEgaisTypeOrigCli = inExtFormF1ValueObjForm:CliEgaisTypeOrigCli
      inExtFormF1ValueObjTo:INNOrigCli = inExtFormF1ValueObjForm:INNOrigCli
      inExtFormF1ValueObjTo:KPPOrigCli = inExtFormF1ValueObjForm:KPPOrigCli
      inExtFormF1ValueObjTo:FullNameOrigCli = inExtFormF1ValueObjForm:FullNameOrigCli
      inExtFormF1ValueObjTo:CountryOrigCli = inExtFormF1ValueObjForm:CountryOrigCli
      inExtFormF1ValueObjTo:RegionOrigCli = inExtFormF1ValueObjForm:RegionOrigCli
      inExtFormF1ValueObjTo:DescrOrigCli = inExtFormF1ValueObjForm:DescrOrigCli
    no-error.
    if error-status:error
    then do:
      ReturnMsg = "Ошибка присвоения свойств объекта inExtFormF1ValueObjTo".
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
    def var hndlclsExtFormF1ValueObj as class ExtFormF1Value no-undo.
    def var ExtFormF1ValueObj as class ExtFormF1Value no-undo.
    v-prod = ''.
    v-impor = ''.
    ReturnMsg = "".
    hndlclsExtFormF1ValueObj = new ExtFormF1Value().
    create ttObjEgaisAlcProp.
    assign
      ttObjEgaisAlcProp.iExtFormF1Obj = inJJ
      ttObjEgaisAlcProp.ExtFormF1ValueObj = cast (hndlclsExtFormF1ValueObj,Progress.Lang.Object).
    hndlclsExtFormF1ValueObj:AlcCode = buf_ext-classif.CharKey_One.
    hndlclsExtFormF1ValueObj:FormF1Code = buf_ext-classif.CharKey_Two.
    find current buf_ext-classif-attr no-lock no-error.
    if not available (buf_ext-classif-attr)
      then
    do:
      ReturnMsg = ReturnMsg + " Товар" + string (hndlclsExtFormF1ValueObj:AlcCode) + "/" + string (hndlclsExtFormF1ValueObj:FormF1Code) + ". Выполните синхронизацию товаров.".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
    end.
    if available (buf_ext-classif-attr)
    then
      assign
        ExtFormF1ValueObj = GetInfoObj (buf_ext-classif-attr.attr-value)
      no-error.
    else
      assign
        ExtFormF1ValueObj = GetInfoObj ("")
      no-error.
    if ReturnMsg <> ""
      then
    do:
      ReturnMsg = ReturnMsg + " Товар" + string (hndlclsExtFormF1ValueObj:AlcCode) + "/" + string (hndlclsExtFormF1ValueObj:FormF1Code) + ". Выполните синхронизацию товаров.".
      if not IsSilent
        then message ReturnMsg view-as alert-box.
    end.
    ExtFormF1ValueObj:AlcCode = buf_ext-classif.CharKey_One.
    ExtFormF1ValueObj:FormF1Code = buf_ext-classif.CharKey_Two.
    assign
      hndlclsExtFormF1ValueObj:AlcCode = ExtFormF1ValueObj:AlcCode
      hndlclsExtFormF1ValueObj:FormF1Code = ExtFormF1ValueObj:FormF1Code
      hndlclsExtFormF1ValueObj:BottlingDate = ExtFormF1ValueObj:BottlingDate
      hndlclsExtFormF1ValueObj:CliRegIdOrigCli = ExtFormF1ValueObj:CliRegIdOrigCli
      hndlclsExtFormF1ValueObj:CliEgaisTypeOrigCli = ExtFormF1ValueObj:CliEgaisTypeOrigCli
      hndlclsExtFormF1ValueObj:INNOrigCli = ExtFormF1ValueObj:INNOrigCli
      hndlclsExtFormF1ValueObj:KPPOrigCli = ExtFormF1ValueObj:KPPOrigCli
      hndlclsExtFormF1ValueObj:FullNameOrigCli = ExtFormF1ValueObj:FullNameOrigCli
      hndlclsExtFormF1ValueObj:CountryOrigCli = ExtFormF1ValueObj:CountryOrigCli
      hndlclsExtFormF1ValueObj:RegionOrigCli = ExtFormF1ValueObj:RegionOrigCli
      hndlclsExtFormF1ValueObj:DescrOrigCli = ExtFormF1ValueObj:DescrOrigCli
    .
    if valid-object (ExtFormF1ValueObj)
      then delete object ExtFormF1ValueObj.
  end.
  method private void ClearProp ():
    AlcCodeItemQuery = "".
    FormF1CodeItemQuery = "".
    NumBundles = 0.
    for each ttObjEgaisAlcProp:
      if valid-object (ttObjEgaisAlcProp.ExtFormF1ValueObj)
        then delete object ttObjEgaisAlcProp.ExtFormF1ValueObj.
    end.
    empty temp-table ttObjEgaisAlcProp.
  end.
  method public class ExtFormF1Value GetInfoObj (inInfoValue as char):
    def var ExtFormF1ValueObj as class ExtFormF1Value no-undo.
    ExtFormF1ValueObj = new ExtFormF1Value().
    ExtFormF1ValueObj:BottlingDate = listManagObj:ReadElement (inInfoValue, "BottlingDate").
    ExtFormF1ValueObj:CliRegIdOrigCli =  listManagObj:ReadElement (inInfoValue, "CliRegIdOrigCli").
    ExtFormF1ValueObj:CliEgaisTypeOrigCli = listManagObj:ReadElement (inInfoValue, "CliEgaisTypeOrigCli").
    ExtFormF1ValueObj:INNOrigCli = listManagObj:ReadElement (inInfoValue, "INNOrigCli").
    ExtFormF1ValueObj:KPPOrigCli = listManagObj:ReadElement (inInfoValue, "KPPOrigCli").
    ExtFormF1ValueObj:FullNameOrigCli = listManagObj:ReadElement (inInfoValue, "FullNameOrigCli").
    ExtFormF1ValueObj:CountryOrigCli = listManagObj:ReadElement (inInfoValue, "CountryOrigCli").
    ExtFormF1ValueObj:RegionOrigCli = listManagObj:ReadElement (inInfoValue, "RegionOrigCli").
    ExtFormF1ValueObj:DescrOrigCli = listManagObj:ReadElement (inInfoValue, "DescrOrigCli").
    return ExtFormF1ValueObj.
  end.
end class.
