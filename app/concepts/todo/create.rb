class Todo::Create < Trailblazer::Operation
  include Model
  model Todo, :create

  contract do
    property :title, validates: { presence: true }
  end

  def process(params)
    validate(params[:todo]) do
      update_todo_list(contract.model, params)
      contract.save
    end
  end

  private

  def update_todo_list(todo, params)
    todo.list = get_or_create_todo_list(params)
    todo.list.user = get_or_create_user(params)
    todo.list.save
  end

  def get_or_create_todo_list(params)
    todo_list =
      if params[:todo_list_id].present?
        TodoList.find(params[:todo_list_id])
      else
        TodoList.find_or_create_by(name: "Default To-do List")
      end
  end

  def get_or_create_user(params)
    return params[:current_user] if params[:current_user].present?

    if params[:current_user_id].nil?
      User.create!(fullname: "Guest")
    else
      User.find(params[:current_user_id])
    end
  end
end
