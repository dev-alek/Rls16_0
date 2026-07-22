block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : rnp-imp-gds.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Tue Aug 30 12:37:42 MSK 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define input parameter parparentproc as widget-handle no-undo .
&if DEFINED(notchang) eq 0
&then
  &GLOBAL-DEFINE notchang no
&endif
define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko$":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rnp-imp-gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rnp-imp-gds.p $":U .
define variable vss-description as character no-undo init "Импорт товаров РН-Питер".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }
{ gbl/ggoattr.i }
{ref/gds-attr.i}
{ str/tt-tax.i "new shared" tt-tax full }
define new shared buffer goods for goods.

define buffer first_gds-grp for ub.gds-grp.

define new shared stream gds-file.

define stream str-log .

define variable custvalue      as character no-undo.
define variable custtype       as character no-undo.
define variable tnvedimp as logical no-undo init no.

define variable f-name as char no-undo.
define variable impc as integer no-undo.
define variable impc-saved as integer no-undo.
define variable impc-Warn as integer no-undo.
define variable not-saved as character no-undo.
define new shared variable text-string as char no-undo.
define variable old-text-string as char no-undo init ?.
define variable p-artic     AS integer NO-UNDO init 1.
define variable p-name      AS integer NO-UNDO init 2.
define variable p-engl-name AS integer NO-UNDO.
define variable p-SLT-code  AS integer NO-UNDO.
define variable p-VAT-code  AS integer NO-UNDO.
define variable p-unit-base AS integer NO-UNDO.
define variable p-struct AS integer NO-UNDO.
define variable p-prod AS integer NO-UNDO.
define variable p-tnved as integer no-undo .
define variable p-attrib as integer no-undo .
define variable p-destin as integer no-undo .
define variable p-sert as integer no-undo .
define variable p-user-rule as integer no-undo .
define variable p-alpha1 as integer no-undo .
define variable p-grp-code as integer no-undo .
define variable p-service as integer no-undo .
define variable p-gds-code as integer no-undo .
define variable p-ppr as integer no-undo .
define variable i-artic as char no-undo.
define variable i-prod-type as character no-undo .
define variable i-prod-code as integer no-undo .
define variable i-gds-name as char no-undo.
define variable i-engl-name as char no-undo.
define variable i-SLT-code as integer no-undo.
define variable i-unit-base as char no-undo.
define variable i-VAT-code as integer no-undo.
define variable i-struct as character no-undo.
define variable i-tnved like ub.goods.tnved no-undo .
define variable i-attrib like ub.goods.attrib no-undo .
define variable i-destin like ub.goods.destin no-undo .
define variable i-sert like ub.goods.sert no-undo .
define variable i-user-rule like ub.goods.user-rule no-undo .
define variable i-alpha1 like ub.goods.alpha1 no-undo .
define variable i-grp-code like ub.goods.grp-code no-undo .
define variable i-service as logical no-undo .
define variable i-gds-code like ub.goods.gds-code no-undo .
define variable choice as integer no-undo.
define variable v-num-fields as integer no-undo .
define variable p-mark as integer no-undo .
define variable i-mark as integer  no-undo .
define variable p-nomcode as integer no-undo .
define variable i-nomcode as character  no-undo .
define variable i-ppr as integer no-undo .

define variable mnewrec as logical no-undo.
define variable v-host-code     as integer           no-undo.
define variable v-recid         as recid             no-undo.

define variable NDS like  tax-rate-value.rate-value  no-undo .
define variable NP like  tax-rate-value.rate-value  no-undo .

define variable j-gds-code like goods.gds-code NO-UNDO.

DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */

DEFINE VARIABLE vLine   AS INTEGER   NO-UNDO.
DEFINE VARIABLE vChLine AS CHARACTER NO-UNDO.
DEFINE VARIABLE vCh     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-prod  as character no-undo .
DEFINE VARIABLE vNoLine AS INTEGER   NO-UNDO.

{ gbl/objsrv.i }
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.
define variable MarkTypeStr as character no-undo.
{ gbl/conf-rd.i
 "'is-custm'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 custvalue
 custtype
 no-error
 }
 
function f-range returns character(input p-num as integer) :
    case p-num :
        when 1 then return "A":U .
        when 2 then return "B":U .
        when 3 then return "C":U .
        when 4 then return "D":U .
        when 5 then return "E":U .
        when 6 then return "F":U .
        when 7 then return "G":U .
        when 8 then return "H":U .
        when 9 then return "I":U .
        when 10 then return "J":U .
        when 11 then return "K":U .
        when 12 then return "L":U .
        when 13 then return "M":U .
        when 14 then return "N":U .
        when 15 then return "O":U .
        when 16 then return "P":U .
        /* на всякий случай ещё несколько */
        when 17 then return "Q":U .
        when 18 then return "R":U .
        when 19 then return "S":U .
        when 20 then return "T":U .
    end case .
end.
 

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i get }
for each thbjattr_thbj-attr  where
        thbjattr_thbj-attr.obj-type = '':U
    and thbjattr_thbj-attr.obj-code = 0
    and thbjattr_thbj-attr.upper-prop-code = {&attr-gds-ref}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when {&attr-gds-ref_tnvedimp} then do:
      tnvedimp = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.

