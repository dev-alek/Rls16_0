block-level on error undo, throw.
/*

$Revision: f5e72f13272f, 2363, rls $
$Author: druban $
$Date: Ср июн 10 21:13:42 2020 +0300 $
$Workfile: nxtgdsi.p $
$Archive: ref/nxtgdsi.p $

Импорт из файла следующего товара в карточку товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

DEFINE INPUT PARAMETER vattaxcd     AS integer NO-UNDO.
DEFINE INPUT PARAMETER slttaxcd     AS integer NO-UNDO.
define input parameter custvalue    as character no-undo .
DEFINE INPUT PARAMETER p-artic     AS integer NO-UNDO.
define input parameter p-prod      as integer no-undo . /*в виде орг5 или чел182*/
DEFINE INPUT PARAMETER p-name      AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-engl-name AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-unit-base AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-VAT-code  AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-SLT-code  AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-Struct  AS integer NO-UNDO.
define input parameter p-tnved    as integer no-undo .
define input parameter p-attrib    as integer no-undo .
define input parameter p-destin    as integer no-undo .
define input parameter p-sert    as integer no-undo .
define input parameter p-user-rule    as integer no-undo .
define input parameter p-alpha1       as integer no-undo .
define input parameter p-grp-code     as integer no-undo .
define input parameter p-service      as integer no-undo .
define input parameter p-gds-code      as integer no-undo .
define input parameter p-mark      as integer no-undo .
/*номер строчки импорта*/
DEFINE INPUT PARAMETER ii as integer No-UNDO.

DEFINE INPUT-OUTPUT PARAMETER i-artic as char NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-prod-type as char NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-prod-code as integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-name as char NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-engl-name as char NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-unit-base as char NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-VAT-code as integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-SLT-code as integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER i-Struct as character NO-UNDO.
define input-output parameter i-tnved like ub.goods.tnved no-undo .
define input-output parameter i-attrib like ub.goods.attrib no-undo .
define input-output parameter i-destin like ub.goods.destin no-undo .
define input-output parameter i-sert like ub.goods.sert no-undo .
define input-output parameter i-user-rule like ub.goods.user-rule no-undo .
define input-output parameter i-alpha1 like ub.goods.alpha1 no-undo .
define input-output parameter i-grp-code like ub.goods.grp-code no-undo .
define input-output parameter i-service as logical no-undo .
define input-output parameter i-gds-code like ub.goods.gds-code no-undo .
define input-output parameter i-mark as integer  no-undo .

define variable vss-revision    as character no-undo init "$Revision: f5e72f13272f, 2363, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: nxtgdsi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/nxtgdsi.p $":U .
define variable vss-description as character no-undo init "Импорт из файла следующего товара в карточку товара".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/t-tnved.i }

DEFINE SHARED stream gds-file.
DEFINE var text-string as char no-undo.
define variable i-prod as character no-undo .
IMPORT stream gds-file UNFORMATTED text-string NO-ERROR.
if text-string = ? or text-string = "" then return "END" .
if error-status:error then return error.

if p-artic > 0
then
assign
i-artic = ENTRY(p-artic, text-string, ";").
else
assign
i-artic = "".

if p-name > 0
then
assign
i-name = ENTRY(p-name, text-string, ";").
else
assign
i-name = "".

if p-engl-name > 0
then
assign
i-engl-name = ENTRY(p-engl-name, text-string, ";").
else
assign
i-engl-name = "".

if p-SLT-code > 0
then do:
        assign
        i-SLT-code = integer(ENTRY(p-SLT-code, text-string, ";"))
        no-error.
        if error-status:error then do:
            message "Неверное значение кода ставки НП "
                    ENTRY(p-SLT-code, text-string, ";") skip
                    " - поле N " p-SLT-code
                    "   строчка N " ii
            view-as alert-box ERROR .
            return ERROR.
        end.
        else do:
            FIND FIRST ub.tax-rate NO-LOCK where
                       ub.tax-rate.rate-code = i-SLT-code
                       No-ERROR.
            IF NOT avail ub.tax-rate then do:
                message "Нет в БД ставки налога с кодом "
                        ENTRY(p-SLT-code, text-string, ";") skip
                        " - поле N " p-SLT-code
                        "   строчка N " ii
                view-as alert-box ERROR.
                i-SLT-code = 0.
                return error.
            END.
            ELSE DO:
                if ub.tax-rate.tax-code <> slttaxcd then do:
                    message "Для ставки налога с кодом "
                            ENTRY(p-SLT-code, text-string, ";")
                            "код налога отличается от кода НП" skip
                            " - поле N " p-SLT-code
                            "   строчка N " ii
                    view-as alert-box ERROR .
                    i-SLT-code = 0.
                    return ERROR.
                end.
            END.
        end.
end.
else do:
    assign
    i-SLT-code = 0.
end.


