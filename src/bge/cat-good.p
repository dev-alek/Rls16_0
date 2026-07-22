block-level on error undo, throw.
/*

$Revision: 1eba0946c2d7, 3078, rls $
$Author: DRuban $
$Date: ѕт авг 05 19:16:25 2022 +0300 $
$Workfile: cat-good.p $
$Archive: bge/cat-good.p $

Ёкспорт справочника товаров

јвтор: ’ныкин ѕавел јндреевич
ƒата создани€: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:
    p-mode          - режим экспорта (список):
                        "good-ext" - расширенный экспорт, весь справочник
                        "list"     - экспорт товаров с кодами из временной таблицы temp_bge-xml_goods
    temp_bge-xml_goods - список кодов товаров дл€ режима "list"

*/
define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: ѕт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cat-good.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cat-good.p $":U .
define variable vss-description as character no-undo init "Ёкспорт справочника товаров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ bge/bge-xml.i  }
{ trg/factord.i  }
{ str/fbrlib.i   }
{ gbl/temphost.i }
{ ref/gds-attr.i }
{ gbl/objsrv.i }

define input parameter p-mode       as character    no-undo.
define input parameter table for temp_bge-xml_goods .
define input parameter p-file-name  as character    no-undo.


define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.

define temp-table temp_gds-host-attr no-undo
    field host-code as integer
    field no-envd   as logical

    index pi is primary unique
        host-code
.

&SCOP SubDir dict
&SCOP OutFileName good

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif

DEF VAR strPutOut       AS CHAR FORMAT "X(255)" NO-UNDO.
DEF VAR strHomeDir      AS CHAR                 NO-UNDO.
DEF VAR strOutFile      AS CHAR                 NO-UNDO.
DEF VAR sLogFile        AS CHAR                 NO-UNDO.

DEF VAR iRepeater       AS INT      INIT 0      NO-UNDO. /* счетчик дл€ цикла */
DEF VAR bLocked         AS LOGICAL  INIT NO     NO-UNDO. /* флаг блокировки */

DEF VAR ErrorLevel      AS INT                  NO-UNDO. /* ошибка - номер */
define VARIABLE v-gds-attr-value-old as character no-undo.
define VARIABLE v-gds-attr-type as character no-undo.
run bge/bge-ini.p ("bge", OUTPUT strHomeDir).
IF RETURN-VALUE <> "OK" THEN RETURN "ERROR".
strHomeDir = strHomeDir + "{&Slash}{&SubDir}".

/* удостоверитьс€, что директори€ $FRG-ACC/{&SubDir} создана */
run bge/dir_cd.p (strHomeDir, "CA").
IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".

strOutFile = strHomeDir + "{&Slash}" + "{&OutFileName}" + p-file-name + ".".

/* найти исходный файл */
bLocked = (SEARCH (strOutFile + "xml") <> ?).
/* найти файл блокировки */
DO iRepeater = 1 TO 3 WHILE bLocked:
   bLocked = (SEARCH (strOutFile + "lk") <> ?).
   IF bLocked THEN READKEY PAUSE 1.
END.
/* читают/обновл€ют в Ѕухѕриложении - «јѕ»—№ Ќ≈¬ќ«ћќ∆Ќј */
IF bLocked THEN RETURN "LOCKED".
/* удалить старый файл */
run bge/os_copy.p ("D", strOutFile + "xml", "", OUTPUT ErrorLevel).
IF ErrorLevel > 0 THEN RETURN "ERROR".

/*- в кодировке 1251 писать в файл $FRG-ACC/{&SubDir}/{&OutFileName}.xm1 -*/
OUTPUT STREAM stmXMLOut TO VALUE(strOutFile + "xm1") CONVERT TARGET "1251".

ASSIGN sLogFile = strHomeDir + "{&Slash}" + "Actions.log".
run wp-XMLWriteLog(sLogFile, 0, "&Line").
run wp-XMLWriteLog(sLogFile, 1, "Ёкспорт справочника товаров...").

run XMLWriteHeaderCat.

run init-temphost.
for each temp-obj
:
    find first temp_gds-host-attr
         where temp_gds-host-attr.host-code = temp-obj.host-code
    no-error.
    if not available temp_gds-host-attr
    then do:
        create temp_gds-host-attr.
        assign
            temp_gds-host-attr.host-code = temp-obj.host-code
        .
    end.
