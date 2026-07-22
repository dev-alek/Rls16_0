/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции, вовращающие характеристики сущностей (товар группа блюд) связанных с сущностями R-KEEPER

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/08/05
Author: Bakhtadze Natalya
Creation date: 02/08/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable varscales-pref{&vssseq} as character no-undo .
define variable varpgscales-pref{&vssseq} as character no-undo .
define variable varscales-pref-type{&vssseq} as character no-undo.
define variable varpgscales-pref-type{&vssseq} as character no-undo.
varscales-pref{&vssseq}  = ?.
 { gbl/conf-rd.i
    "'sclspref':u"
    "'':u"
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    no
    varscales-pref{&vssseq}
    varscales-pref-type{&vssseq}
    no-error
  }
  if varscales-pref{&vssseq} = ? then do:
    assign
      varscales-pref{&vssseq} = {&scales-pref}.
  end.

varpgscales-pref{&vssseq}  = ?.
 { gbl/conf-rd.i
    "'scpgpref':u"
    "'':u"
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    no
    varpgscales-pref{&vssseq}
    varpgscales-pref-type{&vssseq}
    no-error
  }
  if varpgscales-pref{&vssseq} = ? then do:
    assign
      varpgscales-pref{&vssseq} = {&pgscales-pref}.
  end.





/*-----------------------------------------------------------------------------------------------*/
&if "{1}" <> "short" &then

function get-rkgTH-price returns decimal(input p-obj-type as character
                                       , input p-obj-code as integer
                                       , input p-b-code as integer
                                       , output p-doc-num as character):
define variable v-price-sale as decimal   no-undo init ?.
define variable v-road-tax   as decimal   no-undo .
define variable v-excise     as decimal   no-undo .
define variable v-vat-pc     as decimal   no-undo .
define variable v-slt-pc     as decimal   no-undo .


{ gbl/bcprcex.i p-obj-type p-obj-code p-b-code 0 0 p-doc-num v-price-sale v-road-tax v-excise v-vat-pc v-slt-pc no-error }
if not error-status:error then return v-price-sale.
END FUNCTION.


/*-----------------------------------------------------------------------------------------------*/

function get-rkgTH-name returns character(input p-obj-type as character
                                          ,input p-obj-code as integer
                                          ,input p-b-code as integer
                                          , buffer buf_goods for ub.goods):
define variable v-gds-name as character no-undo .
define VARIABLE varresult   as character                no-undo.
define VARIABLE vartype-bc  as character                no-undo.
define VARIABLE varweight   as decimal                  no-undo.
DEFINE VARIABLE v-unit-cli AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-f-name AS CHARACTER NO-UNDO.

DEFINE BUFFER buf_bar-code FOR ub.bar-code.
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
DEFINE BUFFER buf_place FOR ub.place.
DEFINE BUFFER buf_gds-prt FOR ub.gds-prt.

{ str/bc-rcnz.i
  parparentproc
  STRING(p-b-code)
  0
  p-obj-type
  p-obj-code
  NO
  YES
  varscales-pref{&vssseq}
  varpgscales-pref{&vssseq}
  varresult
  vartype-bc
  varweight
  buf_bar-code
  buf_prod-bc
  buf_place
  no-error
}
if not available buf_bar-code then
return "!!!НЕИЗВЕСТНЫЙ ТОВАР".

FIND FIRST buf_goods NO-LOCK WHERE
          buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.
IF NOT AVAILABLE buf_goods THEN DO:
  return "!!!НЕИЗВЕСТНЫЙ ТОВАР".
END.
else do:
  assign
  v-gds-name = buf_goods.chk-name
  .
end.
IF buf_bar-code.unit-cli <> buf_goods.unit-base THEN DO:
  ASSIGN
  v-unit-cli = "*" + string(buf_bar-code.cli-base-rate).
END.
FIND FIRST buf_gds-prt NO-LOCK WHERE
          buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
if buf_gds-prt.node-name <>  {&empty-scale} THEN DO:
    FIND FIRST buf_gds-prt NO-LOCK WHERE
              buf_gds-prt.node-code = buf_bar-code.node-code NO-ERROR.

END.
ASSIGN
v-f-name = (IF AVAILABLE buf_gds-prt THEN buf_gds-prt.f-name ELSE "":U).
ASSIGN
v-gds-name = v-gds-name + {&space-char} + v-f-name + v-unit-cli.
return v-gds-name.
END FUNCTION.


/*-----------------------------------------------------------------------------------------------*/

function get-rkgTH-group returns integer(input p-obj-type as character
                                        , input p-obj-code  as integer
                                        , input p-gds-code as integer
                                        , output p-grp-name as character
                                        ):
