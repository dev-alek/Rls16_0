
/*------------------------------------------------------------------------
    File        : ttCashBook.i
    Purpose     : 

    Syntax      :

    Description : Определение временных таблиц для Типов кассовых книг

    Author(s)   : SSlivenko
    Created     : Fri Feb 15 14:44:11 AST 2019
    Notes       :
  ----------------------------------------------------------------------*/

define temp-table tt-cashbookrule like ub.cashbookrule
  field RkoMask         as character
  field PkoMask         as character
  field currPko         as character
  field currRko         as character
  field ManagerPosition as character
  field ManagerFIO      as character
  field BuhFIO          as character
  field struct          as character
  field uchet           as character
  field DptName         as character
  field DptType         as character
  field DptCode         as integer
  field obj             as character
  field stat            as character
  field Pin             as character
.

define dataset ds-cashbookrule for tt-cashbookrule .

 method private character getMgrPositionName (input p-post-chief as character) :
    define variable v-name as character no-undo .
    case p-post-chief :
      when "1" then v-name = "Директор" .
      when "2" then v-name = "Управляющий" .
      when "0" then v-name = "Должность рук-ля фирмы" .
      otherwise v-name = p-post-chief .        
    end case .
    return v-name .
  end method . /* end_of getMgrPositionName */

 method private character getMgrPositionID (input p-post-chief as character) :
    define variable v-id as character no-undo .
    case p-post-chief :
      when "Директор" then v-id = "1" .
      when "Управляющий" then v-id = "2" .
      when "Должность рук-ля фирмы" then v-id = "0" .
      otherwise v-id = p-post-chief.
    end case .
    return v-id .
  end method . /* end_of getMgrPositionName */
  
  method private character getMgrFioName (input p-fio-chief as character) :
    define variable v-name as character no-undo .
    case p-fio-chief :
      when "1" then v-name = "ФИО руководителя магазина" .
      when "0" then v-name = "ФИО руководителя фирмы" .
      otherwise v-name = p-fio-chief .
    end case .
    return v-name .
  end method . /* end_of getMgrFioName */

  method private character getMgrFioID (input p-fio-chief as character) :
    define variable v-id as character no-undo .
    case p-fio-chief :
      when "ФИО руководителя магазина" then v-id = "1" .
      when "ФИО руководителя фирмы" then v-id = "0" .
        otherwise v-id = p-fio-chief .
    end case .
    return v-id .
  end method . /* end_of getMgrFioName */
  
  method private character getBuhFioName (input p-fio-booker as character) :
    define variable v-name as character no-undo .
    case p-fio-booker :
      when "1" then v-name = "ФИО бухгалтера магазина" .
      when "0" then v-name = "ФИО гл. бухгалтера фирмы" .
      otherwise v-name = p-fio-booker .
    end case .
    return v-name .
  end method . /* end_of getBuhFioName */

  method private character getBuhFioID (input p-fio-booker as character) :
    define variable v-id as character no-undo .
    case p-fio-booker :
      when "ФИО бухгалтера магазина" then v-id = "1" .
      when "ФИО гл. бухгалтера фирмы" then v-id = "0" .
      otherwise v-id = p-fio-booker .
    end case .
    return v-id .
  end method . /* end_of getBuhFioName */
  
  method private character getStructName (input p-struct-unit as integer) :
    /* Поле «Структурн.подразд»  */
    define variable v-name as character no-undo .
    case p-struct-unit :
      when 1 then v-name = "Взять из объекта" .
      when 2 then v-name = "Значение по умолчанию" .
      when 0 then v-name = "Заполняет оператор" .
        otherwise v-name = string(p-struct-unit) .
    end case .
    return v-name .
  end method . /* end_of getStructName */
  
  method private character getStructID (input p-struct-unit as character) :
    define variable v-id as character no-undo .
    case p-struct-unit :
      when "Взять из объекта" then v-id = "1" .
      when "Значение по умолчанию" then v-id = "2" .
      when "Заполняет оператор" then v-id = "0" .
        otherwise v-id = p-struct-unit .
    end case .
    return v-id .
  end method . /* end_of getStructName */
  
  method private character getUchetName (input p-acc-shift as integer) :
    /* Учет ведется по:
• 0 –календарным датам
• 1 –по сменам
       В экранной форме реализован выбор:
arrayvar6[1] = "по сменным датам".
arrayvar6[2] = "по календарным датам".
    */
    define variable v-name as character no-undo .
    case p-acc-shift :
      when 1 then v-name = "по сменным датам" .
      when 0 then v-name = "по календарным датам" .
        otherwise v-name = string (p-acc-shift) .
    end case .
    return v-name .
  end method . /* end_of getUchetName */
  
  method private character getUchetID (input p-acc-shift as character) :
    /* Учет ведется по:
• 0 –календарным датам
• 1 –по сменам
       В экранной форме реализован выбор:
arrayvar6[1] = "по сменным датам".
arrayvar6[2] = "по календарным датам".
    */
    define variable v-id as character no-undo .
    case p-acc-shift :
      when "по сменным датам" then v-id = "1" .
      when "по календарным датам" then v-id = "0" .
        otherwise v-id = p-acc-shift .
    end case .
    return v-id .
  end method . /* end_of getUchetName */