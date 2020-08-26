import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['explanationPanel', 'field', 'fieldContainer'];

  reveal(event) {
    this.explanationPanelTarget.classList.add('ws-profile-edit__additional-email--hidden');
    this.fieldContainerTarget.classList.remove('ws-profile-edit__additional-email--hidden');

    this.fieldTarget.focus();

    event.preventDefault();
  }
}
