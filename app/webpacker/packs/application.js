require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from '@rails/ujs';
import { initAll } from 'govuk-frontend';

Rails.start();
initAll();
