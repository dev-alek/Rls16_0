/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Различные функции для получения информации о партиях

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-parts-part-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-alcohol-prod AS LOGICAL
  ) :

  define variable v-show-part-code as character no-undo .

  if (p-goods-alcohol-prod = false) and (buf_parts.part-code = '':u)
  then do:
    return '------':u .
  end.

  run partsfnc_get-parts-show-code in this-procedure
    (input  buf_parts.part-code
    ,input  buf_parts.mark-db-num
    ,input  buf_parts.mark-code
    ,input  buf_parts.alc-bottling-date
    ,input  p-goods-alcohol-prod
    ,output v-show-part-code
    ) .

  return v-show-part-code .

END FUNCTION.

procedure partsfnc_get-parts-show-code :

  define input  parameter p-part-code          as character no-undo .
  define input  parameter p-mark-db-num        as integer   no-undo .
  define input  parameter p-mark-code          as integer   no-undo .
  define input  parameter p-alc-bottling-date  as date      no-undo .
  define input  parameter p-goods-alcohol-prod as logical   no-undo .
  define output parameter p-show-code          as character no-undo .

  define variable v-alc-mark-name as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-show-code = '':u
    .

    if p-goods-alcohol-prod = true
    then do:
      run alc-lib_mark-name in this-procedure
        (input  p-mark-db-num
        ,input  p-mark-code
        ,output v-alc-mark-name
        ) .
      assign
        p-show-code = substitute('&1,&2':u
                                ,v-alc-mark-name
                                ,string(p-alc-bottling-date,'99/99/9999':u)
                                )
      .
    end.
    else do:
      assign
        p-show-code = p-part-code
      .
    end.

    return '':u .

  end.

end procedure. /* partsfnc_get-parts-show-code */


FUNCTION get-parts-out-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts ) :

  case buf_parts.out-code :
    when {&free-code} then do:
      return "свободно" .
    end.
    when {&output-code} then do:
      return "расход" .
    end.
    otherwise do:
      if buf_parts.doc-type = {&act-overvalue} then do:
        return caps("ЦН") + " № " + buf_parts.out-code .
      end.
      else do:
        define variable v-ext-name       as character no-undo .
        define variable v-trn-doc-status as character no-undo .

        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if available buf_trn-doc then do:
          { gbl/docextnm.i
            buf_parts.out-code
            v-ext-name
          }
          assign
            v-trn-doc-status = (if buf_trn-doc.status_ = {&fact} then {&fact} else "")
          .
        end.
        else do:
          assign
            v-ext-name       = caps(substring(buf_parts.doc-type, 1, 1))
            v-trn-doc-status = (if buf_parts.status_ = ? then {&fact} else "")
          .
        end.
        return substitute("&1 № &2 &3"
           ,v-ext-name
           ,buf_parts.out-code
           ,v-trn-doc-status
           ) .
      end.
    end.
  end case .

  return "".

END FUNCTION.


FUNCTION get-parts-cli-qnty RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :

  if p-goods-twounit then do:
    RETURN buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-base-rate .
  end.

  RETURN ? .

END FUNCTION.

FUNCTION get-parts-cli-base-rate RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :

  if p-goods-twounit then do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.cli-base-rate .
  end.

  RETURN ? .

END FUNCTION.

/* $Workfile$ e n d */