/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

main для журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "sj-adv.price" &then
  &if "{4}" = "-t" &then
&scoped-define   line-length-full 230
&scoped-define   line-length-base 196
  &else
&scoped-define   line-length-full 196
&scoped-define   line-length-base 136
  &endif

&else
  &if "{4}" = "-t" &then
&scoped-define   line-length-full 230
&scoped-define   line-length-base 196
  &else
&scoped-define   line-length-full 196
&scoped-define   line-length-base 196
  &endif
&endif



/*здесь заполним поле всевдо названия группы для sj-goods и sj-tots*/
define variable ii-name as integer no-undo .

for each sj-grp
by sj-grp.grp-name:
  ii-name = ii-name + 1.
  assign
  sj-grp.grp-code-alpha  = ii-name
  .
end.

for each sj-goods
break
by sj-goods.grp-code:
  if first-of(sj-goods.grp-code) then do:
    find first sj-grp no-lock where
              sj-grp.grp-code = sj-goods.grp-code.
    assign
    ii-name = sj-grp.grp-code-alpha.
  end.
  assign
  sj-goods.grp-name = ii-name
  .
end.

for each sj-tots
break
by sj-tots.grp-code:
  if first-of(sj-tots.grp-code) then do:
    find first sj-grp no-lock where
              sj-grp.grp-code = sj-tots.grp-code.
    assign
    ii-name = sj-grp.grp-code-alpha.
  end.
  assign
  sj-tots.grp-name = ii-name
  .
end.

PUT STREAM PrnLibStream
SPACE(25) ( caps( ReportNAme ) + "  " + str1) format "x(110)" SKIP(1)
space(50) "(Без детализации по скидке)" format "x(30)" skip(0)
space(35) ( if NotInc
            then "( по ВСЕМ ЧЕКАМ, в т.ч. невошедшим в отчеты о продажах )"
            else " " ) format "x(80)" skip
SPACE(35) "По объектам : " format "x(15)" .
FOR EACH obj-list :
    FIND FIRST cli-obj WHERE
               cli-obj.obj-type = obj-list.obj-type AND
               cli-obj.obj-code = obj-list.obj-code NO-LOCK .
    PUT STREAM PrnLibStream cli-obj.obj-name format "x(80)" skip space(50) .
    ACCUMULATE ( obj-list.obj-type + string( obj-list.obj-code ) ) ( COUNT ) .
END.
ObjsQnty = ACCUM COUNT ( obj-list.obj-type + string( obj-list.obj-code ) ) .
if ObjsQnty > 1 AND (grouptot_flag OR prodtot_flag)
then AllObjsTotalsBy = yes.
if X-SelectGood = {&g-prod} then do:
    PUT STREAM PrnLibStream  "По производителям: " skip space(50) .
    FOR EACH g#cli :
        FIND FIRST cli-obj WHERE
                    cli-obj.obj-type = g#cli.obj-type AND
                    cli-obj.obj-code = g#cli.obj-code NO-LOCK .
        PUT STREAM PrnLibStream  cli-obj.obj-name format "x(80)" skip space(50) .
    END.
end.
/*if X-SelectGood = {&g-choice} then do:
    counter = 0.
    PUT STREAM PrnLibStream  "По списку товаров: " skip space(10) .
    FOR EACH gds-list :
        message '*' view-as alert-box.
        PUT STREAM PrnLibStream  unformatted
        substitute("&1 &2 &3&4&5"
                   , gds-list.gds-code
                   , gds-list.artic
                   , gds-list.prod-type
                   , gds-list.prod-code
                   , fill( {&space-char}, 10 )
                   )
        .
        counter = counter + 1.
        if counter = 3 then do:
          PUT STREAM PrnLibStream  unformatted skip.
          counter = 0.
        end.
    END.
end.*/
PUT STREAM PrnLibStream
 " " skip
