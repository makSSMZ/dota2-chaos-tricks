const refs = {
  root: $('#root'),
  event: () => $('#event'),
  description: () => $('#description'),
  eventText: () => $('#eventText'),
  userText: () => $('#userText'),
  descriptionSecond: () => $('#descriptionSecond'),
  teamText: () => $('#teamText'),
  textWrapper: () => $('#textWrapper')
};

const notifies = [];
let isShowingNotify = false;

const showNextNotify = (isNeedCheck = true) => { 
  if (isNeedCheck && isShowingNotify) {
    return;
  }

  if (notifies.length == 0) {
    isShowingNotify = false;
    return;
  }

  isShowingNotify = true;
  let notifyData = notifies.shift();
  refs.userText().text = notifyData.userText;
  refs.eventText().text = $.Localize(notifyData.eventText);
  refs.teamText().text = $.Localize(notifyData.teamText);
  refs.descriptionSecond().text = $.Localize(notifyData.descriptionSecond);
  
  let eventObj = refs.event();
  let textWrapperObj = refs.textWrapper();
  let isOneLineText = notifyData.descriptionSecond == "" || notifyData.descriptionSecond == null;

  if (isOneLineText) {
    eventObj?.AddClass('eventOneLine');
    textWrapperObj?.AddClass('textWrapperOneLine');
  }

  $.Schedule(0.25, () => refs.event().AddClass('fade-in'));
  $.Schedule(5.0, () => refs.event().AddClass('fade-out'));
  $.Schedule(6.0, () => {
    if (eventObj != null) {
      eventObj.RemoveClass('fade-out');
      eventObj.RemoveClass('fade-in');
    }

    if (isOneLineText) {
      eventObj?.RemoveClass('eventOneLine');
      textWrapperObj?.RemoveClass('textWrapperOneLine');
    }
     
    if (notifies.length == 0) {
      isShowingNotify = false;
    } else {
      showNextNotify(false);
    }    
  });
};

const addNotify = (userText, eventText, teamText, descriptionSecond) => {
  notifies.push({
	  userText: userText,
    eventText: eventText,
	  teamText: teamText,
	  descriptionSecond: descriptionSecond
  }); 
}

const AddHudOnScreen = (data) => {
  addNotify(data.User, data.Event, data.Team, data.DescriptionSecond);
  showNextNotify();
};

(() => {
  $.Msg("Test msg");
  GameEvents.Subscribe("AddHudOnScreen", AddHudOnScreen);
})();