run ref/strtimp.w (
                       input parparentproc
                      ,{&notchang}
                      ,input integer({&vat-tax-code})
                      ,input integer({&slt-tax-code})
                      ,input custvalue
                      ,input tnvedimp
                      ,output f-name
                      ,output choice
                      ,output p-artic
                      ,output p-prod
                      ,OUTPUT p-name
                      ,OUTPUT p-engl-name
                      ,OUTPUT p-unit-base
                      ,OUTPUT p-VAT-code
                      ,OUTPUT p-SLT-code
                      ,OUTPUT p-struct
                      ,OUTPUT p-tnved
                      ,OUTPUT p-attrib
                      ,OUTPUT p-destin
                      ,OUTPUT p-sert
                      ,OUTPUT p-user-rule
                      ,OUTPUT p-alpha1
                      ,OUTPUT p-grp-code
                      ,OUTPUT p-service
                      ,OUTPUT p-gds-code
                      ,OUTPUT p-mark
                      ,output p-nomcode
                      ,output p-ppr
                      ) .
if  error-status:error or f-name = "" then return error.
CASE choice:
    WHEN 1 then do:
        input stream gds-file from value (f-name) convert source "1251".
    END.
    WHEN 2 then do:
        input stream gds-file from value (f-name) convert source "KOI8-R".
    END.
END CASE.
assign
    impc       = 0
    impc-saved = 0
    impc-Warn  = 0
.

run waitfram-show in this-procedure ( "ЖДИТЕ...") .

output stream str-log to value("gds-imp.log") .