DEFINE BUFFER buf_fbr-gds-obj FOR ub.fbr-gds-obj.
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
FIND FIRST buf_fbr-gds-obj NO-LOCK WHERE
        buf_fbr-gds-obj.obj-type = p-obj-type
    AND buf_fbr-gds-obj.obj-code = p-obj-code
    AND buf_fbr-gds-obj.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_fbr-gds-obj THEN DO:
  RUN fbrglib-get-full-name IN THIS-PROCEDURE(
                                              input p-obj-type
                                              ,INPUT p-obj-code
                                              ,INPUT buf_fbr-gds-obj.fbr-grp-code
                                              ,OUTPUT p-grp-name) NO-ERROR.
  return buf_fbr-gds-obj.fbr-grp-code.
END.
return ?.
END FUNCTION.


function get-rkgTH-modificator returns logical(input p-obj-type as character
                                        , input p-obj-code  as integer
                                        , input p-gds-code as integer
                                        , output p-is-null-price as logical

                                        ):
DEFINE BUFFER buf_fbr-gds-obj FOR ub.fbr-gds-obj.
FIND FIRST buf_fbr-gds-obj NO-LOCK WHERE
        buf_fbr-gds-obj.obj-type = p-obj-type
    AND buf_fbr-gds-obj.obj-code = p-obj-code
    AND buf_fbr-gds-obj.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_fbr-gds-obj THEN DO:
  assign
  p-is-null-price = buf_fbr-gds-obj.is-null-price
  .
  return buf_fbr-gds-obj.is-modificator.
END.
assign
p-is-null-price = no.
return no.
END FUNCTION.



/*-----------------------------------------------------------------------------------------------*/

function get-rkgTH-group-name returns character(input p-obj-type as character
                                              , input p-obj-code  as integer
                                              , input p-out-code as integer):
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
          buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
      and buf_fbr-gds-grp.out-code = p-out-code no-error .
if not available buf_fbr-gds-grp then return ?.
return buf_fbr-gds-grp.node-name.

END FUNCTION.

/*-----------------------------------------------------------------------------------------------*/

function get-rkgTH-parent returns integer(input p-obj-type as character
                                          , input p-obj-code  as integer
                                          , input p-out-code as integer):

DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
DEFINE BUFFER upper_fbr-gds-grp FOR ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
          buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
      and buf_fbr-gds-grp.out-code = p-out-code no-error .
if not available buf_fbr-gds-grp then return ?.
find first upper_fbr-gds-grp no-lock where
          upper_fbr-gds-grp.obj-type = p-obj-type
      AND upper_fbr-gds-grp.obj-code = p-obj-code
      and upper_fbr-gds-grp.out-code = buf_fbr-gds-grp.upper-code no-error .
if not available upper_fbr-gds-grp then return ?.
return upper_fbr-gds-grp.out-code.
END FUNCTION.

&endif

procedure get-rkep-full-grp-name :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER p-grp-code LIKE ub.cd-grp.grp-code NO-UNDO.
define output parameter p-full-name as character    no-undo.

define variable v-upper-code    as integer  no-undo.

define buffer buf_cd-grp       for ub.cd-grp.
define buffer buf_upper_cd-grp for ub.cd-grp.
do
on error undo, return error
:

    if P-grp-code = 0
    then do:        /* Корневая группа */
        assign
            p-full-name = ""
        .
    end.        /* if P-ID = 1 */
    else do:
        find first buf_cd-grp no-lock where
               buf_cd-grp.obj-type = {&shop}
           and buf_cd-grp.obj-code = p-obj-code
           and buf_cd-grp.pos-type = {&cd-type-r-keeper}
           and buf_cd-grp.grp-type = '':U
           and buf_cd-grp.grp-code = p-grp-code
        no-error.
        if not available buf_cd-grp
        then do:
            undo, return error substitute("get-rkep-grp-name: Не найдена группа меню на кассе R-KEEPER с кодом &1", p-grp-code).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 0
        .
        do while true
        on error undo, return error "get-rkep-grp-name: Ошибка составления полного имени группы"
        :
            assign
            p-full-name  = buf_cd-grp.grp-name
                        + (if p-full-name <> "" then {&delim-grp} else "")
                        + p-full-name
            v-upper-code = buf_cd-grp.upper-grp-code
            .
            if buf_cd-grp.grp-code = 0
            then do:
                leave.
            end.
            find first buf_cd-grp no-lock where
                      buf_cd-grp.obj-type = {&shop}
                  and buf_cd-grp.obj-code = p-obj-code
                  and buf_cd-grp.pos-type = {&cd-type-r-keeper}
                  and buf_cd-grp.grp-type = '':U
                  and buf_cd-grp.grp-code = v-upper-code no-error.
            if not available buf_cd-grp
            then do:
                undo, return error "get-rkep-grp-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-id".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else {&delim-grp})
        .
    end.        /* NOT ( if P-ID = 1 ) */
end.

end procedure. /* get-rkep-full-grp-name */

function get-price-id-from-int returns character ( input p-file-num as integer):
  return ({&table_price-list} + {&space-char} +  string(p-file-num)).
end function.


/* $Workfile$ e n d */