block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: im-zaptt.p $
$Archive: utl/im-zaptt.p $

Закачка из файла во временные таблицы

Автор: Чернова Светлана Александровна
Дата создания: 07/16/09
Author: Svetlana Chernova
Creation date: 07/16/09

*/

using Ibs.Th.Gbl.ProgressBar.


define input  parameter parparentproc as handle no-undo .
define input  parameter p-full-name as character no-undo .
define output parameter v-ok as logical   no-undo .
define output parameter p-trn-doc as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: im-zaptt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/im-zaptt.p $":U .
define variable vss-description as character no-undo init "Закачка из файла во временные таблицы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ rep/prg-bar.i def }
{ gbl/xmlchar.i  }
{ str/xmllib.i   }
{ utl/ttzpr.i    }


empty temp-table temp_trn-doc.
empty temp-table temp_doc-line.
v-ok = true  .


define variable v-full-filename as character  no-undo.

define buffer buf_rec-fld      for temp_xmllib_rec-fld.
define buffer buf_rec          for temp_xmllib_rec.
define buffer buf_goods for ub.goods  .


    assign
        v-full-filename   = search( p-full-name )
    .
    if v-full-filename <> ?
    then do:
        run xmllib-clear-parse-data in this-procedure.
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "line-num":U ).
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "doc-date":U ).
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "cli-code":U ).
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "cli-type":U ).
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "obj-code":U ).
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "obj-type":U ).
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "ext-doc-code":U ).
        run xmllib-add-rec-fld in this-procedure ( input "trn-doc":U, input "ps":U ).
        run xmllib-parse-file in this-procedure (
            input v-full-filename
            ) no-error.
        if error-status :error
        then do:
            v-ok = false .
            undo, return error substitute( "Ошибка разбора файла &1 теги trn-doc  &2", v-full-filename , return-value )  .
        end.
        run p-create no-error .
        if error-status :error then do:
            v-ok = false .
            undo, return error substitute( "Ошибка разбора файла &1 теги trn-doc &2", v-full-filename , return-value )  .
        end.

        run xmllib-clear-parse-data in this-procedure.
        run xmllib-add-rec-fld in this-procedure ( input "doc-line":U  , input "ext-doc-code":U ).
        run xmllib-add-rec-fld in this-procedure ( input "doc-line":U  , input "line-num":U   ).
        run xmllib-add-rec-fld in this-procedure ( input "doc-line":U  , input "fact-qnty":U   ).
        run xmllib-add-rec-fld in this-procedure ( input "doc-line":U  , input "price-rubl":U   ).
        run xmllib-add-rec-fld in this-procedure ( input "doc-line":U  , input "gds-code":U   ).
        run xmllib-parse-file in this-procedure (
            input v-full-filename
            ) no-error.
        if error-status :error
        then do:
            v-ok = false .
            undo, return error substitute( "Ошибка разбора файла &1  теги doc-line &2", v-full-filename , return-value )  .
        end.
        run p-create no-error .
        if error-status :error then do:
            v-ok = false .
            undo, return error substitute( "Ошибка разбора файла &1 теги doc-line &2", v-full-filename , return-value )  .
        end.
    end.



for each temp_doc-line :
  if temp_doc-line.line-num = 0 or temp_doc-line.line-num = ? then do:
     v-ok = false .
     undo, return error
     substitute(" В документе нет line-num  в тегах doc-line " ).
  end.
end.



for each temp_trn-doc:
  if temp_trn-doc.line-num = 0 or temp_trn-doc.line-num = ? then do:
     v-ok = false .
     undo, return error
            substitute(" В документе нет line-num  в тегах trn-doc " ).
  end.

  for each temp_doc-line where
           temp_doc-line.line-num = temp_trn-doc.line-num
           :
  if temp_doc-line.gds-code = 0 or temp_doc-line.gds-code = ? then do:
     v-ok = false .
     undo, return error
            substitute(" В документе line-num = &1 тег &2 = &3 не верное значение  &4 &5 " , temp_doc-line.line-num ,
                        "gds-code" , temp_doc-line.gds-code , return-value , error-status :get-message(1)  ) .
  end.
  if temp_doc-line.fact-qnty = 0 or temp_doc-line.fact-qnty = ? then do:
     v-ok = false .
     undo, return error
            substitute(" В документе line-num = &1 тег &2 = &3 не верное значение  &4 &5 " , temp_doc-line.line-num ,
                        "fact-qnty" , temp_doc-line.fact-qnty , return-value , error-status :get-message(1)  ) .
  end.

  if temp_doc-line.price-rubl = 0 or temp_doc-line.price-rubl = ? then do:
     v-ok = false .
     undo, return error
            substitute(" В документе line-num = &1 тег &2 = &3 не верное значение  &4 &5 " , temp_doc-line.line-num ,
                        "price-rubl" , temp_doc-line.price-rubl , return-value , error-status :get-message(1)  ) .
  end.



  find first buf_goods where buf_goods.gds-code  = temp_doc-line.gds-code  no-lock no-error .
  if error-status :error then do:
    v-ok = false .
    undo, return error
    substitute(" В документе line-num &1 тег &2  по нему не найден товар &3 &4 &5 " , temp_doc-line.line-num ,  "gds-code" , temp_doc-line.gds-code , return-value , error-status :get-message(1)  ) .

  end.

      temp_doc-line.artic     = buf_goods.artic .
      temp_doc-line.prod-type = buf_goods.prod-type .
      temp_doc-line.prod-code = buf_goods.prod-code .
      temp_doc-line.price-cli  = temp_doc-line.price-rubl .

  end.
