class SheetService {
    constructor(id_plan) {
       this.id_plan = SpreadsheetApp.openById(id_plan);
    }
  
    getValues(name_plan, range) {
      // Retorna um array bidimensiona
      // com base em um intervalo da planilha
      // se o tamnho do array for 0 retornar um array vazio
  
      const sheet = this.id_plan.getSheetByName(name_plan);
      const values = sheet.getRange(range).getValues();
  
      return values.length > 0 ? values: [[]]; // condicao ternaria JS
    }
  }
  
  class FormService {
    constructor(form) {
      this.form = form || FormApp.getActiveForm();
    }
  
    getQuestion(id_question) {
      return this.form.getItems()[id_question];
    }
  
    setUpdateList(id_question, values) {
      const question = this.getQuestion(id_question).asListItem();
      const values_options = [...new Set(values.map(([row]) => row))].sort();
  
      question.setChoiceValues(values_options);
    }
  }
  
  function dropdownList() {
    const plan = new SheetService(
        "id_planilha"
    )
    
    const id_form = FormApp.openById(
      "id_forms"
    )
    
    // adiciona a lista de valores a uma questão do google forms
    const form = new FormService(id_form);
    form.setUpdateList(0, plan.getValues("estados", "A2:A"));
    form.setUpdateList(2, plan.getValues("cargo", "A2:A"));
  }
  