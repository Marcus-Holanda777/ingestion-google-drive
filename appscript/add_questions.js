class SheetService {
  constructor(idPlan) {
     this.appSheet = SpreadsheetApp.openById(idPlan);
  }

  getValues(name, range) {
    // Retorna um array bidimensiona
    // com base em um intervalo da planilha
    // se o tamnho do array for 0 retornar um array vazio

    const sheet = this.appSheet.getSheetByName(name);
    const values = sheet.getRange(range).getValues();

    return values.length > 0 ? values: [[]]; // condicao ternaria JS
  }
}

class FormService {
  constructor(form) {
    this.form = form || FormApp.getActiveForm();
  }

  getQuestion(question) {
    return this.form.getItems()[question];
  }

  setUpdateList(question, values, convert = 'list') {
    const includesConvert = ["list", "mult"];

    if(!includesConvert.includes(convert)) {
      throw new Error("Option not allowed !");
    }

    if(values.length === 0 || values[0].length === 0) {
      throw new Error("Empty list !");
    }
    
    let appQuestion = this.getQuestion(question)
    
    if(convert === 'list') {
      appQuestion = appQuestion.asListItem();
    } else {
      appQuestion = appQuestion.asCheckboxItem();
    }

    const options = [...new Set(values.map(([row]) => row))].sort();
    appQuestion.setChoiceValues(options);
  }
}

function dropdownList() {
  const plan = new SheetService(
      "id_plan"
  )
  
  const id_form = FormApp.openById(
    "id_form"
  )
  
  const form = new FormService(id_form);

  // lista suspensa
  form.setUpdateList(0, plan.getValues("estados", "A2:A"));
  form.setUpdateList(2, plan.getValues("cargo", "A2:A"));

  // selecao multipla
  form.setUpdateList(3, plan.getValues("conhecimentos", "A2:A",), "mult");
  form.setUpdateList(4, plan.getValues("ferramentas", "A2:A"), "mult");
}
