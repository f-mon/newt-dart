
part of newt;

class ActivityDisplay {

  ActivityDisplay parentDisplay;
  Element element;

  ActivityDisplay() {
    this.element = new Element.div();
  }
  ActivityDisplay.popupDisplay(ActivityDisplay this.parentDisplay) {
    this.element = new Element.div(); 
  }
  
  showActive(Activity activity) {
    this.element.append(activity.view);
  }

  paused(Activity activity) {
    activity.view.hidden = true;
  }

  resumed(Activity activity) {
    activity.view.hidden = false;
  }

  remove(Activity activity) {
    activity.view.remove();
  }

  ActivityDisplay createPopupDisplay() {
    //TODO put layer on element
    ActivityDisplay popupDisplay = new ActivityDisplay.popupDisplay(this);
    this.element.append(popupDisplay.element);
    return popupDisplay;
  }
  
  void destroyDisplayAndResumeParent() {
    this.element.remove();
  }
  
  bool isRootDisplay() {
    return this.parentDisplay==null;
  }
  
}