end.

IF lookup( "list":U, p-mode ) = 0
THEN DO:
    FOR EACH ub.goods NO-LOCK
    :       /* и удаленные товары тоже */
        run XMLWriteGoodsCat in this-procedure (
              input ub.goods.gds-code
            , input sLogFile
        ).
    END.
END.
ELSE DO:
    for each temp_bge-xml_goods
    on error undo, return error
    :
        run XMLWriteGoodsCat in this-procedure (
              input temp_bge-xml_goods.gds-code
            , input sLogFile
        ).
    end.        /* for each temp_bge-xml_goods */
END.

run wp-XMLTagClose(1, "body").
run wp-XMLTagClose(0, "IBS_Trade_House").

OUTPUT STREAM stmXMLOut CLOSE.

/*- переименовать: .xm1 -> .xml -*/
run bge/os_copy.p ("M", strOutFile + "xm1", strOutFile + "xml", OUTPUT ErrorLevel).
IF ErrorLevel > 0 THEN RETURN "ERROR".
/*- права "a+rw" на файл -*/
IF OPSYS = "UNIX" THEN OS-COMMAND SILENT
 chmod 666 value (strOutFile + "xml") 2>/dev/null.

run wp-XMLWriteLog(sLogFile, 1, "Ёкспорт справочника товаров завершЄн.").
run wp-XMLWriteLog(sLogFile, 0, "&Line").
return "OK".

/*========================================================================*/
PROCEDURE XMLWriteGoodsCat:
define input parameter p-gds-code   as integer          no-undo.
define input parameter sLogFile     as character        no-undo.

DEF VAR sPut AS CHAR NO-UNDO.
DEF VAR iBarCode LIKE ub.bar-code.b-code NO-UNDO. /* бар-код товара */

def var v-vat-pc as decimal decimals 10 init 0 no-undo.
def var v-slt-pc as decimal decimals 10 init 0 no-undo.
define variable v-rate-code    as integer      no-undo.
define variable v-have-attr    as logical      no-undo.

define buffer buf_goods                 for ub.goods.
define buffer buf_prod-bc               for ub.prod-bc.
define buffer buf_bar-code              for ub.bar-code.
define buffer buf_alc-type              for ub.alc-type.
define buffer buf_alc-type-gds          for ub.alc-type-gds.
define buffer buf_temp_gds-host-attr    for temp_gds-host-attr.
  define variable v-gds-mercur         as character no-undo .
  define variable v-gds-perishable     as character no-undo .

FIND FIRST buf_goods NO-LOCK
     WHERE buf_goods.gds-code = p-gds-code
.
{ gbl/pgtxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-vat-pc no-error }
{ gbl/pgtxvalg.i buf_goods.gds-code {&slt-tax-code} ? v-slt-pc no-error }
run get-tax-rate-code in this-procedure (
      input buf_goods.gds-code
    , input integer( {&vat-tax-code} )
    , input ?
    , output v-rate-code
).

/*явл€етс€ подконтрольным ‘√»— "ћеркурий"*/                                          
    run gds-attr-value in this-procedure (input Buf_goods.gds-code
                                         ,input {&attr-mercur_FGIS}
                                         ,output v-gds-mercur
                                         ,output v-gds-attr-type ) no-error .
                                         

/*явл€етс€ скоропорт€щейс€ продукцией*/                                          
    run gds-attr-value in this-procedure (input Buf_goods.gds-code
                                         ,input {&attr-perishable}
                                         ,output v-gds-perishable
                                         ,output v-gds-attr-type ) no-error .
/*{ gbl/gdsbcode.i buf_goods.gds-code ? iBarCode no-error }          */
/*IF ERROR-STATUS:ERROR THEN                                         */
/*DO:                                                                */
/*  run wp-XMLWriteLog(sLogFile, 2, "ERROR! Ќе найден баркод товара "*/
/*      + STRING(buf_goods.gds-code) + " или ошибка при поиске").    */
/*END.                                                               */


run wp-XMLTagOpen(2, "{&OutFileName}","").
run wp-XMLTagPut(3, "referenceNo", STRING(buf_goods.gds-code), 0).
run wp-XMLTagPut(3, "articul", buf_goods.artic, 0).
if buf_goods.stts <> 0
then do:
    run wp-XMLTagPut(3, "deleted", "yes", 0).
