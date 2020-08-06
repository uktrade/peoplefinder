import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = ['team', 'destroy'];

    delete() {
      this.teamTarget.classList.add('ws-profile-edit__team--hidden');
      this.destroyTarget.value = 'true';
    }
}