SPACE(5) cash_string format "x(115)" SKIP
SPACE(5) sale_string format "x(115)" SKIP
space(62) string( (if shrs-seller-cashier = "seller"
                   then "Итоги по продавцам      :  "
                   else "Итоги по кассирам       :  " )
                   +
                 ( if SHBySalers then "ДА." else "НЕТ." ) ) format "x(65)" skip
SPACE(5) string( string("Классификация: " + Rs-by-str , "x(57)" ) +
                            "Сортировка              :  " +   ( if SHRs-by = 2 OR SHRS-by = 0
                                                                            then "НЕТ."
                                                                            else rs-sort-str)
                            ) format "x(125)" skip(1) .
if v-curr-r-b = {&r-b-base} then do:
  if my-Set_Val_Type = {&v-all} then
  FORM HEADER
  line {&line-format-full}
  AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(35)" AT 30 SKIP
  with FRAME BottomFramebase{2}{4} width  {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW STREAM PrnLibStream FRAME BottomFramebase{2}{4} .
end.
else do:
  FORM HEADER
  line {&line-format-base}
  AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(35)" AT 30 SKIP
  with FRAME BottomFramerubl{2}{4} width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW STREAM PrnLibStream FRAME BottomFramerubl{2}{4} .
end.

CASE my-Set_Val_Type :
  when {&v-base} then
      FORM with FRAME {2}{4} .
  when {&v-all} then
      FORM with FRAME {3}{4} .
END CASE .

assign
p-frame-width = frame {2}{4}:width.


CASE SHRS-by :
    when 1 OR when 0 then do: /*без класс или без товаров*/
&if "{1}" = "sj-adv.discnt" &then
&if "{4}" = "-t" &then
      RUN SimpleProc_d-t in this-procedure .
&else
      RUN SimpleProc_d in this-procedure .
&endif
&else
&if "{4}" = "-t" &then
      RUN SimpleProc-t in this-procedure .
&else
      RUN SimpleProc in this-procedure .
&endif
&endif
    end.
    when 3 then do:
&if "{1}" = "sj-adv.discnt" &then
&if "{4}" = "-t" &then
      RUN ProdGrpProc_d-t in this-procedure .
&else
      RUN ProdGrpProc_d in this-procedure .
&endif
&else
&if "{4}" = "-t" &then
      RUN ProdGrpProc-t in this-procedure .
&else
     RUN ProdGrpProc in this-procedure .
&endif
&endif
    end.
    when 2 then do:
      if SHRs-Sort = "Article":U then do:
        FOR EACH sj-goods NO-LOCK ,
            EACH sj-adv No-LOCK WHERE
                  sj-adv.obj-attr = sj-goods.obj-attr AND
                  sj-adv.b-code = sj-goods.b-code AND
                  sj-adv.saleman-chr = sj-goods.saleman-chr
            BREAK
            BY sj-goods.obj-attr
            BY sj-goods.grp-name
            BY sj-goods.prod-name
            BY sj-goods.saleman-chr
            BY sj-goods.artic
            BY sj-goods.b-code
            BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
            BY sj-adv.discnt
  &endif
    :
      { rep/e-sjobs.i {2} {3} {4}}
      if first-of( sj-goods.grp-name  ) then do:
        if v-curr-r-b = {&r-b-base} then do:
          if my-Set_Val_Type = {&v-base} then do:
            if frame {2}{4}:line = 0 then do:
              down 1 stream PrnLibStream
              with frame {2}{4}.
            end.
          end.
          else do:
            if frame {3}{4}:line = 0 then do:
              down 1 stream PrnLibStream
              with frame {3}{4}.
            end.
          end.
          PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          if my-Set_Val_Type = {&v-base} then do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME {2}{4} .
          end.
          else do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME {3}{4} .
          end.
        end. /*if v-curr-r-b = {&r-b-base} then do:*/
        else do:
          if frame {2}{4}:line = 0 then do:
            down 1 stream PrnLibStream
            with frame {2}{4}.
          end.
          PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME {2}{4} .
        end.
      end.
      if first-of( sj-goods.prod-name ) then do:
        if prodtot_flag or NOT SHOnly_tot then do:
            if v-curr-r-b = {&r-b-base} then do:
              if my-Set_Val_Type = {&v-base} then do:
                if frame {2}{4}:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame {2}{4}.
                end.
              end.
              else do:
                if frame {3}{4}:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame {3}{4}.
                end.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              if my-Set_Val_Type = {&v-base} then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME {2}{4} .
              end.
              else do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME {3}{4} .
              end.
            end. /*if v-curr-r-b = {&r-b-base} then do:*/
            else do:
              if frame {2}{4}:line = 0 then do:
                down 1 stream PrnLibStream
                with frame {2}{4}.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME {2}{4} .
            end.
          end. /*if prodtot_flag or NOT SHOnly_tot then do:*/
        end. /*if first-of( sj-goods.prod-name ) then do:*/
        { rep/e-sjprod.i sj-goods.grp-name sj-goods.prod-name grouptot_flag prodtot_flag {1} {2} {3} {4}}
      END . /**FOR EACH sj-goods NO-LOCK */
    end. /*if SHRs-Sort = "Article":U then do:*/
    else do:
      FOR EACH sj-goods NO-LOCK,
          EACH sj-adv NO-LOCK WHERE
                sj-adv.obj-attr = sj-goods.obj-attr AND
                sj-adv.b-code = sj-goods.b-code AND
                sj-adv.saleman-chr = sj-goods.saleman-chr
          BREAK
          BY sj-goods.obj-attr
          BY sj-goods.grp-name
          BY sj-goods.prod-name
          BY sj-goods.saleman-chr
          BY sj-goods.b-code
          BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
          BY sj-adv.discnt
&endif
      :
        { rep/e-sjobs.i {2} {3} {4}}
        if first-of( sj-goods.grp-name  ) then do:
          if v-curr-r-b = {&r-b-base} then do:
            if my-Set_Val_Type = {&v-base} then do:
              if frame {2}{4}:line = 0 then do:
                down 1 stream PrnLibStream
                with frame {2}{4}.
              end.
            end.
            else do:
              if frame {3}{4}:line = 0 then do:
                down 1 stream PrnLibStream
                with frame {3}{4}.
              end.
            end.
            PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
            if my-Set_Val_Type = {&v-base} then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME {2}{4} .
            end.
            else do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME {3}{4} .
            end.
          end. /*if my-Set_Val_Type = {&v-base} then do:*/
          else do:
            if frame {2}{4}:line = 0 then do:
              down 1 stream PrnLibStream
              with frame {2}{4}.
            end.
            PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME {2}{4} .
          end.
        end.
        if first-of( sj-goods.prod-name ) then do:
          if prodtot_flag OR NOT SHOnly_tot then do:
            if v-curr-r-b = {&r-b-base} then do:
              if my-Set_Val_Type = {&v-base} then do:
                if frame {2}{4}:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame {2}{4}.
                end.
              end.
              else do:
                if frame {3}{4}:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame {3}{4}.
                end.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              if my-Set_Val_Type = {&v-base} then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME {2}{4} .
              end.
              else do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME {3}{4} .
              end.
            end.
            else do:
              if frame {2}{4}:line = 0 then do:
                down 1 stream PrnLibStream
                with frame {2}{4}.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME {2}{4} .
            end.
          end.
        end.
        { rep/e-sjprod.i sj-goods.grp-name sj-goods.prod-name grouptot_flag prodtot_flag {1} {2} {3} {4}}
      END . /*FOR EACH sj-goods NO-LOCK,*/
    end. /*else if SHRs-Sort = "Article":U then do:*/
  end. /*when 2*/
END CASE .

HIDE STREAM PrnLibStream FRAME BottomFrame{2}{4} .
if Print-List-hist
and x-SelectGood = {&g-choice} then do:
  run lhistprex-print-gds-list-hist-excel  in this-procedure (input yes, input no, 2).
end.


/* $Workfile$ e n d */