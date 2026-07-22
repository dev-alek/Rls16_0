 
 /*------------------------------------------------------------------------
    File        : code_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Mon Jul 29 01:23:14 MSK 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.code.code_trg final: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   { cmp/library.i  class}
   { cmp/str-glbl.i class }
   define temp-table tt-query no-undo
      field NameQuery as character 
      field hQuery    as handle
  index NameQuery NameQuery.
  
  define temp-table tt-SaveParam no-undo
      field LevelSave   as integer  
      field MaxLevel    as integer
      field chek-erpRN  as logical 
  index LevelSave LevelSave.
  
  define temp-table tt-form no-undo
      field f-level    as integer  
      field f-numfield as integer 
      field f-brwname  as character
      field f-SetLevel as integer
  index indForm f-level f-numfield .
  
  define temp-table tt-menu no-undo
      field f-num    as integer  
      field f-lable  as character 
      field f-list   as character 
  index f-num f-num .
  
  define temp-table tt-code-brw no-undo like code 
    field Frecid as int64 init ?
    field fstatus as character
    field fchange as logical  
    .
    
  define temp-table tt-code-frm no-undo like code 
    field Frecid as int64 init ?.
  
  {gbl/tmprecid.i }
  
  define variable v-code-brw as class ibs.th.ref.code.browsecode no-undo .
  
  define public variable parent as character no-undo.
  define public variable menuHandle as handle no-undo.
  define public variable title  as character no-undo init ?.
  define public variable startlevel as integer no-undo.
  define public variable mViewdel as logical no-undo.
  define public variable filter   as character no-undo.
  define public variable nwsGbd   as logical no-undo.
  define public variable nwsUbd   as logical no-undo.
  define public variable extProcView as logical no-undo .
  
  define property curLevel as integer no-undo
  get:
      return if parent eq "" then 0 else num-entries(parent,{&delim-par}).
  end.
  
  define public property MaxLevel as integer  no-undo
  get. 
  set(arg as int):
     saveMaxLevel().
     MaxLevel = arg.
  end.
  
  define public property isForm as logical  no-undo
  get:
     return valid-object (v-code-brw).
  end. 
  
  method  public void saveMaxLevel ():
     if not isForm  then return.
     define variable vcurLevel as integer no-undo.
     vcurLevel = curLevel.
     find first tt-SaveParam where tt-SaveParam.LevelSave eq vcurLevel no-lock no-error.
     if not available tt-SaveParam
     then do:
        create tt-SaveParam.
        tt-SaveParam.LevelSave = vcurLevel.
     end.
     tt-SaveParam.MaxLevel = MaxLevel.
     
  end.
  
  method  public void clearParam ():
     define variable vcurLevel as integer no-undo.
     vcurLevel = curLevel.
     find first tt-SaveParam where tt-SaveParam.LevelSave eq vcurLevel no-lock no-error.
     if available tt-SaveParam
     then do:
        MaxLevel   = tt-SaveParam.MaxLevel.
        chek-erpRN = tt-SaveParam.chek-erpRN.
     end.
     for each tt-SaveParam where tt-SaveParam.LevelSave ge vcurLevel:
        delete tt-SaveParam.
     end.
     for each tt-form where tt-form.f-SetLevel ge vcurLevel:
        delete tt-form.
     end.
     
  end.
  
  define property endLevel as logical no-undo
  get:
      return MaxLevel ne 0 and num-entries(parent,{&delim-par})  eq  MaxLevel  .
  end. 
   
  
  define property chek-erpRN as logical no-undo
   get. 
   set(arg as logical):
     saveChekErpRN().
     chek-erpRN = arg.
  end.
  define property isVisibleStatus as logical no-undo init true
  get.
  set.
  
  method  public void saveChekErpRN ():
     if not isForm  then return.
     define variable vcurLevel as integer no-undo.
     vcurLevel = curLevel.
     find first tt-SaveParam where tt-SaveParam.LevelSave eq vcurLevel no-lock no-error.
     if not available tt-SaveParam
     then do:
        create tt-SaveParam.
        tt-SaveParam.LevelSave = vcurLevel.
     end.
     tt-SaveParam.chek-erpRN = chek-erpRN.
     
  end.
   
  define property Mode as character  no-undo
   get. 
   set.
  
  define variable mode-erprn as logical no-undo init ?.
  method  public logical get1CERP(): 
       define variable conf-par as character no-undo.
       
       define variable par-type as character no-undo.
/*       run gbl/inidebug.p.*/
       if mode-erprn eq ?
       then do:
          { gbl/conf-rd.i
            "'is-erpRN'"
             0
             "''"
             0
             "''"
             "''"
             "''"
             NO
             conf-par
             par-type
             no-error
             }
          
          if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
          else mode-erprn = no.
       end.
       return mode-erprn.
    end.
  define property parparentproc as handle no-undo
    private get.
    set(input iH as handle):
      parparentproc = ih.
    end.

   constructor public code_trg (  ):
      this-object({&update}).
   end constructor.
   
   constructor public code_trg (imode as character   ):
      super ().
      mode = imode.
      if mode eq {&select}
      then
      rid-keep ().
      formLable(0, 1, "Код ").
      formLable(0, 2, "Наименование").
   end constructor.
   
   destructor public code_trg ( ):

   end destructor.
   
   method public void NextLevel ():
      define buffer code for code.
      find first code where recid(code) eq tt-code-brw.Frecid no-lock no-error.
      if available  code 
      then do:
         
         if     code.procview ne ""
            and SearchPFile(code.procview) ne ?
         then do:
            if mode eq {&select}
            then
               rid-keep ().
            extProcView = yes .
            run value( code.procview) (parparentproc, Mode, code.parent , code.code,Code.CodeName) no-error.
            if error-status:error
            then
               message return-value skip
                       error-status:get-message (1) 
               view-as alert-box.
            if mode eq {&select}
            then
               rid-rest ().
         end.
         else do:
            extProcView = no .
            if not endLevel
            then do:
               codeProcViewSet(code.parent,code.code).
               assign
                  parent  = code.parent + {&delim-par} + code.code
                  parent  = left-trim(parent,{&delim-par})
               .
               setFieldBrw(num-entries(Parent,{&delim-par})).
            end.
            getQuery("code").
         end.
      end.
   end.
   
   method public void rid-keep ():
      define buffer buf_tt-code-brw for tt-code-brw.
      for each buf_tt-code-brw:
         find first tmprecid where tmprecid.fTable eq "code"
                               and tmprecid.Frecid eq buf_tt-code-brw.Frecid
         no-error.
         if     available tmprecid
            and not buf_tt-code-brw.fchange
         then
            delete tmprecid.
         else if not available tmprecid
                 and buf_tt-code-brw.fchange
         then do:
            create tmprecid.
            assign
               tmprecid.Frecid = buf_tt-code-brw.Frecid
               tmprecid.fTable = "code"
            .
         end.
      end.
      run gbl/rid-keep.p (input table tmprecid) no-error.
   end.
   
   method public void rid-rest ():
      define buffer buf_tt-code-brw for tt-code-brw.
      run gbl/rid-rest.p (output table tmprecid) no-error.
      for each buf_tt-code-brw:
         find first tmprecid where tmprecid.fTable eq "code"
                               and tmprecid.Frecid eq buf_tt-code-brw.Frecid
         no-error.
      end.
      
   end.
   
   method public logical PrevLevel ():
      if parent ne ""
      then do:
         assign
            entry(num-entries(parent,{&delim-par}),parent,{&delim-par}) = ""
            parent = right-trim(parent,{&delim-par})
          
         .
         
         if num-entries(parent,{&delim-par}) < startlevel
         then do:
            if mode eq {&select}
            then do:
