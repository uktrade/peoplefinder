import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = ["teamlist"];

    add(event) {
        let skeleton_html = this.teamlistTarget.dataset.template;
        let child_index = Date.now().toString();
        let new_team_html = skeleton_html.replace(/TEMPLATE_REPLACE/g, child_index);

        this.teamlistTarget.insertAdjacentHTML('beforeend', new_team_html);
    }
}
