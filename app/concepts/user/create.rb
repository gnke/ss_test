class User::Create < Trailblazer::Operation
  def process(params)
    return @model = params[:current_user] if params[:current_user].present?

    @model =
      if params[:current_user_id].nil?
        User.create!(fullname: "Guest")
      else
        User.find(params[:current_user_id])
      end
  end
end
