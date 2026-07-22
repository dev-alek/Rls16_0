block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для работы с бар-кодами

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

Создана: 06/09/2004
*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с бар-кодами".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/libbcrcn.i }
{utl/gtin.i}
if valid-handle (g#libbcrcn)
and g#libbcrcn <> this-procedure :handle
and g#libbcrcn :get-signature('libbcrcn_bc-rcnz':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с бар-кодами" skip
    g#libbcrcn skip
    g#libbcrcn :type skip
    g#libbcrcn :file-name skip
    valid-handle(g#libbcrcn) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libbcrcn = this-procedure :handle
  .
end.

on delete of this-procedure do:
  assign
    g#libbcrcn = ?
  .
end.
define stream str-err.
procedure libbcrcn_dm-rcnz:
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter parstr-code as character                no-undo.
define input  parameter parprice    like ub.doc-line.price-base no-undo.
define input  parameter parobj-type like ub.clients.obj-type    no-undo.
define input  parameter parobj-code like ub.clients.obj-code    no-undo.
define input  parameter parwith-chs as logical                  no-undo.
define input  parameter paronly-b-code as logical               no-undo.
Define input  parameter parscales-pref as character             no-undo.
Define input  parameter parpgscales-pref as character             no-undo.
define output parameter parresult   as character                no-undo.
define output parameter partype-bc  as character                no-undo.
define output parameter parweight   as decimal                  no-undo.
define parameter buffer bf_bar-code for ub.bar-code.
define parameter buffer bf_prod-bc  for ub.prod-bc.
define parameter buffer bf_place    for ub.place.
      parstr-code = getGtinByDM(parstr-code).
      
{ str/bc-rcnz.i
          parparentproc
          parstr-code
          parprice
          parobj-type
          parobj-code
          parwith-chs
          paronly-b-code
          parscales-pref
          parpgscales-pref
          parresult
          partype-bc
          parweight
          bf_bar-code
          bf_prod-bc
          bf_place
          no-error
        }
end procedure.

procedure libbcrcn_bc-rcnz:
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter parstr-code as character                no-undo.
define input  parameter parprice    like ub.doc-line.price-base no-undo.
define input  parameter parobj-type like ub.clients.obj-type    no-undo.
define input  parameter parobj-code like ub.clients.obj-code    no-undo.
define input  parameter parwith-chs as logical                  no-undo.
define input  parameter paronly-b-code as logical               no-undo.
Define input  parameter parscales-pref as character             no-undo.
Define input  parameter parpgscales-pref as character             no-undo.
define output parameter parresult   as character                no-undo.
define output parameter partype-bc  as character                no-undo.
define output parameter parweight   as decimal                  no-undo.
define parameter buffer bf_bar-code for ub.bar-code.
define parameter buffer bf_prod-bc  for ub.prod-bc.
define parameter buffer bf_place    for ub.place.

define variable varbc-frmt     as character no-undo.
define variable varbc-pfx      as character no-undo.
define variable varpl-frmt     as character no-undo.
define variable varpl-pfx      as character no-undo.
define variable varpar-type    as character no-undo.
define variable varstr-gen-int as integer   no-undo.
define variable varstr-gen     as character no-undo.  /* сгенеренный доп. бар-код      */
define variable varsrc-gen-int as integer   no-undo.
define variable varrid         as recid     no-undo.
define variable varpovtor      as logical   no-undo.
define variable varpgscales-pref as character no-undo .


&scop add-bc-ass   if length (parstr-code) <= 5 then do:                      ~
                      assign                                                  ~
                      partype-bc = "Весовой код".                             ~
                      if length (parstr-code) < 5 then do:                    ~
                        assign                                                ~
                        partype-bc = partype-bc + " без ведущих нулей".       ~
                      end.                                                    ~
                   end.                                                       ~
                   else do:                                                   ~
                     partype-bc = "Дополнительный код".                       ~
                   end.

release bf_bar-code.
release bf_prod-bc .
release bf_place   .
assign
  partype-bc = "".
if not paronly-b-code then do:
  if lookup (substr (parstr-code, 1, 2), parscales-pref) > 0 and
    length (parstr-code) = 13                               then do:
    /* весовой бар-код EAN-13 */
    /* выделяем весовой код и ищем */
    find first bf_prod-bc where
              bf_prod-bc.b-str = string (integer (substr (parstr-code, 3, 5)), "99999") and
              bf_prod-bc.bc-on = yes                                                    no-lock no-error.
    assign
      partype-bc = "Весовой бар-код (EAN-13)"
      parweight  = decimal (substr (parstr-code, 8, 5)) / 1000.
  end.
  define variable v-ii as integer no-undo .
  define variable v-q as character no-undo .
  define variable v-format as character no-undo .
  varpgscales-pref = parpgscales-pref.
  do v-ii = 1 to num-entries(parpgscales-pref):
    entry(v-ii, varpgscales-pref) = substring(entry(v-ii, varpgscales-pref), 1, 2).
  end.
  if lookup (substr (parstr-code, 1, 2), varpgscales-pref) > 0 and
    length (parstr-code) = 13                               then do:
    /* штучный код для весов EAN-13 */
    /* выделяем штучный код и ищем */
    find first bf_prod-bc where
              bf_prod-bc.b-str = string (integer (substr (parstr-code, 3, 5)), "99999") and
              bf_prod-bc.bc-on = yes                                                    no-lock no-error.
    assign
      partype-bc = "Штучный код для весов (EAN-13)"
    v-format = entry(lookup(substr(parstr-code, 1, 2), varpgscales-pref), parpgscales-pref)
    parweight  = decimal (substr (parstr-code, 8, 5)) / exp(10, num-entries(substring(v-format, 8,5), "0") - 1)
    .
  end.

  /* ищем доп БК таким, как он есть */
  if not available bf_prod-bc then do:
    find first bf_prod-bc where
               bf_prod-bc.b-str = parstr-code and
               bf_prod-bc.bc-on = yes         no-lock no-error.
  end.
  if not available bf_prod-bc and
    length (parstr-code) < 5 then do:
    /* любой код короче 5 считаем весовым и дополняем слева нулями */
    find first bf_prod-bc where
              bf_prod-bc.b-str = string (int (parstr-code), "99999") and
              bf_prod-bc.bc-on = yes                                 no-lock no-error.
  end.
  if available bf_prod-bc then do:
    /* найден включенный дополнительный бар-код */
    assign
    varrid    = recid (bf_prod-bc)
    parresult = "prod-bc".
    {&add-bc-ass}
  end.
  else do:
      define variable vtxt as character no-undo.
      vtxt = parstr-code.
      if    length(vtxt) > 14
      then do:  
         vtxt = getGtinByDM(parstr-code).
         if vtxt ne ""
         then
            find first bf_prod-bc where
                 bf_prod-bc.b-str = vtxt and
                 bf_prod-bc.bc-on = yes                                 no-lock no-error.
      end.
       if available bf_prod-bc then do:
        /* найден включенный дополнительный баркод */
        assign
        varrid    = recid (bf_prod-bc)
        parresult = "gtin".
      end.
      else do:
        assign
        varrid = ?.
      end.
  end.
  assign
    varpovtor = no.
  if (varrid <> ?       and
      bf_prod-bc.b-str = parstr-code) or
      varrid = ? then do:
    /* ищем повторный для ИСХОДНОГО, если не было дополнения слева нулями или вырезания из весового БК
      если весовой код был найден после дополнения или вырезания, повторные показаны НЕ БУДУТ ! */
    /*ВЕСОВОЙ НЕ МОЖЕТ БЫТЬ ВЫКЛЮЧЕН*/
    find first bf_prod-bc where
               bf_prod-bc.b-str = parstr-code and
               recid (bf_prod-bc) <> varrid  no-lock no-error.
    if available bf_prod-bc then do:
      /* есть повторные или 1 выключенный - требуем подтверждения */
      if varrid = ? then do:
        assign
        parresult = "prod-bc"
        varrid    = recid (bf_prod-bc).
        /*может быть несколько выключенных*/
        find first bf_prod-bc where
                    bf_prod-bc.b-str = parstr-code and
                    recid (bf_prod-bc) <> varrid  no-lock no-error.
        if available bf_prod-bc then do:
          if parwith-chs = no then do:
            assign varrid = ?.
          end.
          else do:
            assign
              varpovtor = yes.
            {&add-bc-ass}
          end.
        end.
      end.
      else do:
        if parwith-chs = yes then do:
          assign
            varpovtor = yes.
        end.
      end.
      if varpovtor then do:
        /* выбор правильного или отказ */
        define variable varrid1 as recid no-undo .
        varrid1 = varrid .
        run ref/bc-rcnz.w (input parparentproc,
                       input parobj-type,
                       input parobj-code,
                       input parstr-code,
                       input parprice,
                       input "choose",
                       input-output varrid).
      /* bc-rcnz.w может вернуть ?, если не подходит ни один из повторных */
      end.
    end.
    if varrid = ? then varrid = varrid1 .
    find bf_prod-bc where recid (bf_prod-bc) = varrid no-lock no-error.
    if available bf_prod-bc then do:
      assign
        partype-bc = partype-bc + (if bf_prod-bc.bc-on = yes then " (включен) " else " (выключен) ").
    end.
    
  end.
end. /*if not paronly-b-code*/
if available bf_prod-bc then do:
  find first bf_bar-code where bf_bar-code.b-code = bf_prod-bc.b-code no-lock.
end.
else do:
  /* доп БК не найден - ищем основной */
  { gbl/conf-rd.i
    "'bc-frmt':u"
    "'':u"
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    yes
    varbc-frmt
    varpar-type
    no-error
  }
  { gbl/conf-rd.i
    "'bc-pfx':u"
    "'':u"
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    yes
    varbc-pfx
    varpar-type
    no-error
  }
  if not error-status:error and
     varpar-type = "C":U and
     lookup (varbc-frmt, "EAN8,EAN13") > 0 then do:
    /* формат из настроек прочитан */
    if length (parstr-code) = 13 and
       varbc-frmt = "EAN13" or
       length (parstr-code) = 8 and
       varbc-frmt = "EAN8" then do:
      if varpar-type = "C":U     and
         length (varbc-pfx) <= 3 then do:
        assign
          partype-bc = " бар-код (EAN-" + if length (parstr-code) = 13 then "13)" else "8)".
        /* префикс из настроек прочитан - макс длина не может быть больше 3, т.к. локал. код 9 разрядов */
        if substr (parstr-code, 1, length (varbc-pfx)) = varbc-pfx then do:
          /* префиксы совпадают - это собственный бар-код - вырезаем локальный код */
          assign
            parstr-code = substr (parstr-code, length (varbc-pfx) + 1, length (parstr-code) - length (varbc-pfx) - 1).
        end.
      end.
      else do:
        return error "Ошибка параметра bc-pfx - нет префикса для собственных бар-кодов.".
      end.
    end.
  end.
  else do:
    return error "Ошибка параметра bc-frmt - нет формата для собственных бар-кодов.".
  end.
  if partype-bc = "" then do:
    assign
      partype-bc = " код".
  end.
  if length (parstr-code) < 10 or
     length (parstr-code) = 10 and
     parstr-code <= "2147483647" then do:
    /* исходная строка влезает в integer - пробуем его искать как локальный код;
       ищем в другом буфере, т.к. нам нужен на выходе {&bar-code} с основным едизмом */
    find first bf_bar-code where bf_bar-code.b-code = integer (parstr-code) no-lock no-error.
    if available bf_bar-code and bf_bar-code.stts_ = 0 then do:
      assign
       parresult  = "bar-code"
       partype-bc = "Собственный" + partype-bc + " с коэффициентом " + string (bf_bar-code.cli-base-rate).
    end.
  end.
end.
if available bf_bar-code
and bf_bar-code.stts_ = integer({&hn-delete}) then do:
  assign
  parresult  = "error"
  partype-bc = "БАР-КОД ПОМЕЧЕН К УДАЛЕНИЮ".
  release bf_prod-bc.
  release bf_bar-code.
  return.
end.
/* Складские места */
if not available bf_bar-code then do:
  run gbl/conf-rd.p ("pl-frmt", "", "", 0, "", "", "", no, output varpl-frmt, output varpar-type) no-error.
  if not error-status:error and
     varpar-type = "C":U and
     lookup (varpl-frmt, "EAN8,EAN13") > 0 then do:
    /* формат из настроек прочитан */
    if length (parstr-code) = 13 and
       varpl-frmt = "EAN13" or
       length (parstr-code) = 8 and
       varpl-frmt = "EAN8" then do:
      /* формат знакомый */
      run gbl/conf-rd.p ("pl-pfx", "", "", 0, "", "", "", no, output varpl-pfx, output varpar-type) no-error.
      if not error-status:error and
         varpar-type = "C":U then do:
        /* префикс из настроек прочитан */
        if substr (parstr-code, 1, length (varpl-pfx)) = varpl-pfx then do:
          /* префиксы совпадают - это бар-код складского места - вырезаем локальный код */
          assign
            parstr-code = substr (parstr-code, length (varpl-pfx) + 1, length (parstr-code) - length (varpl-pfx) - 1).
        end.
      end.
    end.
  end.
  if length (parstr-code) < 10 or
     length (parstr-code) = 10 and
     parstr-code <= "2147483647" then do:
    /* исходная строка влезает в integer - пробуем его искать как локальный код */
    find first bf_place where
      bf_place.obj-type = parobj-type and
      bf_place.obj-code = parobj-code and
      bf_place.pl-code  = integer (parstr-code) no-lock no-error.
    if available bf_place then do:
      assign
        varrid     = recid(bf_place)
        partype-bc = "Складское место"
        parresult  = "place"
        .
    end.
  end.
end.
if not available bf_bar-code and
   not available bf_place    then do:
   assign
     varsrc-gen-int = integer (parstr-code) no-error.
   if not error-status:error then do:
      { str/bc-gnrti.i varbc varsrc-gen-int varstr-gen no-message }
      if varstr-gen <> "" then do:
         find first bf_prod-bc where
                    bf_prod-bc.b-str = varstr-gen and
                    bf_prod-bc.bc-on = yes     no-lock no-error.
         if available bf_prod-bc then do:
            find first bf_bar-code where bf_bar-code.b-code = bf_prod-bc.b-code no-lock.
            assign
              varrid     = recid(bf_prod-bc)
              parresult  = "prod-bc"
              partype-bc = "Перегенеренный код в " + varstr-gen.
              .
         end.
      end.
   end.
end.
IF not available bf_bar-code and
   not available bf_place    then do:
  assign
   parresult  = "error"
   partype-bc = "ОШИБКА РАЗБОРА КОДА".
end.

end procedure.