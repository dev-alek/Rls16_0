using Progress.Lang.*.
using ibs.th.gbl.gbl-var.
using ibs.th.ref.typl-ad.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impshops implements ibs.th.bge.1crn.import.iimpsubject:
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
  // thbjattr_thbj-attr
  define property Msg as character no-undo
    get.
    set.
DEFINE TEMP-TABLE TT_cassa NO-UNDO LIKE ub.price-list-type-cassa.
DEFINE TEMP-TABLE TT_grp   NO-UNDO LIKE ub.price-list-type-gds-grp.
DEFINE TEMP-TABLE TT_pay-type NO-UNDO LIKE ub.price-list-type-pay-type.
DEFINE TEMP-TABLE TT_cash-pay NO-UNDO LIKE ub.price-list-type-cash-pay.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode      as character no-undo.
    define variable v-rid1      as recid no-undo .
    define variable v-rid2      as recid no-undo .
    define variable v-obj-code  as integer no-undo .
    define variable v-db-num    as integer no-undo .
    define variable v-host-code as integer no-undo .
    define variable v-grp-code  as integer no-undo .
    define variable v-addr1     as character no-undo .
    define variable v-addr2     as character no-undo .
    define variable v-tel       as character no-undo .
    define variable v-retfl     as logical no-undo .
    define buffer buf_shop    for ub.shop .
    define buffer buf_clients for ub.clients .
    define variable v-ps             as character no-undo .
    define variable v-all-prt        as logical no-undo .
    define variable v-buy-goods      as logical no-undo .
    define variable v-cd-bc-alt      as logical no-undo .
    define variable v-cd-bc-base     as logical no-undo .
    define variable v-cd-loc-alt     as logical no-undo .
    define variable v-cd-loc-base    as logical no-undo .
    define variable v-cd-parts-all   as logical no-undo .
    define variable v-cd-parts-not-blank as logical no-undo .
    define variable v-cd-parts-ser   as logical no-undo .
    define variable v-cd-pb-alt      as logical no-undo .
    define variable v-cd-pb-base     as logical no-undo .
    define variable v-cd-sc-base     as logical no-undo .
    define variable v-chk-pay        as integer no-undo .
    define variable v-day-only       as logical no-undo .
    define variable v-discaloc       as logical no-undo .
    define variable v-doc-prt        as logical no-undo .
    define variable v-down-pay       as integer no-undo .
    define variable v-fax            as character no-undo .
    define variable v-goods-man      as character no-undo .
    define variable v-in-ov          as logical no-undo .
    define variable v-in-pay         as integer no-undo .
    define variable v-in-perm        as logical no-undo .
    define variable v-inout-price    as logical no-undo .
    define variable v-inv-pay        as integer no-undo .
    define variable v-is-catering        as logical no-undo .
    define variable v-is-kitchen         as logical no-undo .
    define variable v-is-kitchen-store   as logical no-undo .
    define variable v-kitchen-store-code as integer no-undo .
    define variable v-kitchen-store-type as character no-undo .
    define variable v-no-eq          as logical no-undo .
    define variable v-out-line-discnt as logical no-undo .
    define variable v-out-pay        as integer no-undo .
    define variable v-out-rate       as logical no-undo .
    define variable v-pr-cash        as logical no-undo .
    define variable v-price-calc     as logical no-undo .
    define variable v-ret-pay        as integer no-undo .
    define variable v-ret-sup-pay    as integer no-undo .
    define variable v-fbr-pay        as integer no-undo .
    define variable v-rsrv-time      as integer no-undo .
    define variable v-shift-on       as logical no-undo .
    define variable v-store-boss     as character no-undo .
    define variable v-store-man      as character no-undo .
    define variable v-sub-store-on   as logical no-undo .
    define variable v-sub-store-code as integer no-undo .
    define variable v-sub-store-type as character no-undo .
    define variable v-unit-cli-perm  as logical no-undo .
    define variable v-with-serv      as logical no-undo .
    define variable v-work-hours     as character no-undo .
    define variable v-purch-code     as integer no-undo .
    define variable v-envd           as logical no-undo .
    define variable v-envd-str       as character no-undo .
    define variable v-par-type       as character no-undo .
    define variable v-pharm          as logical no-undo .
    define variable v-pharm-str      as character no-undo .
    define variable v-KPP            as character no-undo .
    define variable v-clim-grp       as character no-undo .
    define variable v-decommissioned as logical no-undo .
    define variable v-decommiss-str  as character no-undo .
    define variable v-begin-summer   as character no-undo .
    define variable v-begin-winter   as character no-undo .
    define variable v-edi            as logical   no-undo .
    define variable objImp as class shops no-undo.
    objImp = cast (subjectObj, shops).
    if objImp:del-f > 0 then do:
      Msg = "физичесткое удаление АЗС/АЗК не предусмотрено" .
      v-retfl = false .
      return false.
    end .
    assign
      v-obj-code  = integer(objImp:code_)
    .
    if v-obj-code > 0 then . else undo, throw new Progress.Lang.AppError("Не задан код АЗК/АЗС") .
    if (objImp:clim-grp > "") and (not can-do("1 (1),1 (2),2 (1),2 (2),2 (3),3 (1),3 (2)", objImp:clim-grp)) then do :
      undo, throw new Progress.Lang.AppError(
        substitute("значение clim-grp = [&1] отсутствует в обозначении климатических групп", objImp:clim-grp)
      ) .
    end .
    find first buf_shop no-lock where buf_shop.obj-code = v-obj-code no-error .
    find first buf_clients no-lock
         where buf_clients.obj-type = 'маг':U
           and buf_clients.obj-code = v-obj-code no-error .
    if objImp:del-l > 0  then do:
      if available buf_clients and buf_clients.stts = 0 then do:
        run ref/clients2.p
        (input ?
        ,input recid(buf_clients)
        ,input 1
        ,input true
        ,input yes
        ,input '':U
        ,input '':U
        ,input '':U
        ) .
      end .
      else undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи МАГАЗИН с кодом [&1]", v-obj-code)
      ) .
    end .
    else if (available buf_shop) and (objImp:del-l = 0) then do:
      if available buf_clients then do:
        if buf_clients.stts <> 0 then do:
          run ref/clients2.p
          (input ?
          ,input recid(buf_clients)
          ,input 0
          ,input true
          ,input yes
          ,input '':U
          ,input '':U
          ,input '':U
          ) .
        end.
      end .
      else undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи МАГАЗИН с кодом [&1]", v-obj-code)
      ) .
    end .
    assign
      Msg = ""
      v-host-code = integer(objImp:frm-code)
      v-db-num    = v-obj-code
      v-grp-code  = v-host-code
    .
    if available buf_shop then do:
      if available buf_clients then do:
        assign
          v-rid2 = recid(buf_clients)
          v-ps   = buf_clients.PS
        .
      end .
      else undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи МАГАЗИН с кодом [&1]", v-obj-code)
      ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input 'маг':U
      ,input  v-obj-code
      ,input  'envd':U
      ,output v-envd-str
      ,output v-par-type
      ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input 'маг':U
      ,input  v-obj-code
      ,input  'pharm':U
      ,output v-pharm-str
      ,output v-par-type
      ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input 'маг':U
      ,input  v-obj-code
      ,input  'kpp':U
      ,output v-KPP
      ,output v-par-type
      ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input 'маг':U
      ,input  v-obj-code
      ,input  'cli-clim-grp':U
      ,output v-clim-grp
      ,output v-par-type
      ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input 'маг':U
      ,input  v-obj-code
      ,input  'cli-decommissioned':U
      ,output v-decommiss-str
      ,output v-par-type
      ) .
      sliceAddress
         ( input  objImp:address
         , input  buf_shop.addres1
         , input  buf_shop.addres2
         , output v-addr1
         , output v-addr2
         ) .
      assign
        v-tel = if objImp:tel >= "" then objImp:tel else buf_shop.phone
      .
      assign
        v-chk-pay        = buf_shop.chk-pay
        v-down-pay       = buf_shop.down-pay
        v-in-pay         = buf_shop.in-pay
        v-inv-pay        = buf_shop.inv-pay
        v-out-pay        = buf_shop.out-pay
        v-ret-pay        = buf_shop.ret-pay
        v-ret-sup-pay    = buf_shop.ret-sup-pay
        v-fbr-pay        = buf_shop.fbr-pay
      .
      assign
        v-mode = 'ИЗМЕНЕНИЕ':U
        v-all-prt         = buf_shop.all-prt
        v-buy-goods       = buf_shop.buy-goods
        v-cd-bc-alt       = buf_shop.cd-bc-alt
        v-cd-bc-base      = buf_shop.cd-bc-base
        v-cd-loc-alt      = buf_shop.cd-loc-alt
        v-cd-loc-base     = buf_shop.cd-loc-base
        v-cd-parts-all    = buf_shop.cd-parts-all
        v-cd-parts-not-blank = buf_shop.cd-parts-not-blank
        v-cd-parts-ser    = buf_shop.cd-parts-ser
        v-cd-pb-alt       = buf_shop.cd-pb-alt
        v-cd-pb-base      = buf_shop.cd-pb-base
        v-cd-sc-base      = buf_shop.cd-sc-base
        v-day-only        = buf_shop.day-only
        v-discaloc        = buf_shop.discaloc
        v-doc-prt         = buf_shop.doc-prt
        v-fax             = buf_shop.fax
        v-goods-man       = buf_shop.goods-man
        v-in-ov           = buf_shop.in-ov
        v-in-perm         = buf_shop.in-perm
        v-inout-price     = buf_shop.inout-price
        v-is-catering        = buf_shop.is-catering
        v-is-kitchen         = buf_shop.is-kitchen
        v-is-kitchen-store   = buf_shop.is-kitchen-store
        v-kitchen-store-code = buf_shop.kitchen-store-code
        v-kitchen-store-type = buf_shop.kitchen-store-type
        v-no-eq           = buf_shop.no-eq
        v-out-line-discnt = buf_shop.out-line-discnt
        v-out-rate        = buf_shop.out-rate
        v-pr-cash         = buf_shop.pr-cash
        v-price-calc      = buf_shop.price-calc
        v-rsrv-time       = buf_shop.rsrv-time
        v-shift-on        = buf_shop.shift-on
        v-store-boss      = buf_shop.store-boss
        v-store-man       = buf_shop.store-man
        v-sub-store-on    = buf_shop.sub-store-on
        v-sub-store-code  = buf_shop.sub-store-code
        v-sub-store-type  = buf_shop.sub-store-type
        v-unit-cli-perm   = buf_shop.unit-cli-perm
        v-with-serv       = buf_shop.with-serv
        v-work-hours      = buf_shop.work-hours
        v-purch-code      = buf_shop.purch-code
        v-envd            = (v-envd-str = "yes":u)
        v-pharm           = (v-pharm-str = "yes":u)
        v-decommissioned  = (v-decommiss-str = "yes":u)
      .
      if num-entries(v-clim-grp) = 3 then assign
        v-begin-summer = entry(2, v-clim-grp)
        v-begin-winter = entry(3, v-clim-grp)
        v-clim-grp     = entry(1, v-clim-grp)
      .
      assign
        v-clim-grp       = objImp:clim-grp     when objImp:clim-grp > ""
        v-begin-summer   = objImp:begin-summer when objImp:begin-summer > ""
        v-begin-winter   = objImp:begin-winter when objImp:begin-winter > ""
        v-decommissioned = (objImp:decommissioned > 0) when (objImp:decommissioned <> ?)
        v-edi            = (objImp:edi > 0) when (objImp:edi <> ?)
        v-KPP            = objImp:kpp when objImp:kpp > ""
      .
    end .
    else do :
      assign
        v-mode = 'ДОБАВЛЕНИЕ':U
        v-rid1 = ?
      .
      run adm/db01.p
      (input-output v-rid1
      ,input v-mode
      ,input v-db-num
      ,input objImp:name_
      ,input true
      ,input true
      ,input true
      ,10
      ) .
      sliceAddress
         ( input  objImp:address
         , input  ""
         , input  ""
         , output v-addr1
         , output v-addr2
         ) .
      assign
        v-in-pay         = 2
        v-out-pay        = 2
        v-ret-pay        = 2
        v-ret-sup-pay    = 3
        v-down-pay       = 2
        v-inv-pay        = 2
        v-chk-pay        = 1
        v-fbr-pay        = 2
      .
      assign
        v-tel = if objImp:tel >= "" then objImp:tel else ""
        v-clim-grp       = objImp:clim-grp
        v-begin-summer   = objImp:begin-summer
        v-begin-winter   = objImp:begin-winter
        v-decommissioned = if objImp:decommissioned > 0 then true else ?
        v-edi            = if objImp:edi > 0 then true else ?
        v-KPP = if objImp:kpp >= "" then objImp:kpp else ""
      .
      assign
        v-rid2 = ?
        v-ps             = ""
        v-all-prt        = false
        v-buy-goods      = true
        v-cd-bc-alt      = false
        v-cd-bc-base     = true
        v-cd-loc-alt     = false
        v-cd-loc-base    = true
        v-cd-parts-all   = false
        v-cd-parts-not-blank = false
        v-cd-parts-ser   = false
        v-cd-pb-alt      = false
        v-cd-pb-base     = true
        v-cd-sc-base     = true
        v-day-only       = yes
        v-discaloc       = yes
        v-doc-prt        = no
        v-fax            = ""
        v-goods-man      = ""
        v-in-ov          = no
        v-in-perm        = no
        v-inout-price    = yes
        v-is-catering        = yes
        v-is-kitchen         = no
        v-is-kitchen-store   = no
        v-kitchen-store-code = 0
        v-kitchen-store-type = ""
        v-no-eq           = yes
        v-out-line-discnt = no
        v-out-rate       = no
        v-pr-cash        = yes
        v-price-calc     = no
        v-rsrv-time      = 0
        v-shift-on       = yes
        v-store-boss     = ""
        v-store-man      = ""
        v-sub-store-on   = no
        v-sub-store-code = 0
        v-sub-store-type = ""
        v-unit-cli-perm  = yes
        v-with-serv      = yes
        v-work-hours     = ""
        v-purch-code     = ?
        v-envd           = no
        v-pharm          = no
      .
    end.
    run adm/shop01.p
    (input-output v-rid2
    ,input v-mode
    ,input v-obj-code
    ,input v-db-num
    ,input v-host-code
    ,input v-grp-code
    ,input objImp:name_
    ,input v-ps
    ,input objImp:accr
    ,input v-addr1
    ,input v-addr2
    ,input v-all-prt
    ,input v-buy-goods
    ,input v-cd-bc-alt
    ,input v-cd-bc-base
    ,input v-cd-loc-alt
    ,input v-cd-loc-base
    ,input v-cd-parts-all
    ,input v-cd-parts-not-blank
    ,input v-cd-parts-ser
    ,input v-cd-pb-alt
    ,input v-cd-pb-base
    ,input v-cd-sc-base
    ,input v-chk-pay
    ,input v-day-only
    ,input objImp:director
    ,input v-discaloc
    ,input v-doc-prt
    ,input v-down-pay
    ,input v-fax
    ,input v-goods-man
    ,input v-in-ov
    ,input v-in-pay
    ,input v-in-perm
    ,input v-inout-price
    ,input v-inv-pay
    ,input v-is-catering
    ,input v-is-kitchen
    ,input v-is-kitchen-store
    ,input v-kitchen-store-code
    ,input v-kitchen-store-type
    ,input v-no-eq
    ,input v-out-line-discnt
    ,input v-out-pay
    ,input v-out-rate
    ,input v-tel
    ,input v-pr-cash
    ,input v-price-calc
    ,input v-ret-pay
    ,input v-ret-sup-pay
    ,input v-fbr-pay
    ,input v-rsrv-time
    ,input v-shift-on
    ,input v-store-boss
    ,input v-store-man
    ,input v-sub-store-on
    ,input v-sub-store-code
    ,input v-sub-store-type
    ,input v-unit-cli-perm
    ,input v-with-serv
    ,input v-work-hours
    ,input v-purch-code
    ,INPUT v-envd
    ,INPUT v-pharm
    ,input v-KPP
    ) .
    for first buf_shop exclusive-lock
        where buf_shop.obj-code = v-obj-code:
      assign
        buf_shop.is-kitchen         = yes
        buf_shop.kitchen-store-type = 'маг':U
        buf_shop.kitchen-store-code = v-obj-code
      .
    end.
    If objimp:hist-code ne ?
    then do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run db-attr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib  ( input v-db-num
                                        , input 'hist-code':U
                                        , input objimp:hist-code
                                        ) no-error .
    end.
    If objimp:hist-name ne ?
    then do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run db-attr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib  ( input v-db-num
                                        , input 'hist-name':U
                                        , input objimp:hist-name
                                        ) no-error .
     end.
             if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input 'маг':U
      ,input v-obj-code
      ,input 'cli-clim-grp':U
      ,input substitute("&1,&2,&3", v-clim-grp, v-begin-summer, v-begin-winter)
      ) .
      if v-decommissioned <> ? then do :
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input 'маг':U
      ,input v-obj-code
      ,input 'cli-decommissioned':U
      ,input string(v-decommissioned)
      ) .
      end .
    define buffer buf_sysconf for ub.sysconf .
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    v-tth = buffer thbjattr_thbj-attr:table-handle .
    empty temp-table thbjattr_thbj-attr .
    run adm/shattri.p (
            input "init":U
          , input 'маг':U
          , input v-obj-code
          , input 'marking':U
          , input "":U
          , output v-value-character
          , output v-value-date
          , output v-value-decimal
          , output v-value-integer
          , output v-value-logical
          , output v-param-type
          , INPUT-OUTPUT table-handle v-tth
          ) no-error .
    if error-status:error then do:
      undo, throw new Progress.Lang.AppError(
        substitute(  "Ошибка чтения начальных значений настроек работы со справочниками товаров в контексте объекта [&1 &2]",
                     error-status:get-message(1), return-value  )
      ) .
    end .
    FOR EACH thbjattr_thbj-attr:
      case thbjattr_thbj-attr.prop-code :
        when 'marking-EDO':U then do: // объект работает с EDI
          thbjattr_thbj-attr.property-value-logical = v-edi .
          define variable mImp2CdH as handle no-undo.
          run str/imp2cdgeth.p(output mImp2CdH).
          run fill-setting in mImp2CdH ('thbj-attr':U,
                                     'маг':U,
                                     v-obj-code,
                                     thbjattr_thbj-attr.upper-prop-code,
                                     thbjattr_thbj-attr.prop-code).
        end.
      end case .
    END .
    thbjattr_set-section ('маг':U, v-obj-code, 'marking':U, input table thbjattr_thbj-attr) .
    if v-mode = 'ДОБАВЛЕНИЕ':U then do :
      v-tth = buffer thbjattr_thbj-attr:table-handle .
      empty temp-table thbjattr_thbj-attr .
      run adm/shattri.p (
              input "init":U
            , input 'маг':U
            , input v-obj-code
            , input 'gds-ref_obj':U
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
            ) no-error .
      if error-status:error then do:
        undo, throw new Progress.Lang.AppError(
          substitute(  "Ошибка чтения начальных значений настроек работы со справочниками товаров в контексте объекта [&1 &2]",
                       error-status:get-message(1), return-value  )
        ) .
      end .
      FOR EACH thbjattr_thbj-attr:
        case thbjattr_thbj-attr.prop-code :
          when 'chg-bcod':U then // Запрещена работа с Доп-БК
            thbjattr_thbj-attr.property-value-logical = true .
        end case .
      END .
      thbjattr_set-section ('маг':U, v-obj-code, 'gds-ref_obj':U, input table thbjattr_thbj-attr) .
      empty temp-table thbjattr_thbj-attr .
    end . // end_of опции при создании объекта
    define variable proc-typl-ad as class typl-ad no-undo .
    define variable v-plt-id     as integer no-undo .
    define variable v-plt-recid  as recid no-undo .
    proc-typl-ad = new typl-ad () .
    if v-mode = 'ДОБАВЛЕНИЕ':U then do :
      v-plt-id = next-value (s-plt, ub)  .
      proc-typl-ad:type-price-list-ADD
      (input v-plt-id
      ,input v-db-num
      ,substitute("ГТПЛ по объекту &1&2", 'маг':U, v-obj-code)
      ,0
      ,'Отключено':U
      ,0.0
      ,0.0
      ,'Отсутствует':U
      ,1
      ,false
      ,false
      ,true
      ,0
      ,v-db-num
      ,0
      ,1
      ,0
      ,?
      ,?
      ,1
      ,1
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,v-db-num
      ,0
      ,false
      ,v-db-num
      ,0
      ,0
      ,v-db-num
      ,0
      ,?
      ,v-db-num
      ,0
      ,v-db-num
      ,0
      ,0
      ,0
      ,v-db-num
      ,0
      ,2
      ,v-db-num
      ,0
      ,gbl-var:g#userid
      ,0
    ,output v-plt-recid
     ,input table TT_cassa
     ,input table TT_grp
     ,input table TT_pay-type
     ,input table TT_cash-pay
      ) .
    end .
    v-retfl = true.
    catch exAppErrors as class Progress.Lang.AppError :
      define variable v-is-delim as logical no-undo .
      v-is-delim = (num-entries(exAppErrors:ReturnValue, chr(4)) > 1) .
      Msg = if v-is-delim then entry(2, exAppErrors:ReturnValue, chr(4)) else exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в АЗС АЗК" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      if Msg > "" then . else Msg = "ProError в АЗС АЗК" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в АЗС АЗК" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      if valid-object(proc-typl-ad) then delete object proc-typl-ad .
      return v-retfl .
    end finally .
  end method.
  method private void sliceAddress (input p-address   as character,
                                    input p-curraddr1 as character,
                                    input p-curraddr2 as character,
                                   output p-addr1     as character,
                                   output p-addr2     as character) :
    if p-address > "" then assign
      p-addr1 = substring(p-address,  1, 63)
      p-addr2 = substring(p-address, 64)
    .
    else if p-address = "" then assign
      p-addr1 = ""
      p-addr2 = ""
    .
    else assign
      p-addr1 = p-curraddr1
      p-addr2 = p-curraddr2
    .
  end method .
  method private void thbjattr_get-section (input p-obj-type   as character,
                                            input p-obj-code   as integer,
                                            input p-upper-code as character,
                                            output table-handle p-tth) :
  end method .
  method private void thbjattr_set-section (input p-obj-type   as character,
                                            input p-obj-code   as integer,
                                            input p-upper-code as character,
                                            input table-handle p-tth) :
    if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run thbjattr_set-section in ibs.th.gbl.gbl-hndllib:g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) .
  end method .
end class.