end.
    run wp-XMLTagPut(3, "prodtype", buf_goods.prod-type, 0).
    run wp-XMLTagPut(3, "prodcode", buf_goods.prod-code, 0).
run wp-XMLTagPut(3, "units", buf_goods.unit-base, 0).
run wp-XMLTagPut(3, "type", buf_goods.gds-type, 0).
run wp-XMLTagPut(3, "minstock", STRING(buf_goods.min-stock), 0).
run wp-XMLTagPut(3, "okdp", buf_goods.okdp, 0).
run wp-XMLTagPut(3, "name", buf_goods.gds-name, 0).
run wp-XMLTagPut(3, "nameengl", buf_goods.engl-name, 0).
if lookup( "good-ext":U, p-mode ) <> 0
then do:
    define variable v-have-recipe          as logical      no-undo.
    define variable v-is-ingredient        as logical      no-undo.
    define variable v-can-be-income        as logical      no-undo.
    define variable v-can-be-write-off     as logical      no-undo.
    run get-fbr-trn-type in this-procedure (
          input buf_goods.gds-code
        , output v-have-recipe
        , output v-is-ingredient
        , output v-can-be-income
        , output v-can-be-write-off
    ).
    run wp-XMLTagPut in this-procedure ( input 3, input "labelname"             , input string( buf_goods.label-name    ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "destin           " ), input string( buf_goods.destin        ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "attrib           " ), input string( buf_goods.attrib        ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "userRule         " ), input string( buf_goods.user-rule     ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "sert             " ), input string( buf_goods.sert          ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "struct           " ), input string( buf_goods.struct        ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "deadline         " ), input string( buf_goods.deadline      ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "sort             " ), input string( buf_goods.sort          ), input 0 ).
/*    run wp-XMLTagPut in this-procedure ( input 3, input trim( "tnved            " ), input string( buf_goods.tnved         ), input 0 ).*/
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "unitCST          " ), input string( buf_goods.unit-cst      ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "CSTBaseRate      " ), input string( buf_goods.cst-base-rate ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "nationality      " ), input string( buf_goods.nationality   ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "normalWastage    " ), input string( buf_goods.normal-wastage), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "normalWaste      " ), input string( buf_goods.normal-waste  ), input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "haveRecipe       " ), input string( v-have-recipe           ), input 3 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "isIngredient     " ), input string( v-is-ingredient         ), input 3 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "canBeIncome      " ), input string( v-can-be-income         ), input 3 ).
    run wp-XMLTagPut in this-procedure ( input 3, input trim( "canBeWriteOff    " ), input string( v-can-be-write-off      ), input 3 ).
end.
run wp-XMLTagPut in this-procedure ( input 3, input "VAT"           , input STRING( v-vat-pc                )   , input 0 ).
run wp-XMLTagPut in this-procedure ( input 3, input "VATRateCode"   , input STRING( v-rate-code             )   , input 0 ).
run wp-XMLTagPut in this-procedure ( input 3, input "SLT"           , input STRING( v-slt-pc                )   , input 0 ).
run wp-XMLTagPut in this-procedure ( input 3, input "country"       , input buf_goods.alpha1                    , input 0 ).
run wp-XMLTagPut in this-procedure ( input 3, input "margin"        , input STRING( buf_goods.increase-pc   )   , input 0 ).
find first ub.units no-lock
     where ub.units.unit-name = buf_goods.unit-base
no-error.
if available ub.units
then do:
    run wp-XMLTagPut(3, "unitType", units.type, 0).
end.        /* available units */
else do:
    run wp-XMLTagPut(3, "unitType", "", 0).
    run wp-XMLWriteLog(sLogFile, 2, "ERROR! Ќе найден тип '" + buf_goods.unit-base
            + "' товара '" + STRING(buf_goods.gds-code) + "' или ошибка при поиске").
