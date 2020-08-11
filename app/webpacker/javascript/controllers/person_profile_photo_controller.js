import { Controller } from 'stimulus';
import Croppr from 'croppr';

export default class extends Controller {
  static targets = ['cropX', 'cropY', 'cropW', 'cropH', 'fileField', 'pictureHeader', 'preview', 'previewContainer'];

  acceptedFileTypes = ['image/jpg', 'image/jpeg', 'image/png'];

  changeFile(event) {
    this.removeError();

    const file = this.fileFieldTarget.files[0];

    if(!this.acceptedFileTypes.includes(file['type'])) {
      this.fail('This file is not an accepted image format. Please choose a JPG or PNG file.');
      return;
    }

    if(file.size > 8000000) {
      this.fail('This photo file is too big. It needs to be less than 8MB.');
      return;
    }

    const reader = new FileReader();

    reader.onload = (readerEvent) => {
      const image = new Image();
      image.src = readerEvent.target.result;
      image.classList.add('ws-profile-edit__photo-preview');
      image.dataset.target = 'person-profile-photo.preview';

      image.onload = () => {
        let originalWidth = image.width;
        let originalHeight = image.height;

        if (originalWidth < 500 || originalHeight < 500) {
          this.fail(`This photo is not big enough. It is ${originalWidth} by ${originalHeight} pixels, but it needs to be at least 500 by 500 pixels.`);
          return;
        }

        if (originalWidth > 8192 || originalHeight > 8192) {
          this.fail(`This photo is too big. It is ${originalWidth} by ${originalHeight} pixels, but it needs to be at most 8192 by 8192 pixels.`);
          return;
        }

        this.pictureHeaderTarget.textContent = 'Crop new profile photo';
        this.setCroppablePreviewImage(image);
      }
    };

    reader.readAsDataURL(file);
  }

  setCroppablePreviewImage(image) {
    this.previewContainerTarget.textContent = '';
    this.previewContainerTarget.appendChild(image);

    new Croppr(this.previewTarget, {
      aspectRatio: 1,
      onCropEnd: (data) => {
        this.cropXTarget.value = data.x;
        this.cropYTarget.value = data.y;
        this.cropWTarget.value = data.width;
        this.cropHTarget.value = data.height;
      }
    });
  }

  fail(message) {
    this.pictureHeaderTarget.textContent = 'New profile photo';

    const formGroupElement = this.fileFieldTarget.parentElement;
    formGroupElement.classList.add('govuk-form-group--error');

    const errorSpan = document.createElement('span');
    errorSpan.classList.add('govuk-error-message');
    errorSpan.innerHTML = `<span class="govuk-visually-hidden">Error:</span> ${message}`;
    formGroupElement.insertBefore(errorSpan, this.fileFieldTarget);

    this.previewContainerTarget.innerHTML = '<div class="ws-profile-edit__photo-preview--error"><span class="govuk-visually-hidden">Cannot preview file</span></div>';
  }

  removeError() {
    const formGroupElement = this.fileFieldTarget.parentElement;
    formGroupElement.classList.remove('govuk-form-group--error');

    const errorElement = formGroupElement.querySelector('.govuk-error-message');
    if(errorElement) errorElement.remove();
  }
}
