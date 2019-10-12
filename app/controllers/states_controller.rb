class StatesController < ApplicationController

  def state_by_city
    city = City.find(params[:id])

    render json: {state: city.state}.as_json
  end

  def fee_by_state
    state = State.find(params[:state_id])

    render json: {state: state}.as_json
  end

end
