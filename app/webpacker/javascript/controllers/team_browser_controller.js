import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ["node", "parent"];

  switchTo(event) {
    let id = event.currentTarget.dataset.group;

    this.nodeTargets.forEach((el, i) => {
      el.classList.toggle("ws-team-browser__node--visible", el.dataset.group == id);

      if(el.dataset.group == id) {
        let newGroup = el.getElementsByTagName('input')[0];
        newGroup.checked = true;
        newGroup.focus();
      }
    })
  }

  activate(event) {
    this.parentTarget.classList.add("ws-team-browser--activated");
    this.focus(null);
  }

  keyPressed(event) {
    switch(event.code) {
      case "ArrowUp":
      case "ArrowDown":
        this.moveRowFocus(event);
        break;
      case "ArrowRight":
      case "Space":
      case "Enter":
        this.selectRow(event);
        break;
      case "Tab":
        // Don't prevent default on tabbing away, and set flag to not jump focus back in when tabbing out
        if(event.shiftKey) this.skipFocus = true;
        return;
    }

    event.preventDefault();
  }

  clickRow(event) {
    let input = this.containedInput(event.currentTarget);

    input.focus();
    input.click();
  }

  focus(event) {
    if(this.skipFocus) {
      this.skipFocus = false;
      return;
    }

    this.parentTarget.querySelector("input:checked").focus();
  }

  moveRowFocus(event) {
    let elementToFocus;

    if(event.code === "ArrowUp") {
      elementToFocus = event.currentTarget.previousSibling;

      if(!elementToFocus) {
        // Jump "up" to current team row if possible (if currently in first row of child teams)
        let parentPreviousSibling = event.currentTarget.parentNode.previousSibling;

        if(parentPreviousSibling.classList.contains('ws-team-browser__row')) {
          elementToFocus = parentPreviousSibling;
        }
      }
    } else if(event.code === "ArrowDown") {
      elementToFocus = event.currentTarget.nextSibling;
    }

    if(!elementToFocus) return;

    let nextFocus = this.containedInput(elementToFocus);
    nextFocus.focus();
    nextFocus.checked = true;
  }

  selectRow(event) {
    let button = event.currentTarget.getElementsByTagName('button')[0];
    if(!button) return;

    button.click();
  }

  containedInput(element) {
    return element.getElementsByTagName('button')[0] || element.getElementsByTagName('input')[0];
  }
}
