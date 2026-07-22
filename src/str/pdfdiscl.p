block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pdfdiscl.p $
$Archive: str/pdfdiscl.p $

Закрытие связных ДНЦ по атрибутам переоценки

Автор: Чернова Светлана Александровна
Дата создания: 04/28/09
Author: Svetlana Chernova
Creation date: 04/28/09


*/


define input  parameter parParentProc as handle no-undo .
define input  parameter p-doc-code    as character no-undo . /* переоценка */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pdfdiscl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pdfdiscl.p $":U .
define variable vss-description as character no-undo init "Закрытие связных ДНЦ по атрибутам переоценки".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_price-doc         for ub.price-doc  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-attr    for ub.doc-attr  .
define variable v-notall-relation as logical   no-undo .
define variable v-exis            as logical   no-undo .
define variable v-str-err as character no-undo .
define variable v-1 as character no-undo .
define variable v-str as character no-undo .
define variable ii1 as integer   no-undo .
define variable ii2 as integer   no-undo .
define variable ii3 as integer   no-undo .
define variable ii4 as integer   no-undo .
  do
  on error undo, return error return-value
  :
find first buf_price-doc no-lock where
           buf_price-doc.doc-num = p-doc-code no-error .
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
        return error return-value .
    end.
  v-exis  = false .
  for each buf_price-doc-attr no-lock where
           buf_price-doc-attr.attr-code begins {&trdcattr-relprpdf} + {&delim-par} and
           buf_price-doc-attr.doc-code  = p-doc-code :
           v-exis  = true  .
  end.
  if v-exis  = false then return . /* связок нет ======>  */

  v-notall-relation = false .
  v-str-err = "" .
  for each buf_price-doc-attr no-lock where
           buf_price-doc-attr.attr-code begins {&trdcattr-relprpdf} + {&delim-par} and
           buf_price-doc-attr.doc-code  = p-doc-code :

           assign
              ii1 =  int(entry(1,buf_price-doc-attr.attr-value))
              ii2 =  int(entry(2,buf_price-doc-attr.attr-value))
              ii3 =  int(entry(3,buf_price-doc-attr.attr-value))
              ii4 =  int(entry(4,buf_price-doc-attr.attr-value))
            no-error .
            if error-status :error then do:
              message "Неверно заведен атрибут переоценки" view-as alert-box error .
              return error "Неверно заведен атрибут переоценки"  .
            end.

      find first buf_price-doc-forming no-lock  where
                 buf_price-doc-forming.plt-id     = int(entry(1,buf_price-doc-attr.attr-value)) and
                 buf_price-doc-forming.plt-db-num = int(entry(2,buf_price-doc-attr.attr-value)) and
                 buf_price-doc-forming.pdf-id     = int(entry(3,buf_price-doc-attr.attr-value)) and
                 buf_price-doc-forming.pdf-db     = int(entry(4,buf_price-doc-attr.attr-value)) no-error .
         if not available buf_price-doc-forming then do:
            v-notall-relation = true  .
            v-str-err = v-str-err  +  substitute(" &1(&2),",
              entry(3,buf_price-doc-attr.attr-value) ,
              entry(4,buf_price-doc-attr.attr-value)).
         end.
  end.


  if v-notall-relation = true  then do:
    v-str = substitute("Не все скидочные ДНЦ доступны для обработки, нет: &1 " , v-str-err )  .
    message v-str  view-as alert-box information .
    return error v-str /* ======> */.
  end.

  for each buf_price-doc-attr no-lock where
           buf_price-doc-attr.attr-code begins {&trdcattr-relprpdf} + {&delim-par} and
           buf_price-doc-attr.doc-code  = p-doc-code ,
      first buf_price-doc-forming no-lock  where
            buf_price-doc-forming.plt-id     = int(entry(1,buf_price-doc-attr.attr-value)) and
            buf_price-doc-forming.plt-db-num = int(entry(2,buf_price-doc-attr.attr-value)) and
            buf_price-doc-forming.pdf-id     = int(entry(3,buf_price-doc-attr.attr-value)) and
            buf_price-doc-forming.pdf-db     = int(entry(4,buf_price-doc-attr.attr-value))
            :
              run str/diallog.w
                ( parparentproc
                , this-procedure
                , 'str/pdf-clos.p':U
                , ( string(recid(buf_price-doc-forming)) + {&delim-par} +
                  'no' + {&delim-par} +
                  'no' + {&delim-par} +
                  '?'  + {&delim-par} +
                  '?'  + {&delim-par} +
                  string({&fact}) + {&delim-par} +
                  '?'  + {&delim-par} +
                  'yes'  )
                , yes /*p-auto-go*/
                , '':U
                , 'Закрытие порожденных ДНЦ') no-error .
                if error-status :error then do:
                   v-str = substitute("_Закрытие порожденных ДНЦ ошибка &1 &2" , return-value ,  error-status :get-message(1) ) .
                   return error v-str .
                end.
    end.
 end.