 
/*------------------------------------------------------------------------
   File        : RequestDictOrg
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : Eshklyar
   Created     : Wed Nov 11 14:29:45 MSK 2015
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.

class ibs.th.bge.egais.Journal inherits ibs.th.bge.egais.EGAISImpl:
{cmp/str-glbl.i class}
/*{ gbl/curdbnum.i class}*/

  define public variable tth_journal-egais as handle no-undo.
  define public variable bh_journal-egais as handle no-undo.
  
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  
  define variable        v-subject        as character no-undo.
  define variable        v-status         as character no-undo.
  define variable        v-db-num         as integer   no-undo.
  define variable        v-user           as character no-undo.
  
  define temp-table tt_journal-egais no-undo
    field jou-who     as character LABEL "Кто отправил"       format "X(30)" 
    field jou-time    as datetime  LABEL "Во сколько"         FORMAT "99.99.99 HH:MM" 
    field jou-subject as character LABEL "Какой запрос"       format "X(25)"
    field jou-status  as character LABEL "Состояние запроса"  format "X(20)"
    field jou-param   as character LABEL "Параметр"           format "X(30)"
    field jou-code    as character LABEL "Код запроса"        format "X(38)"
    field piIndex     as character
    index tt_journal-egais is primary jou-code ascending.
  
  method public override handle GetHndlTable( ):
    
/*        ub.esys-all-attr.table-name = "esys-pck-sent"    */
/*        ub.esys-all-attr.attr-code  = "egais"            */
/*        ub.esys-all-attr.attr-value = inParameters       */
/*        ub.esys-all-attr.key1       = buf_ext-sys.esys-id*/
/*        ub.esys-all-attr.key2       = inSubject          */
/*        ub.esys-all-attr.key3       = string (inSts)     */
/*        ub.esys-all-attr.key4       = string (now)       */
/*        ub.esys-all-attr.key5       = DbNum              */
/*        ub.esys-all-attr.key7       = inReplyId          */
/*        ub.esys-all-attr.key8       = User_Id            */
  

  for each buf_esys-all-attr where buf_esys-all-attr.table-name = "esys-pck-sent"
                               and buf_esys-all-attr.attr-code  = "egais" no-lock:
    
    create tt_journal-egais.
        v-subject = "Some".
        if buf_esys-all-attr.key2 = integer({&EGAIS-DictOrg}) then do:
          v-subject = {&EGAIS-DictOrg-full}.
        end.  
        if buf_esys-all-attr.key2 = integer({&EGAIS-DictGds}) then do:
          v-subject = {&EGAIS-DictGds-full}.
        end.
        if buf_esys-all-attr.key2 = integer({&EGAIS-InfoVer}) then do:
          v-subject = {&EGAIS-InfoVer-full}.
        end.
        /*if buf_esys-all-attr.key2 = integer({&EGAIS-FormF1}) then do:
          v-subject = {&EGAIS-FormF1-full}.
        end.*/
        if buf_esys-all-attr.key2 = 7 then do:
          v-subject = 'Справочник справок 1'.
        end.
        
        if buf_esys-all-attr.key3 = "no" then v-status = "Запрос отправлен".
        else v-status = "Ответ получен".
        
        if buf_esys-all-attr.key8 <> "" then do:
          find first ub.user-account where ub.user-account.user-id = buf_esys-all-attr.key8 no-error.
          v-user = ub.user-account.last-name + ' ' + ub.user-account.first-name + ' ' + ub.user-account.second-name .
        end.
    assign
      tt_journal-egais.jou-who = v-user
      tt_journal-egais.jou-code = buf_esys-all-attr.key7
      tt_journal-egais.jou-time = datetime (buf_esys-all-attr.key4)
/*        tt_journal-egais.jou-time = ub.esys-all-attr.key4*/
      tt_journal-egais.jou-subject = v-subject
      tt_journal-egais.jou-status = v-status
      tt_journal-egais.jou-param = replace(buf_esys-all-attr.attr-value,{&delim-par},'|')
      tt_journal-egais.piIndex = table-name + string (key1) + string (key2) + string (key3) + string (key4) + string (key5) + string (key6) +
        string (key7) + string (key8) + attr-code.
       .
   end. 
    
    return buffer tt_journal-egais:handle.
    
  end.


end class.