if substring(f-name, length(f-name) - 2) = "xls"
or substring(f-name, length(f-name) - 3) = "xlsx"
then do :
    CREATE "Excel.Application":U mExcelApplication.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.    
    ASSIGN
        mExcelApplication:DisplayAlerts = NO
        mWorkbook                       = mExcelApplication:WorkBooks:Add(f-name)
        mWorkSheet                      = mWorkbook:Sheets:Item(1)
    .
    
    loopbl:
    DO vLine = 1 TO 1000000:
        ASSIGN
            vChLine = STRING(vLine)
            i-artic = ?
            i-alpha1 = ?
            i-attrib = ?
            i-destin = ?
            i-engl-name = ?
            i-gds-name = ?
            i-grp-code = 0
            i-prod-code = ?
            i-prod-type = ?
            i-sert = ?
            i-service = ?
            i-gds-code = ?
            i-SLT-code = ?
            i-struct = ?
            i-tnved = ?
            i-unit-base = ?
            i-user-rule = ?
            i-VAT-code = 0
            i-mark = ?
            i-nomcode = ?
            i-ppr = ?
        .  
        
        i-artic = mWorkSheet:Range(f-range(p-artic) + vChLine):VALUE NO-ERROR.  
        if i-artic = ? then i-artic = mWorkSheet:Range(f-range(p-artic) + vChLine):FORMULA NO-ERROR. 
        i-artic = entry(1, i-artic, ".") no-error .
        
        i-alpha1 = mWorkSheet:Range(f-range(p-alpha1) + vChLine):VALUE NO-ERROR. 
        if i-alpha1 = ? then i-alpha1 = mWorkSheet:Range(f-range(p-alpha1) + vChLine):FORMULA NO-ERROR.
        
        i-attrib = mWorkSheet:Range(f-range(p-attrib) + vChLine):VALUE NO-ERROR. 
        if i-attrib = ? then i-attrib = mWorkSheet:Range(f-range(p-attrib) + vChLine):FORMULA NO-ERROR.
        
        i-destin = mWorkSheet:Range(f-range(p-destin) + vChLine):VALUE NO-ERROR. 
        if i-destin = ? then i-destin = mWorkSheet:Range(f-range(p-destin) + vChLine):FORMULA NO-ERROR.
        
        i-engl-name = mWorkSheet:Range(f-range(p-engl-name) + vChLine):VALUE NO-ERROR. 
        if i-engl-name = ? then i-engl-name = mWorkSheet:Range(f-range(p-engl-name) + vChLine):FORMULA NO-ERROR.
        
        i-gds-name = mWorkSheet:Range(f-range(p-name) + vChLine):VALUE NO-ERROR. 
        if i-gds-name = ? then i-gds-name = mWorkSheet:Range(f-range(p-name) + vChLine):FORMULA NO-ERROR.
        
        i-grp-code = integer(mWorkSheet:Range(f-range(p-grp-code) + vChLine):VALUE) NO-ERROR. 
        if i-grp-code = ? then i-grp-code = integer(mWorkSheet:Range(f-range(p-grp-code) + vChLine):FORMULA) NO-ERROR.
        
        v-prod = mWorkSheet:Range(f-range(p-prod) + vChLine):VALUE NO-ERROR. 
        if v-prod = ? then v-prod = mWorkSheet:Range(f-range(p-prod) + vChLine):FORMULA NO-ERROR.
        i-prod-code = integer(substring(v-prod, 4)) no-error .
        i-prod-type = substring(v-prod, 1, 3) .
        
        i-sert = mWorkSheet:Range(f-range(p-sert) + vChLine):VALUE NO-ERROR. 
        if i-sert = ? then i-sert = mWorkSheet:Range(f-range(p-sert) + vChLine):FORMULA NO-ERROR.
        
        i-service = logical(mWorkSheet:Range(f-range(p-service) + vChLine):VALUE) NO-ERROR. 
        if i-service = ? then i-service = logical(mWorkSheet:Range(f-range(p-service) + vChLine):FORMULA) NO-ERROR.
        
        i-gds-code = integer(mWorkSheet:Range(f-range(p-gds-code) + vChLine):VALUE) NO-ERROR. 
        if i-gds-code = ? then i-gds-code = integer(mWorkSheet:Range(f-range(p-gds-code) + vChLine):FORMULA) NO-ERROR.
        
        i-SLT-code = integer(mWorkSheet:Range(f-range(p-SLT-code) + vChLine):VALUE) NO-ERROR. 
        if i-SLT-code = ? then i-SLT-code = integer(mWorkSheet:Range(f-range(p-SLT-code) + vChLine):FORMULA) NO-ERROR.
        
        i-struct = mWorkSheet:Range(f-range(p-struct) + vChLine):VALUE NO-ERROR. 
        if i-struct = ? then i-struct = mWorkSheet:Range(f-range(p-struct) + vChLine):FORMULA NO-ERROR.
        
        i-tnved = mWorkSheet:Range(f-range(p-tnved) + vChLine):VALUE NO-ERROR. 
        if i-tnved = ? then i-tnved = mWorkSheet:Range(f-range(p-tnved) + vChLine):FORMULA NO-ERROR.
        
        i-unit-base = mWorkSheet:Range(f-range(p-unit-base) + vChLine):VALUE NO-ERROR. 
        if i-unit-base = ? then i-unit-base = mWorkSheet:Range(f-range(p-unit-base) + vChLine):FORMULA NO-ERROR.
        
        i-user-rule = mWorkSheet:Range(f-range(p-user-rule) + vChLine):VALUE NO-ERROR. 
        if i-user-rule = ? then i-user-rule = mWorkSheet:Range(f-range(p-user-rule) + vChLine):FORMULA NO-ERROR.
        
        i-VAT-code = integer(mWorkSheet:Range(f-range(p-VAT-code) + vChLine):VALUE) NO-ERROR. 
        if i-VAT-code = ? then i-VAT-code = integer(mWorkSheet:Range(f-range(p-VAT-code) + vChLine):FORMULA) NO-ERROR.
        
        i-mark = integer (mWorkSheet:Range(f-range(p-mark) + vChLine):value) NO-ERROR. 
        if i-mark = ? then i-mark = (mWorkSheet:Range(f-range(p-mark) + vChLine):FORMULA) NO-ERROR.
        
        i-nomcode = mWorkSheet:Range(f-range(p-nomcode) + vChLine):value NO-ERROR. 
        if i-nomcode = ? then i-nomcode = (mWorkSheet:Range(f-range(p-nomcode) + vChLine):FORMULA) NO-ERROR.

        i-ppr = integer(mWorkSheet:Range(f-range(p-ppr) + vChLine):VALUE) NO-ERROR. 
        if i-ppr = ? then i-ppr = integer(mWorkSheet:Range(f-range(p-ppr) + vChLine):FORMULA) NO-ERROR.

        if length(i-artic) > 0 or length(i-alpha1) > 0 or length(i-attrib) > 0
        or length(i-destin) > 0 or length(i-engl-name) > 0 or length(i-engl-name) > 0
        or length(i-gds-name) > 0 or i-grp-code > 0 or length(i-prod-type) > 0
        or i-prod-code > 0 or length(i-sert) > 0 or i-service <> ? or i-gds-code > 0 or length(i-struct) > 0
        or i-SLT-code > 0 or length(i-tnved) > 0 or length(i-unit-base) > 0
        or length(i-user-rule) > 0 or i-VAT-code > 0
        then vNoLine = 0 .
        else do :
            vNoLine = vNoLine + 1.
            IF vNoLine > mMaxNoLine THEN LEAVE loopbl. 
            ELSE NEXT loopbl. 
        end.
        
        
        
        
        if i-gds-code eq ?
           and (i-artic eq ?    
               or  i-prod-type eq ?
               or  i-prod-code eq ?)
                            
        then do:
            impc = impc + 1 .
            put stream str-log unformatted "В загрузке обязательно должен быть код товара или артикул и производитель. Строка" vLine skip .
            next.
        end.
        else do :
            if     i-gds-code ne ?
               and i-artic    ne ?    
               and i-prod-type ne ?
               and i-prod-code ne ?
             and
             can-find(goods where goods.artic eq i-artic
                            and goods.prod-type eq i-prod-type
                            and goods.prod-code eq i-prod-code
                            and goods.gds-code  ne i-gds-code)
            then do:
                impc = impc + 1 .
                put stream str-log unformatted "Уже есть товар с артикулом " i-artic "  " i-prod-type " " string(i-prod-code) " Строка  " vLine skip .
                next.
            end.
        end.
        find first goods where goods.gds-code = i-gds-code no-lock no-error.
        if not available goods
        then
           find first goods where goods.artic     eq i-artic
                              and goods.prod-type eq i-prod-type
                              and goods.prod-code eq i-prod-code no-lock no-error.
        
        if available goods
           and i-unit-base ne ?
           and goods.unit-base ne i-unit-base
        then do:
            impc-Warn = impc-Warn + 1.
            i-unit-base =  goods.unit-base.
            put stream str-log unformatted "Внимание Артикул " goods.artic " .  Единицы измерения изменять нельзя. Единицы измерения проигнорировы.  Строка  " vLine  skip .
        end.
        
        assign
        impc = impc + 1 .
        
        do transaction:
    
    /**************************************************************************/
    
            { gbl/hostcode.i
            v-cntxt-obj-type
            v-cntxt-obj-code
            v-host-code
            }
            
            find last tax-rate-value where    /*Значение ставки налога    НДС    */
                        tax-rate-value.tax-code = 1 and
                        tax-rate-value.rate-code = i-vat-code no-lock no-error.
            IF available tax-rate-value then do:
                NDS = tax-rate-value.rate-code.
            END.
            
            find first gds-grp no-lock where gds-grp.node-code = i-grp-code no-error .
            find first first_gds-grp .
            
            if i-unit-base ne ?
            then do:
            run ref/dtaxgdss.p (
                  input yes
                , input /*par-unit-base*/  i-unit-base
                , input /*par-node-code*/  (if available gds-grp
                              then gds-grp.node-code
                              else first_gds-grp.node-code)
                , input if available goods then recid(goods) else ?
                , input if available goods then recid(goods) else ?
                , input /*par-host-code*/  v-host-code
                , input /*par-obj-type*/   v-cntxt-obj-type
                , input /*par-obj-code*/   v-cntxt-obj-code
            ) no-error.
            if error-status :error
            then do:
            
               put stream str-log unformatted "Артикул " i-artic " .   " replace (return-value,Chr(10)," ")  " Строка  " vLine skip .
               next loopbl.

            end.
            end.
    
            IF p-VAT-code > 0 THEN DO:
                find first tt-tax
                     where tt-tax.tax-code = integer( {&vat-tax-code} )
                no-error.
                if available tt-tax   then do:
                    assign
                        
                        tt-tax.rate-code = NDS .
                end.
            END.
    
            
            v-recid = if available goods then recid(goods) else ?. /*Обнулим так как при ошибке он не изменяется*/
            mnewrec = not avail goods.
            run ref/goods01.p (
                  input parparentproc
                , input if available goods then {&autoupdate} else {&add-def}  /* {&add-def} или {&update} */
                , input no   /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
                , input 0    /*нужно ли вводить ДОП БК вместе с товаром*/
                , input no   /*мз карточки товара - yes*/
                , input yes  /*ругаемся вслух или ?*/
                , input no   /* yes - пропускается проверка на повторный артикул */
                , input no   /*идет импорт из файла - из карточки товара*/
                , input yes  /*надо сохранить только одну запись - потом выход в справ*/
                , input v-host-code
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input (if i-service then no else yes)           /*товар - yes услуга no*/
                , input ?             /*recid записи с которой копируем*/
                , input i-gds-code
                , input i-artic       /* артикул*/
                , input i-prod-type /* тип производителя */
                , input i-prod-code /*код производителя */
                , input 1 /* пустая шкала */
                , input i-grp-code
                , input i-gds-name        /* наименование товара */
                , input ""
                , input i-engl-name        /* Название англ. */
                , input i-gds-name        /* Название на ценнике */
                , input replace( replace( i-gds-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-alpha1        /* Код страны */
                , input i-unit-base   /* Ед. изм. */
                , input i-unit-base   /* Ед. изм. */
                , input 0.0           /* Макс. кол-во дробн./шт */
                , input 0.0           /*  Мин. кол-во дробн./шту */
                , input 1             /* Коэффициент  */
                , input 1             /* Кол. в упак.  */
                , input 0             /* Объем штуки */
                , input 0             /* Вес штуки */
                , input 0             /* Объем упаковки  */
                , input 0             /* Вес упаковки  */
                , input {&pr-calc-grp}            /*   Способ расчета  */
                , input 0             /* Процент наценки  */
                , input no            /* Отриц. остаток   */
                , input (if i-service then 1 else 0)
                , input (if i-service then 1 else 0)
                , input ""            /* ОКДП  */
                , input ""          /* Назначение  */
                , input ""          /*  Характеристики */
                , input ""          /*  Правила эксплутации */
                , input ""          /*  Сертификация */
                , input ""      /* Состав (комплектность)  */
                , input 0             /* Срок хранения  */
                , input 0             /* Код условия хранения  */
                , input ""            /* Сорт  */
                , input 0.0           /* процент алкоголя */
                , input 0             /*  Норма естественной убы */
                , input 0             /*  Норма отходов */
                , input ""            /*  Код ТНВЭД */
                , input ""            /*  Национальность */
                , input ""            /* Таможенная единица изм  */
                , input 0             /*  Коэффициент */
                , input ?             /*  Код глоб.группы меню */
                , input ""            /*  Примечание */
                , input no            /* настройка  */
                , input no            /*  в системе разрешены ювелирные изделия */
                , input no            /* в системе разрешена стеклотара  */
                , input no            /*  в системе разрешено топливо */
                , input "no"          /* в системе разрешена таможня  */
                , input yes           /*настройка*/
                , input no            /*настройка*/
                , input no            /* автоматический артикул */
                , input if i-gds-code > 0 then 2 else 0             /*главный код товара берется из артикула*/
                , input-output v-recid
                , output j-gds-code   /*gds-code*/
            ) no-error .
            find first goods where recid( goods)  = v-recid    no-lock no-error.
            if error-status :error
               or not available goods
            then do:
/*                message                                           */
/*                         vss-workfile vss-revision vss-description*/
/*                    skip "Ошибка создания карточки товара."       */
/*                    skip return-value                             */
/*                    skip i-artic                                  */
/*                    skip trim(error-status :get-message(1))       */
/*                         trim(error-status :get-message(2))       */
/*                         trim(error-status :get-message(3))       */
/*                view-as alert-box error.                          */
                put stream str-log unformatted "Ошибка создания/изменении карточки товара. Артикул " i-artic " .   " return-value " Строка  " vLine  skip .
                next loopbl.
    /*            IF r-s-stop = 2 THEN RETURN.*/
            end.
            else do :
                
                 def var v-value as char no-undo.
                def var v-type as char no-undo.
                if p-mark eq 0
                then do:
                   if mnewrec
                   then do:
                       define variable mflag as logical no-undo.
                       run gds-attr-exist in this-procedure (goods.gds-code,{&attr-mark-type},output mflag).
                       if not mflag
                       then do:
                          run ggoattr-value(
                            input i-grp-code,
                            input 0,
                            input "",
                            input 0,
                            input {&ggoattr-mark-type},
                            output v-value,
                            output v-type
                          ) no-error.
                          
                /*Есть ли атрибут "Группа товаров на кассе" в группе товаров*/
                          if v-value > "" then do:
                              run gds-attr-write IN THIS-PROCEDURE(
                                 input goods.gds-code
                                ,INPUT {&attr-mark-type}
                                ,INPUT v-value ) NO-ERROR.
                              put stream str-log unformatted "Внимание Артикул " goods.artic " .  Признак маркировки установлен с группы Строка " vLine  skip . 
                              impc-Warn = impc-Warn + 1.
                          end.
                      end.  
                   end. 
                end.
                else if i-mark eq ? or i-mark eq 0
                then do:
                   run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                      ,INPUT {&attr-mark-type}
                      ,output mflag).
                end.
                else do:
                   MarkTypeStr = MarkType:GetNameProp(i-mark).
                   if MarkTypeStr eq MarkType:Unknow:NameProp
                   then do:
                      impc-Warn = impc-Warn + 1.
                      put stream str-log unformatted "Внимание Артикул " goods.artic " .  Не известный тип маркировки  " i-mark " Строка " vLine  skip .
                   end.
                   else
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT {&attr-mark-type}
                   ,INPUT MarkTypeStr
                          ) NO-ERROR.
                end.
  
                if p-nomcode <> 0
                then do:
                if i-nomcode = ""
                then do:
                   run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                      ,INPUT {&attr-gds-CommodityCode}
                      ,output mflag).
                end.
                else do:
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT {&attr-gds-CommodityCode}
                   ,INPUT i-nomcode
                          ) NO-ERROR.
                end.   
                end.        
           if p-ppr <> ?
              then 
           do:
              if i-ppr <> 0
                 then 
              do:
                 entry(i-ppr,{&prop-list-attr-item-matter-mark}) no-error .
                 if error-status:error then 
                 do:
                    impc-Warn = impc-Warn + 1.
                    put stream str-log unformatted 
                       "Внимание Артикул " goods.artic " .  Не известный признак предмета расчета  " i-ppr " Строка " vLine  skip .
                 end.  
                 else 
                 do: 
                    run gds-attr-write IN THIS-PROCEDURE(
                       input goods.gds-code
                       ,INPUT {&attr-item-matter-mark}
                       ,INPUT i-ppr
                       ) NO-ERROR.
                 end.
              end.   
           end.                 
                if  goods.artic ne i-artic
                then do:
                    impc-Warn = impc-Warn + 1.
                   put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой Артикул. Строка  " vLine  skip .
                end.
                if         (i-prod-type ne ?
                       and goods.prod-type ne i-prod-type) 
                   or  (    i-prod-code ne ?  
                        and goods.prod-code ne i-prod-code)
                then do:
                    impc-Warn = impc-Warn + 1.
                   put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой прозводитель. Строка  " vLine  skip .
                end.
                   
                   
                if i-service
                then do :
                    for each clients no-lock where clients.obj-type = 'маг' :
                        { gbl/gdscr.i clients.obj-type clients.obj-code  i-artic
                                  i-prod-type i-prod-code  1  ub.gds-obj ub.prt-obj }
                        if avail gds-obj then do:
                          find current gds-obj exclusive-lock .
                          assign
                          gds-obj.price-base = 1
                          gds-obj.price-rubl = 1
                          .
                          run str/callnews.p
                            ( input "gds-obj"
                              ,input (buffer gds-obj:handle)
                            ).
                        end.
                    end.
                end.
                impc-saved = impc-saved + 1.
                if impc-saved modulo 10 = 0 then
                run waitfram-show in this-procedure (input substitute("Обработано товаров &1", impc-saved)) .
            end.
            
        end.   /*   do transaction: */
    end.    