end.        /* NOT ( available units ) */


  for each buf_bar-code where buf_bar-code.gds-code = buf_goods.gds-code and buf_bar-code.part-code = "" and buf_bar-code.in-code = "" no-lock:
      
      run wp-XMLTagOpen(3, "barcode", "").
      run wp-XMLTagPut(4, "barcodenum", STRING(buf_bar-code.b-code, "->>>>>>>>>9"),0).
      run wp-XMLTagPut(4, "barcodeclibase", STRING(buf_bar-code.cli-base-rate ),0).
      run wp-XMLTagPut(4, "barcodecliunit", STRING(buf_bar-code.unit-cli ),0).
            for each buf_prod-bc no-lock
               where buf_prod-bc.b-code = buf_bar-code.b-code
            on error undo, return error
            :
                run wp-XMLTagOpen(5, "bcode","").
                run wp-XMLTagPut(6, "bcodeStr"     , string( buf_prod-bc.b-str         ),  0).
                run wp-XMLTagPut(6, "bcodeOn"      , string( buf_prod-bc.bc-on         ),  0).
                run wp-XMLTagClose(5, "bcode").
            end.        /* for each buf_prod-bc */
       run wp-XMLTagClose(3, "barcode").     
  end. /*for each buf_bar-code where buf_bar-code.gds-code = buf_goods.gds-code:*/
run wp-XMLTagPut(3, "groupcode", STRING(buf_goods.grp-code),0).
run wp-XMLTagPut(3, "condKeepCode", STRING(buf_goods.cond-keep-code),0).

run wp-XMLTagPut(3, "unitCli"       , string( buf_goods.unit-cli        ),  0).
run wp-XMLTagPut(3, "cliBaseRate"   , string( buf_goods.cli-base-rate   ),  0).
run wp-XMLTagPut(3, "msCart"        , string( buf_goods.ms-cart         ),  0).
run wp-XMLTagPut(3, "wtCart"        , string( buf_goods.wt-cart         ),  0).
run wp-XMLTagPut(3, "qntyCart"      , string( buf_goods.qnty-cart       ),  0).
run wp-XMLTagPut(3, "msBase"        , string( buf_goods.ms-base         ),  0).
run wp-XMLTagPut(3, "wtBase"        , string( buf_goods.wt-base         ),  0).

RUN gds-attr-value (
                        INPUT buf_goods.gds-code,
                        INPUT {&attr-alcohol-prod},
                        OUTPUT v-gds-attr-value-old,
                        OUTPUT v-gds-attr-type
                        ).
     if v-gds-attr-value-old = "yes" then do:
        for first buf_alc-type-gds where buf_alc-type-gds.gds-code = buf_goods.gds-code no-lock:
            if AVAILABLE buf_alc-type-gds then do:
               for first buf_alc-type where buf_alc-type.alc-type-inner-code = buf_alc-type-gds.alc-type-inner-code no-lock:
               run wp-XMLTagOpen(3, "alcAttr","").
                   run wp-XMLTagPut(4, "alcgoods"            , string( "yes"               ),  0).
                   run wp-XMLTagPut(4, "alcprodcode"         , string( buf_alc-type.alc-type-code         ),  0).
                   run wp-XMLTagPut(4, "alcprodname"         , string( buf_alc-type.alc-type-name         ),  0).
                   run wp-XMLTagPut(4, "alcproof"            , string( buf_goods.proof                    ),  0).
               run wp-XMLTagClose(3, "alcAttr").
               end.
            end.
        end.         
     end.                   
  run wp-XMLTagPut(3, "comment", buf_goods.PS, 0).
  run wp-XMLTagPut(3, "mercuri"           , string( if v-gds-mercur = "no" then "0" else "1"),  0).
  run wp-XMLTagPut(3, "perishable"        , string( if v-gds-perishable = "no" then "0" else "1"),  0).
  RUN gds-attr-value (
                        INPUT buf_goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-gds-attr-value-old,
                        OUTPUT v-gds-attr-type
                        ).
  def var mMark as integer no-undo.
  mMark = MarkType:GetKeyIntDB(v-gds-attr-value-old).
  
  run wp-XMLTagPut(3, "mark-type"        , if mMark < 0 then  "" else string(mmark),  0).
  RUN gds-attr-value (
                        INPUT buf_goods.gds-code,
                        INPUT {&attr-item-matter-mark},
                        OUTPUT v-gds-attr-value-old,
                        OUTPUT v-gds-attr-type
                        ).
  run wp-XMLTagPut(3, "item-matter-mark"        , v-gds-attr-value-old,  0).