if p-unit-base > 0
then do:
    FIND FIRST ub.units NO-LOCK where
                        ub.units.unit-name = ENTRY(p-unit-base, text-string, ";")
                       No-ERROR.
        IF NOT avail ub.units then do:
            message "Нет в БД единицы измерения "
                    ENTRY(p-unit-base, text-string, ";") skip
                    " - поле N " p-unit-base
                    "   строчка N " ii
            view-as alert-box ERROR.
            return error.
        END.
    assign
    i-unit-base = ENTRY(p-unit-base, text-string, ";").
end.
else
assign
i-unit-base = "".


if p-VAT-code > 0
then do:
        assign
        i-vat-code = integer(ENTRY(p-vat-code, text-string, ";"))
        no-error.
        if error-status:error then do:
            message "Неверное значение кода ставки НП "
                    ENTRY(p-vat-code, text-string, ";") skip
                    " - поле N " p-vat-code
                    "   строчка N " ii
            view-as alert-box ERROR .
            return ERROR.
        end.
        else do:
            FIND FIRST ub.tax-rate NO-LOCK where
                       ub.tax-rate.rate-code = i-vat-code
                       No-ERROR.
            IF NOT avail ub.tax-rate then do:
                message "Нет в БД ставки налога с кодом "
                        ENTRY(p-vat-code, text-string, ";") skip
                        " - поле N " p-vat-code
                        "   строчка N " ii
                view-as alert-box ERROR.
                i-vat-code = 0.
                return error.
            END.
            ELSE DO:
                if tax-rate.tax-code <> vattaxcd then do:
                    message "Для ставки налога с кодом "
                            ENTRY(p-vat-code, text-string, ";")
                            "код налога отличается от кода НДС" skip
                            " - поле N " p-vat-code
                            "   строчка N " ii
                    view-as alert-box ERROR .
                    i-vat-code = 0.
                    return ERROR.
                end.
            END.
        end.
end.
else do:
    assign
    i-VAT-code = 0.
end.
if p-struct > 0
then
assign
i-struct = ENTRY(p-struct, text-string, ";").
else
assign
i-struct = "".

if p-tnved > 0 then do:
  assign
  i-tnved = ENTRY(p-tnved, text-string, ";")
  no-error
  .
  if custvalue = "yes":U then do:
    FIND FIRST TT-tnved WHERE
              TT-tnved.tnved = i-tnved no-error.
    if not available TT-tnved then do:
      message
      "Код ТНВЭД не найден в справочнике."
      view-as alert-box error.
      assign
      i-tnved = "":U.
      return error.
    end.
  end.
  if length(trim(i-tnved)) <> 10 then do:
    message
    "Код ТНВЭД для товару должен быть 10-ти символьный."
    view-as alert-box error.
    assign
    i-tnved = "":U.
    return error.
  end.
end.
else
assign
i-tnved = "".

if p-attrib > 0
then
assign
i-attrib = ENTRY(p-attrib, text-string, ";").
else
assign
i-attrib = "".

if p-destin > 0
then
assign
i-destin = ENTRY(p-destin, text-string, ";").
else
assign
i-destin = "".

if p-sert > 0
then
assign
i-sert = ENTRY(p-sert, text-string, ";").
else
assign
i-sert = "".

if p-user-rule > 0
then
assign
i-user-rule = ENTRY(p-user-rule, text-string, ";").
else
assign
i-user-rule = "".

if p-prod > 0
then do:
  assign
  i-prod = ENTRY(p-prod, text-string, ";").
  assign
  i-prod-type = substring(i-prod, 1, 3)
  i-prod-code = integer(substring(i-prod, 4))
  no-error .
  if error-status:error then do:
    message
    substitute("Неверный формат поля ПРОИЗВОДИТЕЛЬ для товара: &1", i-prod)
    view-as alert-box error.
    assign
    i-prod-type = "":U
    i-prod-code = 0
    .
    return error.
  end.
end.
else
assign
i-prod-type = ""
i-prod-code = 0
.
if p-alpha1 > 0
then
assign
i-alpha1 = ENTRY(p-alpha1, text-string, ";").
else
assign
i-alpha1 = ""
.
if p-grp-code > 0
then
assign
i-grp-code = integer(ENTRY(p-grp-code, text-string, ";")).
else
assign
i-grp-code = 0
.

if p-service > 0
then
assign
i-service = logical(ENTRY(p-service, text-string, ";")).
else
assign
i-service = no
.

if p-gds-code > 0
then do :
  assign
    i-gds-code = integer(ENTRY(p-gds-code, text-string, ";"))
  no-error .
  if error-status:error
  or i-gds-code <= 0
  then do:
      message "Неверное значение кода товара "
              ENTRY(p-gds-code, text-string, ";") skip
              " - поле N " p-gds-code
              "   строчка N " ii
      view-as alert-box ERROR .
      return ERROR.
  end.

end.
else
assign
i-gds-code = 0
.

if p-mark > 0
then do :
  assign
    i-mark = int(ENTRY(p-mark, text-string, ";"))
  no-error .
  end.
else
assign
i-mark = 0
.