end.    
else do :
repeat :
    old-text-string = text-string .
    ASSIGN
        vChLine = STRING(vLine)
        i-artic = ?
        i-alpha1 = ?
        i-attrib = ?
        i-destin = ?
        i-engl-name = ?
        i-gds-name = ?
        i-grp-code = 0
        i-prod-code = ?
        i-prod-type = ?
        i-sert = ?
        i-service = ?
        i-gds-code = ?
        i-SLT-code = ?
        i-struct = ?
        i-tnved = ?
        i-unit-base = ?
        i-user-rule = ?
        i-VAT-code = 0
        i-mark = ?
        i-nomcode = ?
        i-ppr = ?
    .  
    run ref/nxtgdsi.p (   input integer({&vat-tax-code})
                         ,input integer({&slt-tax-code})
                         ,input custvalue
                         ,input p-artic
                         ,input p-prod
                         ,input p-name
                         ,input p-engl-name
                         ,input p-unit-base
                         ,input p-VAT-code
                         ,input p-SLT-code
                         ,input p-struct
                         ,input p-tnved
                         ,input p-attrib
                         ,input p-destin
                         ,input p-sert
                         ,input p-user-rule
                         ,input p-alpha1
                         ,input p-grp-code
                         ,input p-service
                         ,input p-gds-code
                         ,input p-mark
                         ,input p-nomcode
                         ,input p-ppr
                         ,input (impc + 1)
                         ,input-output i-artic
                         ,input-output i-prod-type
                         ,input-output i-prod-code
                         ,input-output i-gds-name
                         ,input-output i-engl-name
                         ,input-output i-unit-base
                         ,input-output i-VAT-code
                         ,input-output i-SLT-code
                         ,input-output i-struct
                         ,input-output i-tnved
                         ,input-output i-attrib
                         ,input-output i-destin
                         ,input-output i-sert
                         ,input-output i-user-rule
                         ,input-output i-alpha1
                         ,input-output i-grp-code
                         ,input-output i-service
                         ,input-output i-gds-code
                         ,input-output i-mark
                         ,input-output i-nomcode
                         ,input-output i-ppr
                          ) no-error .
    if old-text-string = text-string then leave .                      
    if error-status :error
    then do :
        impc = impc + 1 .
        next.
    end. 
    if            i-gds-code eq ?
             and (   i-artic eq ?    
                  or i-prod-type eq ?
                  or  i-prod-code eq ?)
                            
    then do:
       impc = impc + 1 .
       put stream str-log unformatted "В загрузке обязательно должен быть код товара или артикул и производитель. Строка" vLine skip .
       next.
    end.
    v-num-fields = maximum(p-alpha1, p-artic, p-attrib, p-destin, p-engl-name, p-gds-code, p-grp-code,
                           p-name, p-prod, p-sert, p-service, p-SLT-code, p-struct, p-tnved,
                           p-unit-base, p-user-rule, p-VAT-code,p-mark,p-nomcode,p-ppr) .
    if v-num-fields <> num-entries(text-string, ";")    
    then do :
        impc = impc + 1 .
        put stream str-log unformatted "Неверное кол-во полей в строке " text-string " Строка  " impc  skip .
        next.
    end.                                            
    
    if can-find(goods where goods.artic     eq i-artic
                            and goods.prod-type eq i-prod-type
                            and goods.prod-code eq i-prod-code
                            and goods.gds-code  ne i-gds-code)
    then do:
        impc = impc + 1 .
        put stream str-log unformatted "Уже есть товар с артикулом " i-artic "  " i-prod-type " " string(i-prod-code) " Строка  " vLine skip .
        next.
    end.
    
    find first goods where goods.gds-code = i-gds-code no-lock no-error.
    if not available goods
    then
       find first goods where goods.artic     eq i-artic
                          and goods.prod-type eq i-prod-type
                          and goods.prod-code eq i-prod-code no-lock no-error.
    
    assign
    impc = impc + 1 .
    
    do transaction:

/**************************************************************************/
        if available goods
           and goods.unit-base ne i-unit-base
        then do:
            impc-Warn = impc-Warn + 1.
            i-unit-base =  goods.unit-base.
            put stream str-log unformatted "Внимание Артикул " goods.artic " .  Единицы измерения изменять нельзя. Единицы измерения проигнорировы.  Строка  " vLine  skip .
        end.
         
        { gbl/hostcode.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-host-code
        }
        
        find last tax-rate-value where    /*Значение ставки налога    НДС    */
                    tax-rate-value.tax-code = 1 and
                    tax-rate-value.rate-code = i-vat-code no-lock no-error.
        IF available tax-rate-value then do:
            NDS = tax-rate-value.rate-code.
        END.
        
        find first gds-grp no-lock where gds-grp.node-code = i-grp-code no-error .
        find first first_gds-grp .
        
        run ref/dtaxgdss.p (
              input yes
            , input /*par-unit-base*/  i-unit-base
            , input /*par-node-code*/  (if available gds-grp
                          then gds-grp.node-code
                          else first_gds-grp.node-code)
            , input if available goods then recid(goods) else ?
            , input if available goods then recid(goods) else ?
            , input /*par-host-code*/  v-host-code
            , input /*par-obj-type*/   v-cntxt-obj-type
            , input /*par-obj-code*/   v-cntxt-obj-code
        ) no-error.    
        if error-status :error
        then do:
            
            put stream str-log unformatted "Артикул " i-artic " .   " replace (return-value,Chr(10)," ") " Строка  " impc  skip .
            next .