run fill-gds-host-attr in this-procedure (
      input p-gds-code
    , output v-have-attr
).
if v-have-attr = yes
then do:
    run wp-XMLTagOpen(3, "gdsHostAttr","").
    for each buf_temp_gds-host-attr
       where buf_temp_gds-host-attr.no-envd = yes
    :
        run wp-XMLTagPut(4, "hostCode"     , string( buf_temp_gds-host-attr.host-code  ),  0).
        run wp-XMLTagPut(4, "noENVD"       , string( buf_temp_gds-host-attr.no-ENVD    ),  0).
    end.        /* for each buf_temp_gds-host-attr */
    run wp-XMLTagClose(3, "gdsHostAttr").
end.
/*run wp-XMLTagPut(3, "group", buf_goods.grp-code, 0).*/

run wp-XMLTagClose(2, "{&OutFileName}").

END PROCEDURE.

/*========================================================================*/
PROCEDURE XMLWriteHeaderCat:

PUT STREAM stmXMLOut UNFORMATTED "<?xml version='1.0' encoding='windows-1251'?>".
/*PUT STREAM stmXMLOut UNFORMATTED {&new-line} + '<?xml-stylesheet type="text/xsl" href="{&OutFileName}.xsl"?>'.*/
PUT STREAM stmXMLOut UNFORMATTED {&new-line} +
                  '<IBS_Trade_House>'.
run wp-XMLTagOpen(1, "header","").
run wp-XMLTagOpen(2, "delivery","").
run wp-XMLTagOpen(3, "to","").
run wp-XMLTagClose(3, "to").
run wp-XMLTagOpen(3, "from","").
run wp-XMLTagClose(3, "from").
run wp-XMLTagClose(2, "delivery").
run wp-XMLTagOpen(2, "manifest","").
run wp-XMLTagOpen(3, "document","").
run wp-XMLTagPut(4, "name","{&OutFileName}", 0).
run wp-XMLTagPut(4, "description","", 0).
run wp-XMLTagClose(3, "document").
run wp-XMLTagClose(2, "manifest").
run wp-XMLTagClose(1, "header").
run wp-XMLTagOpen(1, "body","").

END PROCEDURE.

/*==========================================================================*/
procedure get-tax-rate-code :
define input parameter p-gds-code   as integer          no-undo.
define input parameter p-tax-code   as integer          no-undo.
define input parameter p-date       as date             no-undo.
define output parameter p-rate-code as integer          no-undo.

    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-fact-order        as integer      no-undo.

    define buffer buf_tax-rate-gds      for ub.tax-rate-gds.
do
for buf_tax-rate-gds
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    if p-date = ?
    then do:
        assign
            p-date = v-today
        .
    end.
    run factord-end-day in this-procedure (
          input p-date
        , output v-fact-order
    ).
    find last buf_tax-rate-gds no-lock
        where buf_tax-rate-gds.gds-code   = p-gds-code
          and buf_tax-rate-gds.tax-code   = p-tax-code
          and buf_tax-rate-gds.host-code  = 0
          and buf_tax-rate-gds.obj-type   = ""
          and buf_tax-rate-gds.obj-code   = 0
          and buf_tax-rate-gds.fact-order <= v-fact-order
    no-error .
    if not available buf_tax-rate-gds
    then do:
        assign
            p-rate-code = 0
        .
    end.
    else do:
        assign
            p-rate-code = buf_tax-rate-gds.rate-code
        .
    end.

end.
end procedure. /* get-tax-rate-code */


/*==========================================================================*/
procedure get-fbr-trn-type :
define input parameter p-gds-code           as integer          no-undo.
define output parameter p-have-recipe       as logical          no-undo.
define output parameter p-is-ingredient     as logical          no-undo.
define output parameter p-can-be-income     as logical          no-undo.
define output parameter p-can-be-write-off  as logical          no-undo.

    define variable v-is-comp       as logical      no-undo.
    define variable v-trn-type      as character    no-undo.
    define variable v-recipe-type   as character    no-undo.

    define buffer buf_goods         for ub.goods.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_recipe-gds    for ub.recipe-gds.
