require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from '@rails/ujs';
import { initAll } from 'govuk-frontend';

import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

// Initialise Rails UJS
Rails.start();

// Initialise GOV.UK Frontend
initAll();

// Initialise Stimulus
const application = Application.start()
const stimulusContext = require.context("../javascript/controllers", true, /\.js$/)
application.load(definitionsFromContext(stimulusContext))
