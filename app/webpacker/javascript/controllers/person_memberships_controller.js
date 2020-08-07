import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = ['teamlist'];

    add() {
      const skeletonHtml = this.teamlistTarget.dataset.template;
      const childIndex = Date.now().toString();
      const newTeamHtml = skeletonHtml.replace(/TEMPLATE_REPLACE/g, childIndex);

      this.teamlistTarget.insertAdjacentHTML('beforeend', newTeamHtml);
      this.teamlistTarget.querySelector('.ws-profile-edit__team:last-child input[type="radio"]').focus();
    }
}
