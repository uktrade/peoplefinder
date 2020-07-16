import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ["node", "parent"];

  switchTo(event) {
    var id = event.currentTarget.dataset.group;

    this.nodeTargets.forEach((el, i) => {
      el.classList.toggle("ws-team-browser__node--visible", el.dataset.group == id);
    })
  }

  activate(event) {
    this.parentTarget.classList.add("ws-team-browser--activated");
  }
}