/*               for each tmprecid: */
/*                  delete tmprecid.*/
/*               end.               */
               run gbl/rid-keep.p (input table tmprecid) no-error.
            end.
            return no.
         end.
         else do:
            clearParam(). 
            setFieldBrw(num-entries(Parent,{&delim-par})).  
            getQuery("code").
            return yes.
         end.
      end.
      
   end.
   
   method public void formLable (ilevel as integer, inumfield as integer ,iname as character   ):
       formLableSetLevel ((if isForm then curLevel else 0) + ilevel, inumfield, iname).
   end.
   
   method public void formLableSetLevel (ilevel as integer, inumfield as integer ,iname as character   ):
      find first tt-form where tt-form.f-level    eq ilevel
                           and tt-form.f-numfield eq inumfield 
                           no-error.
      if not available tt-form
      then do:
         
         create tt-form.
         assign
            tt-form.f-level    = ilevel
            tt-form.f-numfield = inumfield
            tt-form.f-brwname  = iname
            tt-form.f-SetLevel = if isForm then curLevel else -1
         . 
         
      end.
      else do:
/*         if iname ne ?     */
/*         then do:          */
/*            delete tt-form.*/
/*                           */
/*         end.              */
/*         else              */
            tt-form.f-brwname  = iname. 
      end.   
   end.
   method public handle getQuery (input iNameQuery as character ) :
        return getQuery(iNameQuery,no).
   end.
   
   method public handle getQuery (input iNameQuery as character,input iNewQuery as logical ) :
        define variable hQuery   as handle  no-undo .
        define variable vCodeQry as handle  no-undo .
        define variable vfirst   as logical no-undo .
        define variable vOpen    as logical no-undo init yes.
        define variable vTblName as character no-undo .
        define variable vOpenStr as character no-undo .
        define variable vSchedId as integer no-undo .
        define variable sortFrase as character no-undo .
        
        define buffer code    for ub.code.
        
        find first tt-Query where tt-Query.NameQuery eq iNameQuery
        no-error.
      if     available tt-Query
         and iNewQuery
      then do:
         delete object tt-Query.hQuery.
         delete tt-Query.
      end.      
      if not available tt-Query
      then 
      do: 
          create query hQuery.
      end.
      else
         hQuery = tt-Query.hQuery.
          
          case iNameQuery:
              when "code"
              then do:
                  for each tt-code-brw:
                     delete tt-code-brw.
                  end.
                  create query vCodeQry.
                  vCodeQry:set-buffers(buffer code:handle).
                  vCodeQry:query-prepare(substitute("for each code where code.parent = &1 &2 and &3",
                                                    quoter(Parent),
                                                    filter,
                                                    if mViewdel then "yes" else "code.status_ <> {&bef-deleted-status-int}", filter)).
                 vCodeQry:query-open().
                 vCodeQry:get-first().
    
                 QRY-BLOCK:
                 repeat while not vCodeQry:query-off-end:
                   create tt-code-brw.
                   buffer-copy code to tt-code-brw.
                   assign
                     tt-code-brw.Frecid = recid (code)
                     tt-code-brw.fstatus = getstatus(Code.status_)
                   .
                   vCodeQry:get-next().
                 end.
                 vCodeQry:query-close().
                 delete object vCodeQry.
                 
                 case entry(1, Parent, {&delim-par}) :
                   when "CashParamHash"
                   then do :
                     if num-entries(Parent, {&delim-par}) = 1
                     then do :
                       sortFrase = "by datetime(tt-code-brw.codeName) desc".
                     end .
                   end .
                   when "XML_UPD"
                   then do :
                     if num-entries(Parent, {&delim-par}) = 2
                     then do :
                       sortFrase = "by datetime(tt-code-brw.code) desc".
                     end .
                   end .
                 end case .
                 
                 hQuery:set-buffers(buffer tt-code-brw:HANDLE). 
                 hQuery:query-prepare("FOR EACH tt-code-brw " + sortFrase).
              end.
              when "currentcode" 
              then do:
                 define buffer buf_code for code.
                 /*hQuery:set-buffers(buffer buf_code:HANDLE). 
                 hQuery:query-prepare("FOR EACH buf_code where (buf_code.parent eq " + quoter(code.parent) +
                                                          " and buf_code.code   eq " + quoter(code.code)  +
                                                          " ) or ( buf_code.parent begins " + quoter(code.parent + {&delim-par} + code.code ) + ")").*/
                 message "FOR EACH buf_code where (buf_code.parent eq " + quoter(code.parent) +
                                                          " and buf_code.code   eq " + quoter(code.code)  +
                                                          " ) or ( buf_code.parent begins " + quoter(code.parent + {&delim-par} + code.code ) + ")"
                 view-as alert-box.
                 
              end.
                                 
          end case.
          if vOpen
          then do:
             hQuery:query-open.

             if vFirst 
             then
                 hQuery:get-first () no-error .
          end.
              
          if not available tt-Query
          then 
          do: 
             create tt-Query.
          
          assign
              tt-Query.NameQuery = iNameQuery
              
              tt-Query.hQuery    = hQuery
          .         
      end.
     /* else
         hQuery = tt-Query.hQuery.*/
               
            