end.

/*
for each temp_trn-doc:
    message temp_trn-doc.line-num skip
            temp_trn-doc.doc-code  skip
            temp_trn-doc.doc-date  skip
            temp_trn-doc.obj-type  skip
            temp_trn-doc.obj-code  skip
            temp_trn-doc.cli-type  skip
            temp_trn-doc.cli-code  skip
            temp_trn-doc.ps  skip
            skip
            'trn-doc'.
end.

for each temp_doc-line:
    message temp_doc-line.line-num  'line-num '  skip
            temp_doc-line.doc-code  'doc-code ' skip
            temp_doc-line.gds-code  'gds-code ' skip
            temp_doc-line.artic     'artic    '  skip
            temp_doc-line.fact-qnty 'fact-qnty    '  skip
            temp_doc-line.price-rubl 'price-rubl    '  skip
            'doc-line'.
end.
*/


run utl/imp-izpr.p (
  input parparentproc ,
  input table temp_trn-doc ,
  input table temp_doc-line ,
  output p-trn-doc
  ) no-error .
  if error-status :error then do:
    v-ok = false .
    undo, return error  substitute("Создание запроса по &1 &2 &3" , temp_trn-doc.doc-code , return-value , error-status :get-message(1)  ) .
  end.
RETURN.



procedure p-create :

  do
  on error undo, return error return-value
  :

        for each buf_rec
        on error undo, return error
        :
            if buf_rec.recName = "trn-doc" then do:
              create temp_trn-doc.
            end.

            if buf_rec.recName = "doc-line" then do:
              create temp_doc-line.
            end.


            for each buf_rec-fld
               where buf_rec-fld.rec-key = buf_rec.rec-key
            on error undo, return error
            :

            if buf_rec.recName = "trn-doc" then do:
               case buf_rec-fld.fldName:
                when "line-num":U then do: temp_trn-doc.line-num = INT(buf_rec-fld.fldValue) .  end.
                when "doc-date":U then do:
                       temp_trn-doc.doc-date = date( int(substring(buf_rec-fld.fldValue,6,2)),int(substring(buf_rec-fld.fldValue,9,2)), int(substring(buf_rec-fld.fldValue,1,4))) no-error  .
                       if error-status :error then do:
                          return error substitute(" Не верно задана дата yyyy-mm-dd  &1" , buf_rec-fld.fldValue ) .
                       end.
                end.
                when "cli-code":U then do: temp_trn-doc.cli-code = int(buf_rec-fld.fldValue) no-error . end.
                when "cli-type":U then do: temp_trn-doc.cli-type = buf_rec-fld.fldValue . end.
                when "obj-code":U then do: temp_trn-doc.obj-code = int(buf_rec-fld.fldValue) no-error  . end.
                when "obj-type":U then do: temp_trn-doc.obj-type = buf_rec-fld.fldValue . end.
                when "ps":U       then do: temp_trn-doc.ps       = buf_rec-fld.fldValue . end.
                when "ext-doc-code":U then do:
                   if buf_rec-fld.fldValue <> "" then do:
                      temp_trn-doc.doc-code = buf_rec-fld.fldValue .
                   end.
                end.
               end case.
            end.
            if buf_rec.recName = "doc-line" then do:
                case buf_rec-fld.fldName:
                  when "line-num":U     then do: temp_doc-line.line-num   = int(buf_rec-fld.fldValue) no-error .
                       if error-status :error then do:
                          return error substitute(" Не верно задан line-num &1" , buf_rec-fld.fldValue ) .
                       end.
                  end.
                  when "fact-qnty":U    then do: temp_doc-line.fact-qnty  = decimal(buf_rec-fld.fldValue) .
                       if error-status :error then do:
                          return error substitute(" Не верно задан fact-qnty &1" , buf_rec-fld.fldValue ) .
                       end.

                  end.
                  when "price-rubl":U   then do: temp_doc-line.price-rubl = decimal(buf_rec-fld.fldValue) .
                       if error-status :error then do:
                          return error substitute(" Не верно задан price-rubl &1" , buf_rec-fld.fldValue ) .
                       end.

                  end.
                  when "gds-code":U     then do: temp_doc-line.gds-code   = int(buf_rec-fld.fldValue) .
                       if error-status :error then do:
                          return error substitute(" Не верно задан gds-code &1" , buf_rec-fld.fldValue ) .
                       end.

                  end.
                  when "ext-doc-code":U then do:
                        temp_doc-line.doc-code   = buf_rec-fld.fldValue .
                       if error-status :error then do:
                          return error substitute(" Не верно задан ext-doc-code &1" , buf_rec-fld.fldValue ) .
                       end.
                  end.
                end case.
            end.
            end.
        end.

  end.

end procedure. /* create-p */