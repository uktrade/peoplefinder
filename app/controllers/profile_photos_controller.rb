# frozen_string_literal: true

class ProfilePhotosController < ApplicationController
  include StateCookieHelper

  def create
    set_state_cookie_picture_editing_complete
    photo = ProfilePhoto.create(profile_photo_params)

    # NOTE: IE requires JSON as text
    if photo.valid?
      render plain: photo.to_json
    else
      render plain: { error: photo.errors.full_messages.join(', ') }.to_json, status: :unprocessable_entity
    end
  end

  private

  def profile_photo_params
    params.require(:profile_photo).permit(:image)
  end
end
