/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Последний приход по группе

Автор: Чернова Светлана Александровна
Дата создания: 02/20/06
Author: Svetlana Chernova
Creation date: 02/20/06

*/
/* define temp-table x_obj-group no-undo like ub.clients .  */
{ cmp/str-glbl.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/* Последняя цена по Приходу по S */
procedure last-incom-S :

define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .
define output parameter p-in-code   as character no-undo .
define output parameter p-obj-type  as character no-undo .
define output parameter p-obj-code  as integer   no-undo .

  do
  on error undo, return error return-value
  :
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_gds-obj for ub.gds-obj  .

  do
  on error undo, return error
  :
    assign
      p-in-code  = ""
      p-obj-type = ""
      p-obj-code = 0
    .
     for each x_obj-group ,
      each buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = x_obj-group.obj-type
        and buf_gds-obj.obj-code  = x_obj-group.obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_gds-obj.in-code
        and buf_trn-doc.status_  = {&fact}
    on error undo, return error
    by buf_trn-doc.fact-order descending
    :
      assign
        p-in-code  = buf_gds-obj.in-code
        p-obj-type = buf_gds-obj.obj-type
        p-obj-code = buf_gds-obj.obj-code
      .

      leave . /* --->>>--- */
    end.
  end.

  end.

end procedure. /* last-incom-S */

procedure main-road-tax :
def input param p-obj-type  like ub.gds-obj.obj-type  no-undo .
def input param p-obj-code  like ub.gds-obj.obj-code  no-undo .
def input param p-artic     like ub.gds-obj.artic     no-undo .
def input param p-prod-type like ub.gds-obj.prod-type no-undo .
def input param p-prod-code like ub.gds-obj.prod-code no-undo .
def input-output param p-road-tax-base as decimal no-undo .
def input-output param p-road-tax-rubl as decimal no-undo .

define buffer     buff-goods    for ub.goods   .
define buffer     buf_gds-obj   for ub.gds-obj .
define buffer     buf_parts     for ub.parts   .

{ str/in-vatp.i  def }

define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .

define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable v-last-in-code  like ub.gds-obj.in-code  no-undo .
define variable v-last-obj-type like ub.gds-obj.obj-type no-undo .
define variable v-last-obj-code like ub.gds-obj.obj-code no-undo .

def var v-rec as recid no-undo.
def var t-ret as logical no-undo .
def var v-total-avrg-base as decimal no-undo .
def var v-total-avrg-rubl as decimal no-undo .
def var v-total-avrg-qnty as decimal no-undo .
def var v-total-road-tax-base     as decimal no-undo .
def var v-total-road-tax-rubl     as decimal no-undo .
def var v-all-total-road-tax-base as decimal no-undo .
def var v-all-total-road-tax-rubl as decimal no-undo .

assign
  p-road-tax-base = ?
  p-road-tax-rubl = ?
  .

  Find first buff-goods no-lock where
        buff-goods.artic     = p-artic and
        buff-goods.prod-type = p-prod-type and
        buff-goods.prod-code = p-prod-code
        no-error .

/* Проверочка наличия Третьего налога */

      if available buff-goods then do:
           v-rec = recid (buff-goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
          { str/is-petrl.i
            p-artic
            p-prod-type
            p-prod-code
            is-petrolium
            is-pieces
            }
           t-ret =  session:SET-WAIT-STATE("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
              assign
                p-road-tax-base = ?
                p-road-tax-rubl = ?
                .
              return.
           end.
      end.

      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .

      /*
        возвращается средняя учетная цена положительных партий свободной зоны по объекту
        не учитываются партии зарезервированные за незакрытыми документами
      */
      for each x_obj-group,
         each buf_parts no-lock
        where buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = {&free-code}  /* только партии свободной зоны */
          and buf_parts.qnty      > 0             /* только положительные партии  */
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
         { str/in-vatp.i calc-parts buf_parts. buf_td. g }

        assign
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
        /* message
          'lastincs.i'  skip
          'road-tax-rubl-loc'    road-tax-rubl-loc   skip
         'buf_parts.fact-qnty'  buf_parts.fact-qnty skip
          'v-total-avrg-qnty'     v-total-avrg-qnty

          .*/
      end.

          if v-total-avrg-qnty > 0 then  DO :
              assign
                p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
                p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
                .
          end.

            if v-total-avrg-qnty <= 0 then do :
                run last-incom-S in this-procedure
                ( input   p-artic ,
                  input   p-prod-type,
                  input   p-prod-code ,
                  output  v-last-in-code,
                  output  v-last-obj-type,
                  output  v-last-obj-code ).

                      /* состав последнего прихода */
                      find buf_trn-doc where buf_trn-doc.doc-code  = v-last-in-code no-lock no-error .
                      find buf_doc-line where     buf_doc-line.doc-code  = v-last-in-code
                                      and buf_doc-line.artic     = p-artic
                                      and buf_doc-line.prod-type = p-prod-type
                                      and buf_doc-line.prod-code = p-prod-code no-lock no-error.
                      if avail buf_doc-line then do :
                      { str/in-vatp.i calc buf_doc-line. buf_trn-doc. g }

                      Assign
                          p-road-tax-rubl =  road-tax-rubl-loc
                          p-road-tax-base =  road-tax-base-loc
                          .
                      end.
    end.
end procedure. /* main-road-tax */