/* 26/VII-2018 не используется       end.*/
     
        return hQuery.
    end.
    method public void  brwcode ():
         
       v-code-brw = new ibs.th.ref.code.browsecode (input mode, input this-object).
       v-code-brw:chek-erpRN = chek-erpRN.
       v-code-brw:Text = if this-object:title eq ? then "Справочники" else this-object:title. 
       setMenu().
       setFieldBrw(num-entries(parent,{&delim-par})).
       wait-for  v-code-brw:ShowDialog() .
       
       delete object v-code-brw.
    end.
    
    method public void codeProcViewSet(iparent as character ,icode as character ):
       if iparent eq ""
       then do:
          if icode eq "CashFunKey"
          then do:
             MaxLevel = MaxLevel + 1.
             formLable(1, 1, "Функция").
             formLable(1, 2, "Наименование").
             formLable(1, 3, "Код функции").
             formLable(1, 4, "   ").
             
          end.
          else if icode eq "CashParamHash"
          then do:
             MaxLevel = MaxLevel + 1.
             formLable(1, 1, "БД").
             formLable(1, 2, "Дата и время").
             formLable(1, 3, "Хеш").
          end.
          else if icode eq "codeerror"
          then do:
             MaxLevel = MaxLevel + 3.
             formLable(1, 1, "Код").
             formLable(1, 2, "Наименование").

             formLable(2, 1, "Код").
             formLable(2, 2, "Наименование").

             formLable(3, 1, "Код").
             formLable(3, 2, "Наименование").
             formLable(3, 3, "Текст").
             formLable(3, 4, "Группировка выгр.").
             formLable(3, 5, "Знач.Выгр.").
               
             
          end.
          else if icode eq "okei-kkt"
          then do:
             formLable(1, 1, "Код ОКЕИ").
             formLable(1, 2, "Код ЕИ ККТ").
             formLable(1, 4, "ПФ ККТ").
             MaxLevel = MaxLevel + 1.
             chek-erpRN = yes.
          end.
          else if icode eq "DTSeasons"
          then do:
             formLable(1, 1, "Код").
             formLable(1, 2, "Наименование на чеке").
             formLable(1, 3, "Код топлива").
             formLable(1, 4, "Альтернативное наименование").
             formLable(1, 5, "НДС в ПЦ").
             formLable(1, 6, "ЕИ в ПЦ").
             MaxLevel = MaxLevel + 1.
          end.
          else if icode eq "FuelCodeInfo"
          then do:
             formLable(1, 1, "Код АСУ АЗК").
             formLable(1, 3, "Эталонный код").
             MaxLevel = MaxLevel + 1.
             chek-erpRN = yes.
             isVisibleStatus = false.
          end.
          else if icode eq "XML_UPD"
          then do:
             MaxLevel = MaxLevel + 2.
             formLable(1, 1,"БД ").

             formLable(2, 1, "Код").
             formLable(2, 3, "Файл").
             formLable(2, 4, "Хеш").
             formLable(2, 5, "Версия метаданных").
             formLable(2, 6, "БД").
             
          end.

          else if icode eq "XML_BACKUP"
          then do:
             MaxLevel = MaxLevel + 2.
             formLable(1, 1,"Код ").
             formLable(1, 3,"Файл").
             formLable(1, 4,"Хеш "). 
             formLable(1, 6, " ").
           
          end.

       end.
    end.
    
    method public void setFieldBrw (ilevel as integer ):
       define variable vi as integer no-undo.
       if not valid-object (v-code-brw)
       then 
          return.
       find first tt-form where tt-form.f-level eq ilevel
       no-error.
       if available tt-form and valid-object (v-code-brw) then
       do vi= 1 to 16:
          find first tt-form where tt-form.f-level eq ilevel
                               and tt-form.f-numfield eq vi
          no-error.
          if available tt-form
          then
             v-code-brw:Visual_Columns(vi,tt-form.f-brwname).
          else
             v-code-brw:Visual_Columns(vi,?).
       end.
       else
          v-code-brw:defColumn().
    end.
    
    method public void addMenu (inum as integer, iLable as character , ilistMenu as character ):
       find first tt-menu where tt-menu.f-num eq inum no-error.
       if not available tt-menu
       then do:
          create tt-menu.
          tt-menu.f-num = inum.
       end.
       assign
          tt-menu.f-lable = iLable
          tt-menu.f-list  = ilistMenu
       .
    end.
    
    method public void delMenu (inum as integer):
       find first tt-menu where tt-menu.f-num eq inum no-error.
       if available tt-menu
       then do:
          delete tt-menu.
          
       end.
      
    end.
    
    method public void setMenu ( ):
       if not valid-handle (menuHandle) then return.
       for each tt-menu no-lock:
          v-code-brw:addMenu(tt-menu.f-num, tt-menu.f-lable, tt-menu.f-list).
       end.
    end.
    
    method private integer  getDbNum ( ):
       find first sys-ctrl.
       return sys-ctrl.db-num.
    end.
    
    method public void histOne ( ):
       define variable v-rid-list as character no-undo.
       
      if avail tt-code-brw then  
      do:
         run ref/ccode.w (
                   tt-code-brw.parent, 
                   tt-code-brw.code,
                   parparentproc,
                   0,
                   "",
                   0,
                   "",
                   "one",
                   ?,
                   "",
                   "" ,
                   getDbNum ( ),
                   ?,
                   input-output v-rid-list ) .
      end.
    end.
    
    method public void histChild ( ):
       define variable v-rid-list as character no-undo.
      if avail tt-code-brw then  
      do:
         run ref/ccode.w (
                   tt-code-brw.parent, 
                   tt-code-brw.code,
                   parparentproc,
                   0,
                   "",
                   0,
                   "",
                   "parentBeg",
                   ?,
                   "",
                   "" ,
                   getDbNum ( ),
                   ?,
                   input-output v-rid-list ) .
      end.
    end.
    
    method public void runMenu (iStr as character ):
       define buffer code for code.
       find first code where recid(code) eq tt-code-brw.Frecid no-lock no-error.
       run value(istr) in menuHandle 
       ((buffer code:handle)) no-error.
       if error-status:error
       then
          message error-status:get-message (1) skip
                  return-value
          view-as alert-box.
    end.
    
    method public void addcode ( ):
       release code.
       create tt-code-frm.
     
       tt-code-frm.parent = parent.
       frmcode({&add-def} , buffer tt-code-frm:handle).
       finally:
          delete tt-code-frm.
       end finally.
    end method.
    
    method public void editcode ( ):
       define buffer code for code.
       find first code where recid(code) eq tt-code-brw.Frecid no-lock no-error.
       if available code 
       then do:
     
          buffer-copy code to tt-code-frm.
          tt-code-frm.Frecid  = recid(code).
          frmcode({&update},buffer tt-code-frm:handle).
       end.
       finally:
          if available tt-code-frm
          then
             delete tt-code-frm.
       end finally.
    end method.
    
    method public void delcode ( ):
       define buffer buf_code for code.
       define buffer code for code.
       find first code where recid(code) eq tt-code-brw.Frecid no-lock no-error.
       if available code 
       then do:
          if SearchPFile(Code.procdel) ne ?
          then 
             run value (Code.procdel) (recid(code)).
          else do:
             find first buf_code where recid(buf_code) eq recid(code)
             exclusive-lock.
             if available buf_code
             then do:
                if buf_code.status_ eq {&bef-deleted-status-int}
                then
                   buf_code.status_ = {&bef-current-status-int}.
                else
                   buf_code.status_ = {&bef-deleted-status-int}.
             end.
          end.
       end.
      
    end method.
    
    method public character  getstatus (iStatus as integer  ):
    define variable vStatus as character no-undo.   
       &glob status-code string(iStatus)
       vStatus = {&status-int-name} no-error.
       return vStatus. 
    
    end method.
    
    method public character  getprocedit(ibuffertt as handle ):
       define variable oProc as character no-undo.
       define variable vparent     as character no-undo.
       define variable vcode       as character no-undo.
       define variable vLastdelim  as integer no-undo.
       define buffer code for code.
       if     ibuffertt::procedit ne ""
          and ibuffertt::procedit ne  ?
       then
          oProc = ibuffertt::procedit.
       
       else do:
         assign
            vLastdelim = r-index(ibuffertt::parent,{&delim-par})
            vparent    = if vLastdelim eq 0 then "" else substring(ibuffertt::parent,1,vLastdelim - 1)
            vcode      = if vLastdelim eq 0 then ibuffertt::parent else substring(ibuffertt::parent,vLastdelim + 1)
         .
         find first code where Code.parent eq vparent
                            and code.code  eq vcode
         no-lock no-error.
         block-code:       
         do while available code and code.code ne "":
            
            if     code.procedit ne ?
               and code.procedit ne ""
            then do:
               oProc = code.procedit.
               leave block-code.
            end.
            assign
               vLastdelim = r-index(Code.parent,{&delim-par})
               vparent    = if vLastdelim eq 0 then "" else substring(Code.parent,1,vLastdelim - 1)
               vcode      = if vLastdelim eq 0 then Code.parent else substring(Code.parent,vLastdelim + 1)
            .
            find first code where Code.parent eq vparent
                               and code.code  eq vcode
            no-lock no-error.
          end.
       end.
       return oProc.  
    end method.   
    
    method public void frmcode (Imode as character ,ibuffertt as handle ):
       define variable VSave as logical no-undo.
       define variable v-code-frm as class ibs.th.ref.code.frmcode no-undo.
       define buffer buf_code for code.
       define variable vproc as character no-undo.
       vproc = getprocedit(ibuffertt).
       if SearchPFile(vproc) ne ?
       then
          run value(vproc) (parparentproc, this-object, Imode  ,ibuffertt,output Vsave ).
       else do:
          v-code-frm = new ibs.th.ref.code.frmcode(ibuffertt,this-object).
          for each tt-form where tt-form.f-level eq num-entries(parent,{&delim-par}):
             v-code-frm:setlable(tt-form.f-numfield, tt-form.f-brwname).
          end.
          wait-for  v-code-frm:ShowDialog() .
          VSave = v-code-frm:DialogResult = System.Windows.Forms.DialogResult:ok.
          delete object v-code-frm.
       end.
       if VSave  
       then do trans:
          if ibuffertt::frecid ne ?
          then
             find first buf_code where recid(buf_code) eq ibuffertt::frecid exclusive-lock.
          buffer-copy tt-code-frm to buf_code
          assign
             buf_code.nwsgbd = nwsGbd when nwsGbd
             buf_code.nwsubd = nwsUbd when nwsUbd 
          .
          if available tt-code-brw
          then
             buffer-copy tt-code-frm to tt-code-brw.
       end.
       
    end method.
    
    method public void checkcode () :
    define buffer buf_code for code.
    find first buf_code where buf_code.parent eq parent
                          and buf_code.code   eq tt-code-frm.code
                          and if tt-code-frm.frecid ne ? then recid(buf_code) ne tt-code-frm.frecid else yes
                          no-lock no-error.
     if available buf_code
     then do:
        message "Уже есть запись с кодом " tt-code-frm.code
        view-as alert-box.
        return error.
     end.
        
  end method. // end_of_checkPromoAction 
  
  method public void CheckCodeInt () :
    define buffer buf_code for code.
    find first buf_code where buf_code.parent eq parent
                          and int(buf_code.code)   eq int(tt-code-frm.code)
                          and if tt-code-frm.frecid ne ? then recid(buf_code) ne tt-code-frm.frecid else yes
                          no-lock no-error.
     if available buf_code
     then do:
        message "Уже есть запись с кодом " tt-code-frm.code
        view-as alert-box.
        return error.
     end.
  end method. // end_of_checkPromoAction 
  
  method public void codeexport (file as character  ):
     define variable vexpot as class ibs.th.bge.xmlimpexp no-undo.
      vexpot = new ibs.th.bge.xmlimpexp().
      /*define variable hQuery as handle no-undo.
      hQuery = this-object:getQuery("currentcode").*/
      define variable hQuery   as handle  no-undo .
      define buffer Buf_code for code.
      
      create query hQuery.
      hQuery:set-buffers(buffer buf_code:HANDLE). 
      /*hQuery:query-prepare("FOR EACH buf_code where (buf_code.parent eq " + quoter(tt-code-brw.parent) +
                                                          " and buf_code.code   eq " + quoter(tt-code-brw.code)  +
                                                          " ) or ( buf_code.parent begins " + quoter((if tt-code-brw.parent eq "" then "" else (tt-code-brw.parent + {&delim-par})) + tt-code-brw.code ) + ")").
      */
      hQuery:query-prepare("FOR EACH buf_code where buf_code.export_ "  
                                                          ).
      hQuery:query-open ().
      
      vexpot:updatetableforxml(hQuery).
      vexpot:xmldom-save  ( file ).
      message "Выгружен файл " file
      view-as alert-box.
      finally:
         delete object vexpot.
        
         delete object hQuery.
      end finally.
     end method. 
     
     method public void codeimport (file as character  ):
       define variable vimport as class ibs.th.bge.xmlimpexp no-undo.
       vimport= new ibs.th.bge.xmlimpexp().
       
       vimport:xmldom-load ( file ).
       vimport:updatetablefordb().
       message "Загрузка завершена."
       view-as alert-box.
       finally:
         delete object vimport.
         
      end finally. 
     end method. 
     
     method public void changeRow(input iAll as logical):
       define variable vFlag as logical no-undo.
       vFlag = if     available tt-code-brw
                  and tt-code-brw.fchange
               then no
               else yes.
       if iAll 
       then
           for each   tt-code-brw:
               tt-code-brw.fchange = vFlag.
           end.
       else
            if avail tt-code-brw
            then
                tt-code-brw.fchange = vFlag.
               
   end.
   {utl/search.i class}
   
end class.