do
for buf_goods
  , buf_recipe
  , buf_recipe-gds
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    assign
        p-have-recipe       = no
        p-is-ingredient     = no
        p-can-be-income     = no
        p-can-be-write-off  = no
    .
    find first buf_recipe no-lock
         where buf_recipe.artic       = buf_goods.artic
           and buf_recipe.prod-type   = buf_goods.prod-type
           and buf_recipe.prod-code   = buf_goods.prod-code
    no-error.
    if available buf_recipe
    then do:
        assign
            p-have-recipe = yes
        .
    end.
    find first buf_recipe-gds no-lock
         where buf_recipe-gds.artic       = buf_goods.artic
           and buf_recipe-gds.prod-type   = buf_goods.prod-type
           and buf_recipe-gds.prod-code   = buf_goods.prod-code
    no-error.
    if available buf_recipe-gds
    then do:
        assign
            p-is-ingredient = yes
        .
    end.
    if p-have-recipe = yes
    then do:
        find first buf_recipe no-lock
             where buf_recipe.artic       = buf_goods.artic
               and buf_recipe.prod-type   = buf_goods.prod-type
               and buf_recipe.prod-code   = buf_goods.prod-code
               and buf_recipe.recipe-type = {&gathering}
        no-error.
        if available buf_recipe
        then do:
            assign
                p-can-be-income    = yes
                p-can-be-write-off = yes
            .
            return .
        end.
        else do:
            calc-trn-type-by-recipe:
            for each buf_recipe no-lock
               where buf_recipe.artic       = buf_goods.artic
                 and buf_recipe.prod-type   = buf_goods.prod-type
                 and buf_recipe.prod-code   = buf_goods.prod-code
            on error undo, return error
            :
                run fbrlib-get-trn-type in this-procedure (
                      input buf_recipe.recipe-code
                    , input recid( buf_goods )
                    , input yes
                    , output v-is-comp
                    , output v-trn-type
                ).
                if v-trn-type = {&income}
                then do:
                    assign
                        p-can-be-income    = yes
                    .
                end.
                if v-trn-type = {&write-off}
                then do:
                    assign
                        p-can-be-write-off = yes
                    .
                end.
            end.        /* for each buf_recipe */
        end.
    end.
    if p-is-ingredient = yes
    then do:
        calc-trn-type-by-recipe-gds:
        for each buf_recipe-gds no-lock
           where buf_recipe-gds.artic       = buf_goods.artic
             and buf_recipe-gds.prod-type   = buf_goods.prod-type
             and buf_recipe-gds.prod-code   = buf_goods.prod-code
        on error undo, return error
        :
            run fbrlib-get-recipe-type in this-procedure (
                  input "":U
                , input buf_recipe-gds.recipe-code
                , output v-recipe-type
            ).
            if v-recipe-type = {&gathering}
            then do:
                assign
                    p-can-be-income    = yes
                    p-can-be-write-off = yes
                .
                return .
            end.
            run fbrlib-get-trn-type in this-procedure (
                  input buf_recipe-gds.recipe-code
                , input recid( buf_goods )
                , input yes
                , output v-is-comp
                , output v-trn-type
            ).
            if v-trn-type = {&income}
            then do:
                assign
                    p-can-be-income    = yes
                .
            end.
            if v-trn-type = {&write-off}
            then do:
                assign
                    p-can-be-write-off = yes
                .
            end.
        end.        /* for each buf_recipe-gds */
    end.
end.
end procedure. /* get-fbr-trn-type */


/*==========================================================================*/
procedure fill-gds-host-attr :
define input parameter p-gds-code   as integer          no-undo.
define output parameter p-have-attr as logical          no-undo.

    define buffer buf_gds-host-attr         for ub.gds-host-attr.
    define buffer buf_temp_gds-host-attr    for temp_gds-host-attr.
do
for buf_gds-host-attr
  , buf_temp_gds-host-attr
on error undo, return error
:
    assign
        p-have-attr = no
    .
    for each buf_temp_gds-host-attr
    :
        find first buf_gds-host-attr no-lock
             where buf_gds-host-attr.host-code = buf_temp_gds-host-attr.host-code
               and buf_gds-host-attr.gds-code  = p-gds-code
               and buf_gds-host-attr.attr-code = "no-envd":U
        no-error.
        if not available buf_gds-host-attr
        then do:
            assign
                buf_temp_gds-host-attr.no-envd = no
            .
        end.
        else do:
            assign
                buf_temp_gds-host-attr.no-envd = ( buf_gds-host-attr.attr-value = "yes":U )
            .
        end.
        if buf_temp_gds-host-attr.no-envd = yes
        then do:
            assign
                p-have-attr = yes
            .
        end.
    end.
end.
end procedure. /* fill-gds-host-attr */
