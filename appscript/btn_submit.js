function sendCloudRun(responses) {
    const URI_CLOUD_RUN = "";
  
    const payload = {
      responses: responses
    };
  
    const options = {
      method: "post",
      contentType: "application/json",
      payload: JSON.stringify(payload, null, 2)
    };
    
    const responsesApi = UrlFetchApp.fetch(URI_CLOUD_RUN, options);
    Logger.log(responsesApi.getContentText());
  
  }
  
  function onFormSubmit(e) {
    const formResponse = e.response;
  
    const responses = formResponse.getItemResponses().map((itemResponse) => {
        return {
          question: itemResponse.getItem().getTitle(),
          response: itemResponse.getResponse()
        }
      }
    );
  
    sendCloudRun(responses);
  }
  