/*            IF r-s-stop = 2 THEN RETURN.*/
        end.

        IF p-VAT-code > 0 THEN DO:
            find first tt-tax
                 where tt-tax.tax-code = integer( {&vat-tax-code} )
            no-error.
            if available tt-tax   then do:
                assign
                    tt-tax.rate-code = NDS .
            end.
        END.

        v-recid = if available goods then recid(goods) else ?. /*Обнулим так как при ошибке он не изменяется*/
        mnewrec = not available goods.
        run ref/goods01.p (
              input parparentproc
            , input if available goods then {&autoupdate} else {&add-def} /* {&add-def} или {&update} */
            , input no   /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
            , input 0    /*нужно ли вводить ДОП БК вместе с товаром*/
            , input no   /*мз карточки товара - yes*/
            , input yes  /*ругаемся вслух или ?*/
            , input no   /* yes - пропускается проверка на повторный артикул */
            , input no   /*идет импорт из файла - из карточки товара*/
            , input yes  /*надо сохранить только одну запись - потом выход в справ*/
            , input v-host-code
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input (if i-service then no else yes)           /*товар - yes услуга no*/
            , input ?             /*recid записи с которой копируем*/
            , input i-gds-code
            , input i-artic       /* артикул*/
            , input i-prod-type /* тип производителя */
            , input i-prod-code /*код производителя */
            , input 1 /* пустая шкала */
            , input i-grp-code
            , input i-gds-name        /* наименование товара */
            , input ""
            , input i-engl-name        /* Название англ. */
            , input i-gds-name        /* Название на ценнике */
            , input replace( replace( i-gds-name, chr( 39 ), "" ), chr( 34 ), "" )
            , input i-alpha1        /* Код страны */
            , input i-unit-base   /* Ед. изм. */
            , input i-unit-base   /* Ед. изм. */
            , input 0.0           /* Макс. кол-во дробн./шт */
            , input 0.0           /*  Мин. кол-во дробн./шту */
            , input 1             /* Коэффициент  */
            , input 1             /* Кол. в упак.  */
            , input 0             /* Объем штуки */
            , input 0             /* Вес штуки */
            , input 0             /* Объем упаковки  */
            , input 0             /* Вес упаковки  */
            , input {&pr-calc-grp}            /*   Способ расчета  */
            , input 0             /* Процент наценки  */
            , input no            /* Отриц. остаток   */
            , input (if i-service then 1 else 0)
            , input (if i-service then 1 else 0)
            , input ""            /* ОКДП  */
            , input ""          /* Назначение  */
            , input ""          /*  Характеристики */
            , input ""          /*  Правила эксплутации */
            , input ""          /*  Сертификация */
            , input ""      /* Состав (комплектность)  */
            , input 0             /* Срок хранения  */
            , input 0             /* Код условия хранения  */
            , input ""            /* Сорт  */
            , input 0.0           /* процент алкоголя */
            , input 0             /*  Норма естественной убы */
            , input 0             /*  Норма отходов */
            , input ""            /*  Код ТНВЭД */
            , input ""            /*  Национальность */
            , input ""            /* Таможенная единица изм  */
            , input 0             /*  Коэффициент */
            , input ?             /*  Код глоб.группы меню */
            , input ""            /*  Примечание */
            , input no            /* настройка  */
            , input no            /*  в системе разрешены ювелирные изделия */
            , input no            /* в системе разрешена стеклотара  */
            , input no            /*  в системе разрешено топливо */
            , input "no"          /* в системе разрешена таможня  */
            , input yes           /*настройка*/
            , input no            /*настройка*/
            , input no            /* автоматический артикул */
            , input if i-gds-code > 0 then 2 else 0             /*главный код товара берется из артикула*/
            , input-output v-recid
            , output j-gds-code   /*gds-code*/
        ) no-error .

        find first goods where recid( goods)  = v-recid    no-lock no-error.
        if    error-status :error
           or not available goods      
        then do:
/*            message                                           */
/*                     vss-workfile vss-revision vss-description*/
/*                skip "Ошибка создания карточки товара."       */
/*                skip return-value                             */
/*                skip i-artic                                  */
/*                skip trim(error-status :get-message(1))       */
/*                     trim(error-status :get-message(2))       */
/*                     trim(error-status :get-message(3))       */
/*            view-as alert-box error.                          */
            
            put stream str-log unformatted "Ошибка создания карточки товара. Артикул " i-artic " .   " return-value " Строка  " impc  skip .
            next.
/*            IF r-s-stop = 2 THEN RETURN.*/
        end.
        else do :
             
             if p-mark eq 0
             then do:
                 if mnewrec 
                 then do:
                     run gds-attr-exist in this-procedure (goods.gds-code,{&attr-mark-type},output mflag).
                     if not mflag
                     then do:
                        run ggoattr-value(
                            input i-grp-code,
                            input 0,
                            input "",
                            input 0,
                            input {&ggoattr-mark-type},
                            output v-value,
                            output v-type
                          ) no-error.
                  
        /*Есть ли атрибут "Группа товаров на кассе" в группе товаров*/
                        if v-value > "" then do:
                            run gds-attr-write IN THIS-PROCEDURE(
                                input goods.gds-code
                               ,INPUT {&attr-mark-type}
                               ,INPUT v-value ) NO-ERROR.
                           impc-Warn = impc-Warn + 1.
                 put stream str-log unformatted "Внимание Артикул " goods.artic " .  Признак маркировки установлен с группы Строка  " vLine  skip .
                        end. 
                     end.
                 end.    
             end.
             else if i-mark eq ? or i-mark eq 0
             then do:
                 run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                   ,INPUT {&attr-mark-type}
                   ,output mflag).
             end.
             else do:
                MarkTypeStr = MarkType:GetNameProp(i-mark).
                if MarkTypeStr eq MarkType:Unknow:NameProp
                then do:
                      impc-Warn = impc-Warn + 1.
                      put stream str-log unformatted "Внимание Артикул " goods.artic " .  Не известный тип маркировки  " i-mark " Строка " vLine  skip .
                   end.
                   else 
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT {&attr-mark-type}
                   ,INPUT MarkTypeStr
                          ) NO-ERROR.
                 
                end.
                if p-nomcode <> 0
                then do:
                if i-nomcode = ""
                then do:
                   run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                      ,INPUT {&attr-gds-CommodityCode}
                      ,output mflag).
                end.
                else do:
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT {&attr-gds-CommodityCode}
                   ,INPUT i-nomcode
                          ) NO-ERROR.
                end.   
                end.  
             find first goods where goods.gds-code = j-gds-code no-lock no-error.
             if available goods then do:
             if  goods.artic ne i-artic
             then do:
                put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой Артикул. Строка  " vLine  skip .
                impc-Warn = impc-Warn + 1.
             end.
             if     (    i-prod-type ne ?
                     and goods.prod-type ne i-prod-type) 
                or  (i-prod-code ne ? 
                     and goods.prod-code ne i-prod-code)
             then do:
                 impc-Warn = impc-Warn + 1.
                 put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой прозводитель. Строка  " vLine  skip .
             end.
            end.       
           if p-ppr <> ?
              then 
           do:
              if i-ppr <> 0
                 then 
              do:
                 entry(i-ppr,{&prop-list-attr-item-matter-mark}) no-error .
                 if error-status:error then 
                 do:
                    impc-Warn = impc-Warn + 1.
                    put stream str-log unformatted 
                       "Внимание Артикул " goods.artic " .  Не известный признак предмета расчета  " i-ppr " Строка " vLine  skip .
                 end.  
                 else 
                 do: 
                    run gds-attr-write IN THIS-PROCEDURE(
                       input goods.gds-code
                       ,INPUT {&attr-item-matter-mark}
                       ,INPUT i-ppr
                       ) NO-ERROR.
                 end.
              end.   
           end.  
             find first goods where goods.gds-code = j-gds-code no-lock no-error.
             if available goods then do:
             if  goods.artic ne i-artic
             then do:
                put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой Артикул. Строка  " vLine  skip .
                impc-Warn = impc-Warn + 1.
             end.
                
             
             if     (    i-prod-type ne ?
                     and goods.prod-type ne i-prod-type) 
                or  (i-prod-code ne ? 
                     and goods.prod-code ne i-prod-code)
             then do:
                 impc-Warn = impc-Warn + 1.
                 put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой прозводитель. Строка  " vLine  skip .
             end.
            end.                     
            if i-service
            then do :
                for each clients no-lock where clients.obj-type = 'маг' :
                    { gbl/gdscr.i clients.obj-type clients.obj-code  i-artic
                              i-prod-type i-prod-code  1  ub.gds-obj ub.prt-obj }
                    if avail gds-obj then do:
                      find current gds-obj exclusive-lock .
                      assign
                      gds-obj.price-base = 1
                      gds-obj.price-rubl = 1
                      .
                      run str/callnews.p
                        ( input "gds-obj"
                          ,input (buffer gds-obj:handle)
                        ).
                    end.
                end.
            end.
            impc-saved = impc-saved + 1.
            if impc-saved modulo 10 = 0 then
            run waitfram-show in this-procedure (input substitute("Обработано товаров &1", impc-saved)) .
        end.
        
    end.   /*   do transaction: */
    
end.
end.

input stream gds-file close.
output stream str-log close.

run waitfram-hide in this-procedure .
message ("Импорт из файла " + f-name + " закончен" + {&new-line} + "прочитано " + string(impc) +
         ",  сохранено " + string(impc-saved) + ", предупреждений " + string(impc-Warn) + {&new-line} + {&new-line} + "Информация по незагруженным товарам находится в файле gds-imp.log" )
view-as alert-box  INFORMATION.

release object mWorkSheet. /*удаление объекта*/
mExcelApplication:quit. /* Завершает работу Microsoft Excel. */
release object mExcelApplication. /*удаление объекта*/
 